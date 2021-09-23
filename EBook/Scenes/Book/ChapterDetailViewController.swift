//
//  ChapterDetailViewController.swift
//  EBook
//
//  Created by Daniel on 2021/9/13.
//

import UIKit

class ChapterDetailViewController: BaseViewController, BindableType {
    
    static let kTopMenuHeight: CGFloat = (App.isModelX ? 80 : 64)
    static let kBottomMenuHeight: CGFloat = 160
    
    var viewModel: ChapterDetailViewModelType!
    private var msettingView = UIView()
    private var sideBar: UIView?
    private var curPage = 0
    private var curChapter = 0
    private var lastChapter = CatalogModel(0)
    private var curChapterTotalPages = 0
    private var reader: DUAReader!
    private var statusBarHidden = true
    
    private lazy var loadingHud: MBProgressHUD = {
        let hud = MBProgressHUD.showLoadingHud(at: view)
        return hud
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch UserinterfaceManager.shared.interfaceStyle {
        case .dark, .system:
            return .lightContent
        default:
            return .darkContent
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
        printLog("====currentChapterIndex:\(lastChapter.index)!!!!!!!!!");
        if curChapter != lastChapter.index {
            viewModel.input.loadNewChapter(withIndex: lastChapter.index)
        }
    }
    
    func bindViewModel() {
        let output = viewModel.output
        let input = viewModel.input        
        rx.disposeBag ~ [
            output.loading ~> loadingHud.rx.animation,
            output.chapterList.subscribe(onNext: { [weak self] chapters, idx, pageIndex in
                guard let `self` = self else { return }
                self.reader.readWith(chapters: chapters, selectedChapterIndex:idx, pageIndex: pageIndex)
            }),
            output.updatedChapters.subscribe(onNext: { [weak self] chapters in
                guard let `self` = self else { return }
                if chapters.count > 0 {
                    self.reader.updateTotalChapters(chapters)
                }
            }),
            NotificationCenter.default.rx.notification(SPNotification.interfaceChanged.name).subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.reader.config.backgroundImage = R.color.windowBgColor()?.toImage()
                switch UserinterfaceManager.shared.interfaceStyle {
                case .light, .system:
                    self.reader.config.textColor = R.color.b1e3c()!
                    self.reader.config.titleColor = .black
                default:
                    self.reader.config.textColor = UIColor(hexString: "#E0E0E0")!
                    self.reader.config.titleColor = UIColor(hexString: "#E0E0E0")!
                }
            })
        ]
    }


}

// MARK: - DUAReaderDelegate

extension ChapterDetailViewController: DUAReaderDelegate {
    
    func readerDidClickSettingFrame(reader: DUAReader) {

        let topMenu = ReaderTopMenu(frame: CGRect(x: 0, y: -ChapterDetailViewController.kTopMenuHeight, width: self.view.width, height: ChapterDetailViewController.kTopMenuHeight))
        let bottomMenu = ReaderBottomMenu(frame: CGRect(x: 0, y: view.height, width: view.width, height: ChapterDetailViewController.kBottomMenuHeight))
        let window: UIWindow = SceneCoordinator.shared.window
        let baseView = UIView(frame: window.bounds)
        window.addSubview(baseView)
        baseView.addSubview(topMenu)
        baseView.addSubview(bottomMenu)
        
        UIView.animate(withDuration: 0.2, animations: {() in
            self.statusBarHidden = false
            topMenu.frame = CGRect(x: 0, y: 0, width: self.view.width, height: ChapterDetailViewController.kTopMenuHeight)
            bottomMenu.frame = CGRect(x: 0, y: self.view.height - ChapterDetailViewController.kBottomMenuHeight, width: self.view.width, height: ChapterDetailViewController.kBottomMenuHeight)
            self.setNeedsStatusBarAppearanceUpdate()
        })

//        添加手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(onSettingViewClicked))
        baseView.addGestureRecognizer(tap)
        msettingView = baseView
        
//        给设置面板所有button添加点击事件
        for view in topMenu.subviews.first!.subviews {
            if view is UIButton {
                let button = view as! UIButton
                button.addTarget(self, action: #selector(onSettingItemClicked), for: .touchUpInside)
            }
        }
        for view in bottomMenu.subviews {
            if view is UIButton {
                let button = view as! UIButton
                if button.tag == 204 {
                    switch UserinterfaceManager.shared.interfaceStyle {
                    case .dark:
                        button.isSelected = true
                    case .light:
                        button.isSelected = false
                    default:
                        break
                    }
                }
                button.addTarget(self, action: #selector(onSettingItemClicked), for: .touchUpInside)
            }
            if view is UISlider {
                let slider = view as! UISlider
                slider.value = Float(curPage) / Float(curChapterTotalPages)
                slider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)
            }
        }
    }
    
    func reader(reader: DUAReader, readerStateChanged state: DUAReaderState) {
        viewModel.input.readerStateChanged(state)
    }
    
    func reader(reader: DUAReader, readerProgressUpdated curChapter: Int, curPage: Int, totalPages: Int) {
        self.curPage = curPage
        self.curChapter = curChapter
        self.curChapterTotalPages = totalPages
        viewModel.input.readerProgressUpdate(curChapter: curChapter, curPage: curPage, totalPages: totalPages)
    }
    
}

// MARK: - ResponseEvent

private extension ChapterDetailViewController {
    
    @objc func onSettingViewClicked() {
        let topMenu: UIView = msettingView.subviews.first!
        let bottomMenu: UIView = msettingView.subviews.last!
        UIView.animate(withDuration: 0.2, animations: {() in
            self.statusBarHidden = true
            topMenu.frame = CGRect(x: 0, y: -ChapterDetailViewController.kTopMenuHeight, width: self.view.width, height: ChapterDetailViewController.kTopMenuHeight)
            bottomMenu.frame = CGRect(x: 0, y: self.view.height, width: self.view.width, height: ChapterDetailViewController.kBottomMenuHeight)
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: {(complete) in
            if complete {
                self.msettingView.removeFromSuperview()
            }
        })
    }
    
    @objc func sliderValueChanged(sender: UISlider) -> Void {
        let index = floor(Float(curChapterTotalPages) * sender.value)
        reader.readChapterBy(index: curChapter, pageIndex: Int(index))
    }
    
    @objc func onSettingItemClicked(_ sender: UIButton) {
        switch sender.tag {
//            上菜单
        case 100:
            printLog("退出阅读器")
//            navigationController?.popViewController(animated: true)
            viewModel.input.backAction.execute()
            reader = nil
            msettingView.removeFromSuperview()
        case 101:
            printLog("上部更多")
//            self.saveBookMarks(button: button)
            
//            下菜单
        case 200:
            reader.readChapterBy(index: curChapter - 1, pageIndex: 1)
        case 201:
            reader.readChapterBy(index: curChapter + 1, pageIndex: 1)
        case 202:
            let catalog = CatalogModel(curChapter)
            viewModel.input.showCatalog(catalog)
            lastChapter = catalog
            msettingView.removeFromSuperview()
//            reader.config.scrollType = .curl
        case 203:
            printLog("翻页动画")
//            reader.config.scrollType = .horizontal
        case 204:
            printLog("夜间模式")
            sender.isSelected = !sender.isSelected
            setNeedsStatusBarAppearanceUpdate()
            self.view.layoutIfNeeded()
            viewModel.input.userInterfaceChanged(sender.isSelected)
//            reader.config.scrollType = .vertical
        case 205:
            printLog("字体设置")
//            reader.config.scrollType = .none
//        case 206:
//            print("设置背景1")
//            reader.config.backgroundImage = UIImage.init(named: "backImg.jpg")
//        case 207:
//            print("设置背景2")
//            reader.config.backgroundImage = UIImage.init(named: "backImg1.jpg")
//        case 208:
//            print("设置背景3")
//            reader.config.backgroundImage = UIImage.init(named: "backImg2.jpg")
//        case 209:
//            print("展示章节目录")
////            self.showSideBar()
//        case 210:
//            print("调小字号")
//            reader.config.fontSize -= 1
//        case 211:
//            print("调大字号")
//            reader.config.fontSize += 1
        default:
            print("nothing")
        }
    }
}

// MARK: - Init

private extension ChapterDetailViewController {
    func setup() {
        navigationBar.isHidden = true
        reader = DUAReader()
        let configuration = DUAConfiguration()
        configuration.backgroundImage = R.color.windowBgColor()?.toImage()
        switch UserinterfaceManager.shared.interfaceStyle {
        case .light, .system:
            configuration.textColor = R.color.b1e3c()!
            configuration.titleColor = .black
        default:
            configuration.textColor = UIColor(hexString: "#E0E0E0")!
            configuration.titleColor = UIColor(hexString: "#E0E0E0")!
        }
        reader.config = configuration
        reader.delegate = self
        view.addSubview(reader.view)
        reader.view.snp.makeConstraints { $0.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))  }
    }
}
