//
//  DUAReader.swift
//  DUAReader
//
//  Created by mengminduan on 2017/12/26.
//  Copyright © 2017年 nothot. All rights reserved.
//

import UIKit
import DTCoreText

enum DUAReaderState {
    case busy
    case ready
}

protocol DUAReaderDelegate: NSObjectProtocol {
    func readerDidClickSettingFrame(reader: DUAReader)
    func reader(reader: DUAReader, readerStateChanged state: DUAReaderState)
    func reader(reader: DUAReader, readerProgressUpdated curChapter: Int, curPage: Int, totalPages: Int)
    func reader(reader: DUAReader, chapterTitles: [String])
}

extension DUAReaderDelegate {
    func reader(reader: DUAReader, chapterTitles: [String]) {}
}

class DUAReader: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, DUATranslationProtocol {
    /// 配置类
    public var config: DUAConfiguration!
    /// 代理
    public var delegate: DUAReaderDelegate?
    /// 章节缓存（分页后的页面数组）
    private var chapterCaches: [String: [DUAPageModel]] = [String: [DUAPageModel]]()
    /// chapter model cache
    private var chapterModels = [String: DUAChapterModel]()
    /// 数据解析类
    private var dataParser: DUADataParser = DUADataParser()
    /// 缓存队列
    private var cacheQueue: DispatchQueue = DispatchQueue(label: "duareader.cache.queue")
    /// page vc
    private var pageVC: DUAContainerPageViewController?
    /// table view
    private var tableView: DUATableView?
    /// translation vc
    private var translationVC: DUAtranslationControllerExt?
    /// 状态栏
    private var statusBar: DUAStatusBar?
    /// 是否重分页
    private var isReCutPage: Bool = false
    /// 当前页面
    private var currentPageIndex: Int = 0
    /// 当前章节
    private var currentChapterIndex: Int = 0
    /// 分页前当前页首字符索引
    
    /// 重分页后如何定位阅读进度？
    /// 首先记录分页前当前页面首字符在本章的索引，重分页后根据索引确定用户先前看的页面在章节中新的位置
    private var prePageStartLocation: Int = -1
    /// 首次进阅读器
    private var firstIntoReader = true
    /// 页面饥饿
    private var pageHunger = false
    /// 解析后的所有章节model
    private var totalChapterModels: [DUAChapterModel] = []
    /// 对table view而言，status bar是放在reader view上的，其他模式则是放在每个page页面上
    private var statusBarForTableView: DUAStatusBar?
    /// 是否成功切换到某章节，成功为0，不成功则记录未成功切换的章节index，当指定跳至某章节时使用
    var successSwitchChapter = 0
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
#if DEBUG
    deinit {
        print("DUAReader====dealloc")
    }
#endif
    
    // MARK:--UI渲染
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        if self.config.bookType == DUAReaderBookType.epub {
            self.dataParser = DUAEpubDataParser()
        }else {
            self.dataParser = DUATextDataParser()
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pagingTap(ges:)))
        self.view.addGestureRecognizer(tapGesture)
        self.addObserverForConfiguration()
        self.loadReaderView()
    }
    
    private func loadReaderView() -> Void {
        switch self.config.scrollType {
        case .curl:
            self.loadPageViewController()
        case .vertical:
            self.loadTableView()
        case .horizontal:
            self.loadTranslationVC(animating: true)
        case .none:
            self.loadTranslationVC(animating: false)
        }
        
        if self.config.backgroundImage != nil {
            self.loadBackgroundImage()
        }
    }
    
    private func loadPageViewController() -> Void {

        self.clearReaderViewIfNeed()
        let transtionStyle: UIPageViewController.TransitionStyle = (self.config.scrollType == .curl) ? .pageCurl : .scroll
        self.pageVC = DUAContainerPageViewController(transitionStyle: transtionStyle, navigationOrientation: .horizontal, options: nil)
        self.pageVC?.dataSource = self
        self.pageVC?.delegate = self
        self.pageVC?.view.backgroundColor = UIColor.clear
        self.pageVC?.isDoubleSided = (self.config.scrollType == .curl) ? true : false
        
        self.addChild(self.pageVC!)
        self.view.addSubview((self.pageVC?.view)!)
        self.pageVC?.didMove(toParent: self)
    }
    
    private func loadTableView() -> Void {
        
        self.clearReaderViewIfNeed()
        self.tableView = DUATableView(frame: CGRect(x: 0, y: config.contentFrame.origin.y, width: UIScreen.main.bounds.size.width, height: config.contentFrame.size.height), style: .plain)
        self.tableView!.dataSource = self
        self.tableView!.delegate = self
        self.tableView!.showsVerticalScrollIndicator = false
        self.tableView!.separatorStyle = .none
        self.tableView!.estimatedRowHeight = 0
        self.tableView!.scrollsToTop = false
        self.tableView!.backgroundColor = UIColor.clear

        self.view.addSubview(tableView!)
        
        self.addStatusBarTo(view: self.view, totalCounts: self.pageArrayFromCache(chapterIndex: currentChapterIndex).count, curPage: currentPageIndex)
    }
    
    /// bool值意味着平移翻页还是无动画翻页
    ///
    /// - Parameter animating: none
    func loadTranslationVC(animating: Bool) -> Void {
        
        self.clearReaderViewIfNeed()
        self.translationVC = DUAtranslationControllerExt()
        self.translationVC?.delegate = self
        self.translationVC?.allowAnimating = animating
        self.addChild(self.translationVC!)
        self.translationVC?.didMove(toParent: self)
        self.view.addSubview(self.translationVC!.view)
    }
    
    private func loadPage(pageIndex: Int) -> Void {
        switch self.config.scrollType {
        case .curl:
            let page = self.getPageVCWith(pageIndex: pageIndex, chapterIndex: self.currentChapterIndex)
            if page == nil {
                return
            }
            self.pageVC?.setViewControllers([page!], direction: .forward, animated: false, completion: nil)
        case .vertical:
            print("load table view page")
            tableView?.dataArray.removeAll()
            tableView?.dataArray = self.pageArrayFromCache(chapterIndex: currentChapterIndex)
            self.tableView?.cellIndex = pageIndex
            if tableView?.dataArray == nil {
                return
            }
            
            self.tableView?.isReloading = true
            self.tableView?.reloadData()
            self.tableView?.scrollToRow(at: IndexPath(row: tableView!.cellIndex, section: 0), at: .top, animated: false)
            self.tableView?.isReloading = false
            
            self.statusBarForTableView?.totalPageCounts = (tableView?.dataArray.count)!
            self.statusBarForTableView?.curPageIndex = currentPageIndex
            
            /// 当加载的页码为最后一页，需要手动触发一次下一章的请求
            if self.currentPageIndex == self.pageArrayFromCache(chapterIndex: self.currentChapterIndex).count - 1 {
                self.requestNextChapterForTableView()
            }
        case .horizontal:
            let page = self.getPageVCWith(pageIndex: pageIndex, chapterIndex: self.currentChapterIndex)
            if page == nil {
                return
            }
            self.translationVC?.setViewController(viewController: page!, direction: .left, animated: false, completionHandler: nil)
        case .none:
            let page = self.getPageVCWith(pageIndex: pageIndex, chapterIndex: self.currentChapterIndex)
            if page == nil {
                return
            }
            self.translationVC?.setViewController(viewController: page!, direction: .left, animated: false, completionHandler: nil)
            
        }
    }
    
    private func loadBackgroundImage() -> Void {
        var curPage: DUAPageViewController? = nil
        if config.scrollType == .curl {
            curPage = pageVC?.viewControllers?.first as? DUAPageViewController
            if curPage != nil {
                let imageView = curPage?.view.subviews.first as? UIImageView
                imageView?.image = self.config.backgroundImage
            }
        }
        if config.scrollType == .horizontal || config.scrollType == .none {
            curPage = translationVC?.children.first as? DUAPageViewController
            if curPage != nil {
                let imageView = curPage?.view.subviews.first as? UIImageView
                imageView?.image = self.config.backgroundImage
            }
        }
        let firstView = self.view.subviews.first as? UIImageView
        if firstView != nil {
            firstView?.image = self.config.backgroundImage
        } else {
            let imageView = UIImageView(frame: self.view.frame)
            imageView.image = self.config.backgroundImage
            self.view.insertSubview(imageView, at: 0)
        }
    }
    
    private func addStatusBarTo(view: UIView, totalCounts: Int, curPage: Int) -> Void {
        let safeAreaBottomHeight: CGFloat = UIScreen.main.bounds.size.height == 812.0 ? 34 : 0
        let rect = CGRect(x: config.contentFrame.origin.x, y: UIScreen.main.bounds.size.height - 30 - safeAreaBottomHeight, width: config.contentFrame.width, height: 20)
        let statusBar = DUAStatusBar(frame: rect)
        view.addSubview(statusBar)
        statusBar.totalPageCounts = totalCounts
        statusBar.curPageIndex = curPage
        self.statusBarForTableView = statusBar
    }
    
    func clearReaderViewIfNeed() -> Void {
        if self.pageVC != nil {
            self.pageVC?.view.removeFromSuperview()
            self.pageVC?.willMove(toParent: nil)
            self.pageVC?.removeFromParent()
        }
        if self.tableView != nil {
            for item in self.view.subviews {
                item.removeFromSuperview()
            }
        }
        if self.translationVC != nil {
            self.translationVC?.view.removeFromSuperview()
            self.translationVC?.willMove(toParent: nil)
            self.translationVC?.removeFromParent()
        }
    }
    
    /// MARK:--数据处理
    
    
    /// 仿真、平移、无动画翻页模式使用
    ///
    /// - Parameters:
    ///   - pageIndex: 页面索引
    ///   - chapterIndex: 章节索引
    /// - Returns: 单个page页面
    private func getPageVCWith(pageIndex: Int, chapterIndex: Int) -> DUAPageViewController? {
        let page = DUAPageViewController()
        page.index = pageIndex
        page.chapterBelong = chapterIndex
        if self.config.backgroundImage != nil {
            page.backgroundImage = config.backgroundImage
        }
        let dtLabel = DUAAttributedView(frame: CGRect(x: 0, y: config.contentFrame.origin.y, width: self.view.frame.size.width, height: config.contentFrame.height))
        dtLabel.edgeInsets = UIEdgeInsets(top: 0, left: config.contentFrame.origin.x, bottom: 0, right: config.contentFrame.origin.x)
        
        let pageArray = pageArrayFromCache(chapterIndex: chapterIndex)
        if pageArray.isEmpty {
            return nil
        }
        let pageModel = pageArray[pageIndex]
        dtLabel.attributedString = pageModel.attributedString
        dtLabel.backgroundColor = .clear
        page.view.addSubview(dtLabel)
        addStatusBarTo(view: page.view, totalCounts: pageArray.count, curPage: pageIndex)
        return page
    }
    
    private func pageArrayFromCache(chapterIndex: Int) -> [DUAPageModel] {
        if let pageArray = chapterCaches[String(chapterIndex)] {
            return pageArray
        } else {
            return []
        }
    }
    
    private func cachePageArray(pageModels: [DUAPageModel], chapterIndex: Int) {
        self.chapterCaches[String(chapterIndex)] = pageModels
        pageHunger = true
    }
    
    
    private func requestChapterWith(index: Int) {
        if !pageArrayFromCache(chapterIndex: index).isEmpty {
            return
        }
        if index < 0 || index >= totalChapterModels.count {
            return
        }
        /// 这里在书籍解析后直接保存了所有章节model，故直接取即可
        
        /// 对于分章节阅读的情况，每个章节可能需要通过网络请求获取，完成后调用readWithchapter方法即可
        
        let chapter = totalChapterModels[index]
        readWith(chapter: chapter, pageIndex: 1)
    }
    
    private func updateChapterIndex(index: Int, isFirstLoad: Bool = false) {
        if currentChapterIndex == index {
            return
        }
        print("进入第 \(index) 章")
        let forward = currentChapterIndex > index ? false : true
        currentChapterIndex = index
        if isFirstLoad && index > 0 {
            forwardCacheIfNeed(forward: false)
        }
        /// 每当章节切换时触发预缓存
        forwardCacheIfNeed(forward: forward)
    }
    
    
    /// 请求上个章节 for tableview
    private func requestLastChapterForTableView() -> Void {
        tableView?.scrollDirection = .up
        if currentChapterIndex - 1 <= 0 {
            return
        }
        self.requestChapterWith(index: currentChapterIndex - 1)
        let lastPages = self.pageArrayFromCache(chapterIndex: currentChapterIndex - 1)
        if lastPages.isEmpty {
            /// 页面饥饿
            pageHunger = true
            self.postReaderStateNotification(state: .busy)
            return
        }
        var indexPathsToInsert: [IndexPath] = []
        for (index, _) in lastPages.enumerated() {
            let indexPath = IndexPath(row: index, section: 0)
            indexPathsToInsert.append(indexPath)
        }
        self.tableView?.dataArray = lastPages + (self.tableView?.dataArray)!
        self.tableView?.beginUpdates()
        self.tableView?.insertRows(at: indexPathsToInsert, with: .top)
        self.tableView?.endUpdates()

        DispatchQueue.main.async {
            self.tableView?.cellIndex += lastPages.count
            self.tableView?.setContentOffset(CGPoint(x: 0, y: CGFloat(lastPages.count)*self.config.contentFrame.height), animated: false)
        }
        
    }
    
    /// 请求下个章节 for tableview
    private func requestNextChapterForTableView() -> Void {
        tableView?.scrollDirection = .down
        if currentChapterIndex + 1 > totalChapterModels.count {
            return
        }
        self.requestChapterWith(index: currentChapterIndex + 1)
        let nextPages = self.pageArrayFromCache(chapterIndex: currentChapterIndex + 1)
        if nextPages.isEmpty {
            ///                 页面饥饿
            pageHunger = true
            self.postReaderStateNotification(state: .busy)
            return
        }
        var indexPathsToInsert: [IndexPath] = []
        for (index, _) in nextPages.enumerated() {
            let indexPath = IndexPath(row: (tableView?.dataArray.count)! + index, section: 0)
            indexPathsToInsert.append(indexPath)
        }
        self.tableView?.dataArray += nextPages
        self.tableView?.beginUpdates()
        self.tableView?.insertRows(at: indexPathsToInsert, with: .none)
        self.tableView?.endUpdates()
    }
    
    // MARK:--预缓存
    
    
    /// 为何要预缓存？
    /// 本阅读器是按照逐个章节的方式阅读的（便于分章阅读，例如连载小说等），如果当前章节阅读结束时请求下一章数据
    /// 那么章节解析分页均会耗时（当然你可以不等分页全部完成就直接展示已经分好的页面，以减少用户等待，那是另一套
    /// 逻辑了）。因此每当用户跨入新的一章，程序自动触发当前章下一章的请求，提前准备好数据，以实现章节无缝切换
    ///
    /// - Parameter forward: 向前缓存还是向后缓存
    private func forwardCacheIfNeed(forward: Bool) -> Void {
        let predictIndex = forward ? currentChapterIndex + 1 : currentChapterIndex - 1
        if predictIndex < 0 || predictIndex >= totalChapterModels.count {
            return
        }
        self.cacheQueue.async {
            let nextPageArray = self.pageArrayFromCache(chapterIndex: predictIndex)
            if nextPageArray.isEmpty {
                print("执行预缓存 章节 \(predictIndex)")
                self.forwardCacheWith(chapter: self.totalChapterModels[predictIndex])
            }
        }
    }
    
    private func forwardCacheWith(chapter: DUAChapterModel) -> Void {
        var pageArray: [DUAPageModel] = []
        let attrString = self.dataParser.attributedStringFromChapterModel(chapter: chapter, config: self.config)
        self.dataParser.cutPageWith(attrString: attrString!, config: self.config, completeHandler: {
            (completedPageCounts, page, completed) -> Void in
            pageArray.append(page)
            if completed {
                self.cachePageArray(pageModels: pageArray, chapterIndex: chapter.chapterIndex)
                print("预缓存完成")
                if pageHunger {
                    DispatchQueue.main.async {
                        self.postReaderStateNotification(state: .ready)
                        self.pageHunger = false
                        if self.pageVC != nil {
                            self.loadPage(pageIndex: self.currentPageIndex)
                        }
                        if self.tableView != nil {
                            if self.currentPageIndex == 0 && self.tableView?.scrollDirection == .up {
                                self.requestLastChapterForTableView()
                            }
                            if self.currentPageIndex == self.pageArrayFromCache(chapterIndex: self.currentChapterIndex).count - 1 && self.tableView?.scrollDirection == .down {
                                self.requestNextChapterForTableView()
                            }
                        }
                    }
                }
            }
        })
    }
    
    // MARK:--属性观察器
    
    private func addObserverForConfiguration() -> Void {
        self.config.didFontSizeChanged = {[weak self] (fontSize) in
            self?.reloadReader()
        }
        self.config.didLineHeightChanged = {[weak self] (lineHeight) in
            self?.reloadReader()
        }
        self.config.didFontNameChanged = {[weak self] (String) in
            self?.reloadReader()
        }
        self.config.didBackgroundImageChanged = {[weak self] (UIImage) in
            self?.loadBackgroundImage()
        }
        self.config.didScrollTypeChanged = {[weak self] (DUAReaderScrollType) in
            self?.loadReaderView()
            self?.loadPage(pageIndex: self!.currentPageIndex)
        }
    }
    
    private func reloadReader() -> Void {
        isReCutPage = true
        if prePageStartLocation == -1 {
            let pageArray = self.pageArrayFromCache(chapterIndex: currentChapterIndex)
            prePageStartLocation = (pageArray[currentPageIndex].range?.location)!
        }
        let chapter = chapterModels[String(currentChapterIndex)]
        self.readWith(chapter: chapter!, pageIndex: currentPageIndex)
    }
    
    // MARK:--PageVC Delegate
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        print("向前翻页")
        struct FirstPage {
            static var arrived = false
        }
        if viewController is DUAPageViewController {
            let page = viewController as! DUAPageViewController
            let backPage = DUABackViewController()
            var nextIndex = page.index - 1
            if nextIndex < 0 {
                if currentChapterIndex < 1 {
                    return nil
                }
                FirstPage.arrived = true
                pageVC?.willStepIntoLastChapter = true
                requestChapterWith(index: currentChapterIndex - 1)
                nextIndex = pageArrayFromCache(chapterIndex: currentChapterIndex - 1).count - 1
                let nextPage = getPageVCWith(pageIndex: nextIndex, chapterIndex: currentChapterIndex - 1)
                ///         需要的页面并没有准备好，此时出现页面饥饿
                if nextPage == nil {
                    postReaderStateNotification(state: .busy)
                    pageHunger = true
                    return nil
                } else {
                    backPage.grabViewController(viewController: nextPage!)
                    return backPage
                }
            } else {
                let pageArray = pageArrayFromCache(chapterIndex: currentChapterIndex)
                if nextIndex == pageArray.count / 2 {
                    forwardCacheIfNeed(forward: false)
                }
            }
            backPage.grabViewController(viewController: self.getPageVCWith(pageIndex: nextIndex, chapterIndex: page.chapterBelong)!)
            return backPage
        }
        let back = viewController as! DUABackViewController
        if FirstPage.arrived {
            FirstPage.arrived = false
            return getPageVCWith(pageIndex: back.index, chapterIndex: back.chapterBelong)
        }
        return getPageVCWith(pageIndex: back.index, chapterIndex: back.chapterBelong)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        print("向后翻页")
        struct LastPage {
            static var arrived = false
        }
        let nextIndex: Int
        let pageArray = pageArrayFromCache(chapterIndex: currentChapterIndex)
        if viewController is DUAPageViewController {
            let page = viewController as! DUAPageViewController
            nextIndex = page.index + 1
            if nextIndex == pageArray.count / 2 {
                forwardCacheIfNeed(forward: true)
            }
            if nextIndex == pageArray.count {
                LastPage.arrived = true
            }
            let backPage = DUABackViewController()
            backPage.grabViewController(viewController: page)
            return backPage
        }
        if LastPage.arrived {
            LastPage.arrived = false
            if currentChapterIndex + 1 > totalChapterModels.count {
                return nil
            }
            pageVC?.willStepIntoNextChapter = true
            requestChapterWith(index: currentChapterIndex + 1)
            let nextPage = getPageVCWith(pageIndex: 0, chapterIndex: currentChapterIndex + 1)
            ///         需要的页面并没有准备好，此时出现页面饥饿
            if nextPage == nil {
                postReaderStateNotification(state: .busy)
                pageHunger = true
            }
            return nextPage
        }
        let back = viewController as! DUABackViewController
        return getPageVCWith(pageIndex: back.index + 1, chapterIndex: back.chapterBelong)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        containerController(type: 0, currentController: pageViewController.viewControllers!.first!, didFinishedTransition: completed, previousController: previousViewControllers.first!)
    }
    
    func containerController(type: Int, currentController: UIViewController, didFinishedTransition finished: Bool, previousController: UIViewController) -> Void {
        prePageStartLocation = -1
        let curPage = currentController as! DUAPageViewController
        let previousPage = previousController as! DUAPageViewController
        print("当前页面所在章节 \(curPage.chapterBelong) 先前页面所在章节 \(previousPage.chapterBelong)")
        
        currentPageIndex = curPage.index
        
        var didStepIntoLastChapter = false
        var didStepIntoNextChapter = false
        if type == 0 {
            didStepIntoLastChapter = (pageVC?.willStepIntoLastChapter)! && curPage.chapterBelong < previousPage.chapterBelong
            didStepIntoNextChapter = (pageVC?.willStepIntoNextChapter)! && curPage.chapterBelong > previousPage.chapterBelong
        }else {
            didStepIntoLastChapter = (translationVC?.willStepIntoLastChapter)! && curPage.chapterBelong < previousPage.chapterBelong
            didStepIntoNextChapter = (translationVC?.willStepIntoNextChapter)! && curPage.chapterBelong > previousPage.chapterBelong
        }
        
        if didStepIntoNextChapter {
            print("进入下一章")
            updateChapterIndex(index: currentChapterIndex + 1)
            if type == 0 {
                pageVC?.willStepIntoLastChapter = true
                pageVC?.willStepIntoNextChapter = false
            }else {
                translationVC?.willStepIntoLastChapter = true
                translationVC?.willStepIntoNextChapter = false
            }

        }
        if didStepIntoLastChapter {
            print("进入上一章")
            updateChapterIndex(index: currentChapterIndex - 1)
            if type == 0 {
                pageVC?.willStepIntoNextChapter = true
                pageVC?.willStepIntoLastChapter = false
            } else {
                translationVC?.willStepIntoNextChapter = true
                translationVC?.willStepIntoLastChapter = false
            }
            
        }
        
        if currentPageIndex != 0 {
            if type == 0 {
                pageVC?.willStepIntoLastChapter = false
            } else {
                translationVC?.willStepIntoLastChapter = false
            }
            
        }
        if currentPageIndex != self.pageArrayFromCache(chapterIndex: currentChapterIndex).count - 1 {
            if type == 0 {
                pageVC?.willStepIntoNextChapter = false
            } else {
                translationVC?.willStepIntoNextChapter = false
            }
            
        }
        
        ///     进度信息必要时可以通过delegate回调出去
        print("当前阅读进度 章节 \(currentChapterIndex) 总页数 \(self.pageArrayFromCache(chapterIndex: currentChapterIndex).count) 当前页 \(currentPageIndex + 1)")
        if let delegate = delegate {
            delegate.reader(reader: self, readerProgressUpdated: currentChapterIndex, curPage: currentPageIndex + 1, totalPages: pageArrayFromCache(chapterIndex: currentChapterIndex).count)
        }
    }
    
    
    // MARK:--Table View Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return config.contentFrame.height
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableView!.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: DUATableViewCell? = self.tableView?.dequeueReusableCell(withIdentifier: "dua.reader.cell") as? DUATableViewCell
        if let subviews = cell?.contentView.subviews {
            for item in subviews {
                item.removeFromSuperview()
            }
        }
        if cell == nil {
            cell = DUATableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "dua.reader.cell")
        }
        
        let pageModel = self.tableView?.dataArray[indexPath.row]
        cell?.configCellWith(pageModel: pageModel!, config: config)
        
        return cell!
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if tableView!.isReloading {
            return
        }
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset.y = 0
            // cell index = 0 需要请求上一章
            if tableView?.arrivedZeroOffset == false {
                self.requestLastChapterForTableView()
            }
            tableView?.arrivedZeroOffset = true
        } else {
            tableView?.arrivedZeroOffset = false
        }
        
        let basePoint = CGPoint(x: config.contentFrame.width/2.0, y: scrollView.contentOffset.y + config.contentFrame.height/2.0)
        let majorIndexPath = tableView?.indexPathForRow(at: basePoint)
        
        if majorIndexPath!.row > tableView!.cellIndex { // 向后翻页
            
            prePageStartLocation = -1
            tableView?.cellIndex = majorIndexPath!.row
            currentPageIndex = (self.tableView?.dataArray[tableView!.cellIndex].pageIndex)!
            print("进入下一页 页码 \(currentPageIndex)")
            
            if currentPageIndex == 0 {
                print("跳入下一章，从 \(currentChapterIndex) 到 \(currentChapterIndex + 1)")
                updateChapterIndex(index: currentChapterIndex + 1)
                self.statusBarForTableView?.totalPageCounts = self.pageArrayFromCache(chapterIndex: currentChapterIndex).count
            }
            self.statusBarForTableView?.curPageIndex = currentPageIndex
            
            // 到达本章节最后一页，请求下一章
            if tableView?.cellIndex == (self.tableView?.dataArray.count)! - 1 {
                self.requestNextChapterForTableView()
            }
            
            if self.delegate?.reader(reader: readerProgressUpdated: curPage: totalPages: ) != nil {
                self.delegate?.reader(reader: self, readerProgressUpdated: currentChapterIndex, curPage: currentPageIndex + 1, totalPages: self.pageArrayFromCache(chapterIndex: currentChapterIndex).count)
            }
        }else if majorIndexPath!.row < tableView!.cellIndex {     //向前翻页
            prePageStartLocation = -1
            tableView?.cellIndex = majorIndexPath!.row
            currentPageIndex = (self.tableView?.dataArray[tableView!.cellIndex].pageIndex)!
            print("进入上一页 页码 \(currentPageIndex)")
            
            let previousPageIndex = self.tableView!.dataArray[tableView!.cellIndex + 1].pageIndex
            if currentChapterIndex - 1 > 0 && currentPageIndex == self.pageArrayFromCache(chapterIndex: currentChapterIndex - 1).count - 1 && previousPageIndex == 0 {
                print("跳入上一章，从 \(currentChapterIndex) 到 \(currentChapterIndex - 1)")
                updateChapterIndex(index: currentChapterIndex - 1)
                self.statusBarForTableView?.totalPageCounts = self.pageArrayFromCache(chapterIndex: currentChapterIndex).count

            }
            self.statusBarForTableView?.curPageIndex = currentPageIndex
            
            if self.delegate?.reader(reader: readerProgressUpdated: curPage: totalPages: ) != nil {
                self.delegate?.reader(reader: self, readerProgressUpdated: currentChapterIndex, curPage: currentPageIndex + 1, totalPages: self.pageArrayFromCache(chapterIndex: currentChapterIndex).count)
            }
        }
    }
    
    // MARK: DUATranslationController Delegate
    
    func translationController(translationController: DUAtranslationController, controllerAfter controller: UIViewController) -> UIViewController? {
        print("向后翻页")
        let nextIndex: Int
        var nextPage: DUAPageViewController? = nil
        let pageArray = self.pageArrayFromCache(chapterIndex: currentChapterIndex)
        if controller is DUAPageViewController {
            let page = controller as! DUAPageViewController
            nextIndex = page.index + 1
            if nextIndex == pageArray.count {
                if currentChapterIndex + 1 > totalChapterModels.count {
                    return nil
                }
                translationVC?.willStepIntoNextChapter = true
                self.requestChapterWith(index: currentChapterIndex + 1)
                nextPage = self.getPageVCWith(pageIndex: 0, chapterIndex: currentChapterIndex + 1)
                ///         需要的页面并没有准备好，此时出现页面饥饿
                if nextPage == nil {
                    self.postReaderStateNotification(state: .busy)
                    pageHunger = true
                    return nil
                }
            }else {
                nextPage = self.getPageVCWith(pageIndex: nextIndex, chapterIndex: page.chapterBelong)
            }
        }
        
        return nextPage
    }
    
    func translationController(translationController: DUAtranslationController, controllerBefore controller: UIViewController) -> UIViewController? {
        
        print("向前翻页")
        var nextPage: DUAPageViewController? = nil
        if controller is DUAPageViewController {
            let page = controller as! DUAPageViewController
            var nextIndex = page.index - 1
            if nextIndex < 0 {
                if currentChapterIndex <= 1 {
                    return nil
                }
                self.translationVC?.willStepIntoLastChapter = true
                self.requestChapterWith(index: currentChapterIndex - 1)
                nextIndex = self.pageArrayFromCache(chapterIndex: currentChapterIndex - 1).count - 1
                nextPage = self.getPageVCWith(pageIndex: nextIndex, chapterIndex: currentChapterIndex - 1)
                ///         需要的页面并没有准备好，此时出现页面饥饿
                if nextPage == nil {
                    self.postReaderStateNotification(state: .busy)
                    pageHunger = true
                    return nil
                }
            }else {
                nextPage = self.getPageVCWith(pageIndex: nextIndex, chapterIndex: page.chapterBelong)
            }
        }
        
        return nextPage
    }
    
    func translationController(translationController: DUAtranslationController, willTransitionTo controller: UIViewController) {
        print("willTransitionTo")
    }
    
    func translationController(translationController: DUAtranslationController, didFinishAnimating finished: Bool, previousController: UIViewController, transitionCompleted completed: Bool)
    {
        self.containerController(type: 1, currentController: translationController.children.first!, didFinishedTransition: completed, previousController: previousController)
    }

}

// MARK: - 对外接口

extension DUAReader {
    
    public func readWith(filePath: String, pageIndex: Int, title: String? = nil) -> Void {
        postReaderStateNotification(state: .busy)
        dataParser.parseChapterFromBook(path: filePath, title: title, completeHandler: {(titles, models) -> Void in
            if let delegate = self.delegate {
                delegate.reader(reader: self, chapterTitles: titles)
            }
            self.totalChapterModels = models
            self.readWith(chapter: models.first!, pageIndex: pageIndex)
        })
    }
    
    public func readWith(chapters: [DUAChapterModel], pageIndex: Int = 1, selectedChapterIndex: Int = 0) {
        if chapters.count <= 0 || selectedChapterIndex >= chapters.count {
            return
        }
        postReaderStateNotification(state: .busy)
        let titles = chapters.map{ $0.title ?? "" }
        if let delegate = delegate {
            delegate.reader(reader: self, chapterTitles: titles)
        }
        totalChapterModels = chapters
        readWith(chapter: chapters[selectedChapterIndex], pageIndex: pageIndex)
    }

    public func readChapterBy(index: Int, pageIndex: Int) -> Void {
        if index > 0 && index <= totalChapterModels.count {
            if pageArrayFromCache(chapterIndex: index).isEmpty {
                successSwitchChapter = index
                postReaderStateNotification(state: .busy)
                requestChapterWith(index: index)
            } else {
                successSwitchChapter = 0
                currentPageIndex = pageIndex <= 0 ? 0 : (pageIndex - 1)
                updateChapterIndex(index: index)
                loadPage(pageIndex: currentPageIndex)
                if let delegate = delegate {
                    delegate.reader(reader: self, readerProgressUpdated: currentChapterIndex, curPage: currentPageIndex + 1, totalPages: pageArrayFromCache(chapterIndex: currentChapterIndex).count)
                }
            }
        }
    }
}

// MARK: - 以下为私有方法
private extension DUAReader {
    func readWith(chapter: DUAChapterModel, pageIndex: Int) -> Void {
        
        chapterModels[String(chapter.chapterIndex)] = chapter
        if !Thread.isMainThread {
            self.forwardCacheWith(chapter: chapter)
            return
        }
        
        var pageModels: [DUAPageModel] = [DUAPageModel]()
        if self.isReCutPage {
            self.postReaderStateNotification(state: .busy)
            self.chapterCaches.removeAll()
        }else {
            pageModels = self.pageArrayFromCache(chapterIndex: chapter.chapterIndex)
        }
        if pageModels.isEmpty || self.isReCutPage {
            self.cacheQueue.async {
                if !self.pageArrayFromCache(chapterIndex: chapter.chapterIndex).isEmpty {
                    return
                }
                let attrString = self.dataParser.attributedStringFromChapterModel(chapter: chapter, config: self.config)
                self.dataParser.cutPageWith(attrString: attrString!, config: self.config, completeHandler: {
                    (completedPageCounts, page, completed) -> Void in
                    pageModels.append(page)
                    if completed {
                        self.cachePageArray(pageModels: pageModels, chapterIndex: chapter.chapterIndex)
                        DispatchQueue.main.async {
                            self.processPageArray(pages: pageModels, chapter: chapter, pageIndex: pageIndex)
                        }
                        
                    }
                })
            }
        }
    }
    
    func processPageArray(pages: [DUAPageModel], chapter: DUAChapterModel, pageIndex: Int) -> Void {
        
        self.postReaderStateNotification(state: .ready)
        if pageHunger {
            pageHunger = false
            if pageVC != nil {
                self.loadPage(pageIndex: currentPageIndex)
            }
            if tableView != nil {
                if currentPageIndex == 0 && tableView?.scrollDirection == .up {
                    self.requestLastChapterForTableView()
                }
                if currentPageIndex == self.pageArrayFromCache(chapterIndex: currentChapterIndex).count - 1 && tableView?.scrollDirection == .down {
                    self.requestNextChapterForTableView()
                }
            }
        }
        
        if firstIntoReader {
            firstIntoReader = false
            currentPageIndex = pageIndex <= 0 ? 0 : (pageIndex - 1)
            updateChapterIndex(index: chapter.chapterIndex)
            self.loadPage(pageIndex: currentPageIndex)
            if self.delegate?.reader(reader: readerProgressUpdated: curPage: totalPages: ) != nil {
                self.delegate?.reader(reader: self, readerProgressUpdated: currentChapterIndex, curPage: currentPageIndex + 1, totalPages: self.pageArrayFromCache(chapterIndex: currentChapterIndex).count)
            }
        }
        
        if isReCutPage {
            isReCutPage = false
            var newIndex = 1
            for (index, item) in pages.enumerated() {
                if prePageStartLocation >= (item.range?.location)! && prePageStartLocation <= (item.range?.location)! + (item.range?.length)! {
                    newIndex = index
                }
            }
            currentPageIndex = newIndex
            self.loadPage(pageIndex: currentPageIndex)
            
            /// 触发预缓存
            self.forwardCacheIfNeed(forward: true)
            self.forwardCacheIfNeed(forward: false)
        }
        
        if successSwitchChapter != 0 {
            self.readChapterBy(index: successSwitchChapter, pageIndex: 1)
        }
    }
    
    func postReaderStateNotification(state: DUAReaderState) -> Void {
        DispatchQueue.main.async {
            if self.delegate?.reader(reader: readerStateChanged: ) != nil {
                self.delegate?.reader(reader: self, readerStateChanged: state)
            }
        }
    }
    
    /// 弹出设置菜单
    ///
    /// - Parameter ges: 单击手势
    @objc func pagingTap(ges: UITapGestureRecognizer) -> Void {
        let tapPoint = ges.location(in: self.view)
        let width = UIScreen.main.bounds.size.width
        let rect = CGRect(x: width/3, y: 0, width: width/3, height: UIScreen.main.bounds.size.height)
        if rect.contains(tapPoint) {
            if self.delegate?.readerDidClickSettingFrame(reader:) != nil {
                self.delegate?.readerDidClickSettingFrame(reader: self)
            }
        }
    }
}
