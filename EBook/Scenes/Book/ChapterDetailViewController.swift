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
    static let kFilpMenuHeight: CGFloat = 244
    
    var viewModel: ChapterDetailViewModelType!
    private var msettingView = UIView()
    private weak var readerFilpView: ReaderFlipMenu!
    private var sideBar: UIView?
    private var curPage = 0
    private var curChapter = 0
    private var totalChapters = 0
    private var lastChapter = CatalogModel(0)
    private var curChapterTotalPages = 0
    private var reader: DUAReader!
    private var statusBarHidden = true
    private var debouncer: Debouncer? = nil

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
        if curChapter != lastChapter.index {
            viewModel.input.loadNewChapter(withIndex: lastChapter.index)
        }
    }
    
    func bindViewModel() {
        let output = viewModel.output
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
                    self.reader.config.textColor = UIColor(hexString: "#0B1E3C")!
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
        let flipMenu = ReaderFlipMenu(frame: CGRect(x: 0, y: view.height - ChapterDetailViewController.kFilpMenuHeight, width: view.width, height: ChapterDetailViewController.kFilpMenuHeight))
        flipMenu.isHidden = true
        flipMenu.delegate = self
        readerFilpView = flipMenu
        let window: UIWindow = SceneCoordinator.shared.window
        let baseView = UIView(frame: window.bounds)
        window.addSubview(baseView)
        baseView.addSubview(topMenu)
        baseView.addSubview(flipMenu)
        baseView.addSubview(bottomMenu)
        
        
        UIView.animate(withDuration: 0.2, animations: { () in
            self.statusBarHidden = false
            topMenu.frame = CGRect(x: 0, y: 0, width: self.view.width, height: ChapterDetailViewController.kTopMenuHeight)
            bottomMenu.frame = CGRect(x: 0, y: self.view.height - ChapterDetailViewController.kBottomMenuHeight, width: self.view.width, height: ChapterDetailViewController.kBottomMenuHeight)
            self.setNeedsStatusBarAppearanceUpdate()
        })

//        添加手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(onSettingViewClicked))
        tap.delegate = self
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
                slider.value = Float(curChapter + 1) / Float(totalChapters)
                slider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)
            }
        }
    }
    
    func reader(reader: DUAReader, readerStateChanged state: DUAReaderState) {
        viewModel.input.readerStateChanged(state)
    }
    
    func reader(reader: DUAReader, readerProgressUpdated curChapter: Int, totalChapters: Int, curPage: Int, totalPages: Int) {
        if curChapter != self.curChapter {
            lastChapter = CatalogModel(curChapter)
        }
        self.curChapter = curChapter
        self.totalChapters = totalChapters
        self.curPage = curPage
        self.curChapterTotalPages = totalPages
        viewModel.input.readerProgressUpdate(curChapter: curChapter, curPage: curPage)
    }
    
    func readler(reader: DUAReader, chapterNeedUpdate chapter: DUAChapterModel) {
        viewModel.input.loadNewChapter(withIndex: chapter.chapterIndex)
    }
    
}

extension ChapterDetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        var view = touch.view
        while view != nil {
            if view!.isKind(of: UITableView.self) {
                return false
            } else {
                view = view!.superview
            }
        }
        return true
    }
}

extension ChapterDetailViewController: ReaderFlipMenuDelegate {
    
    func clickBack(_ sender: UIButton) {
        let bottomMenu: UIView = msettingView.subviews.last!
        bottomMenu.isHidden = false
        readerFilpView.isHidden = true
    }
    
    func menu(_ menu: ReaderFlipMenu, selectedAt index: Int) {
        if let scrollType = DUAReaderScrollType(rawValue: index) {
            AppStorage.shared.setObject(index, forKey: .readerScrollType)
            AppStorage.shared.synchronous()
            reader.config.scrollType = scrollType
        }
        
    }
}

// MARK: - ResponseEvent

private extension ChapterDetailViewController {
    
    @objc func onSettingViewClicked(_ tap: UITapGestureRecognizer) {
        let topMenu: UIView = msettingView.subviews.first!
        let bottomMenu: UIView = msettingView.subviews.last!
        UIView.animate(withDuration: 0.2, animations: { () in
            self.statusBarHidden = true
            topMenu.frame = CGRect(x: 0, y: -ChapterDetailViewController.kTopMenuHeight, width: self.view.width, height: ChapterDetailViewController.kTopMenuHeight)
            if !bottomMenu.isHidden {
                bottomMenu.frame = CGRect(x: 0, y: self.view.height, width: self.view.width, height: ChapterDetailViewController.kBottomMenuHeight)
            } else if !self.readerFilpView.isHidden {
                self.readerFilpView.frame = CGRect(x: 0, y: self.view.height, width: self.view.width, height: ChapterDetailViewController.kFilpMenuHeight)
            }
            
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: {(complete) in
            if complete {
                self.msettingView.removeFromSuperview()
            }
        })
    }
    
    @objc func sliderValueChanged(sender: UISlider) -> Void {
        debouncer?.call { [weak self] in
            guard let `self` = self else { return }
            dispatch_async_safely_to_main_queue {
                var index = Int(floor(Float(self.totalChapters - 1) * sender.value))
                printLog("slider index:\(index)")
                if index >= self.totalChapters {
                    index = self.totalChapters - 1
                }
                self.reader.readChapterBy(index: index, pageIndex: 1)
            }
        }
    }
    
    @objc func onSettingItemClicked(_ sender: UIButton) {
        switch sender.tag {
//            上菜单
        case 100:
            printLog("退出阅读器")
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
        case 203:
            printLog("翻页动画")
            let bottomMenu: UIView = msettingView.subviews.last!
            bottomMenu.isHidden = true
            readerFilpView.isHidden = false
        case 204:
            sender.isSelected = !sender.isSelected
            setNeedsStatusBarAppearanceUpdate()
            self.view.layoutIfNeeded()
            viewModel.input.userInterfaceChanged(sender.isSelected)
        case 205:
            printLog("字体设置")
        default:
            print("nothing")
        }
    }
}

// MARK: - Init

private extension ChapterDetailViewController {
    func setup() {
        debouncer = Debouncer(label: "ChapterDetail", interval: 1.0)
        navigationBar.isHidden = true
        reader = DUAReader()
        let configuration = DUAConfiguration()
        configuration.backgroundImage = R.color.windowBgColor()?.toImage()
        configuration.scrollType = AppManager.shared.scrollType
        switch UserinterfaceManager.shared.interfaceStyle {
        case .light, .system:
            configuration.textColor = UIColor(hexString: "#0B1E3C")!
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
