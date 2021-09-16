//
//  ChapterDetailViewController.swift
//  EBook
//
//  Created by Daniel on 2021/9/13.
//

import UIKit

class ChapterDetailViewController: BaseViewController, BindableType {
    
    var viewModel: ChapterDetailViewModelType!
    private var msettingView = UIView()
    private var sideBar: UIView?
    private var curPage = 0
    private var curChapter = 0
    private var curChapterTotalPages = 0
    private var reader: DUAReader!
    private var statusBarHidden = true
    private var statusBarStyle = UIStatusBarStyle.darkContent
    
    private lazy var loadingHud: MBProgressHUD = {
        let hud = MBProgressHUD.showLoadingHud(at: view)
        return hud
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
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
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.loading ~> loadingHud.rx.animation,
            output.chapterList.subscribe(onNext: { [weak self] chapters, idx in
                guard let `self` = self else { return }
                self.reader.readWith(chapters: chapters, selectedChapterIndex:idx)
            })
        ]
    }


}

// MARK: - DUAReaderDelegate

extension ChapterDetailViewController: DUAReaderDelegate {
    
    func readerDidClickSettingFrame(reader: DUAReader) {

        let topMenu = ReaderTopMenu(frame: CGRect(x: 0, y: -80, width: self.view.width, height: 80))
        let bottomMenuNibViews = Bundle.main.loadNibNamed("bottomMenu", owner: nil, options: nil)
        let bottomMenu = bottomMenuNibViews?.first as? UIView
        bottomMenu?.frame = CGRect(x: 0, y: self.view.height, width: self.view.width, height: 200)
        let window: UIWindow = ((UIApplication.shared.delegate?.window)!)!
        let baseView = UIView(frame: window.bounds)
        window.addSubview(baseView)
        baseView.addSubview(topMenu)
        baseView.addSubview(bottomMenu!)
        
        UIView.animate(withDuration: 0.2, animations: {() in
            self.statusBarHidden = false
            topMenu.frame = CGRect(x: 0, y: 0, width: self.view.width, height: 80)
            bottomMenu?.frame = CGRect(x: 0, y: self.view.height - 200, width: self.view.width, height: 200)
            self.setNeedsStatusBarAppearanceUpdate()
        })

//        添加手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(onSettingViewClicked(ges:)))
        baseView.addGestureRecognizer(tap)
        msettingView = baseView
        
//        给设置面板所有button添加点击事件
        for view in topMenu.subviews.first!.subviews {
            if view is UIButton {
                let button = view as! UIButton
                button.addTarget(self, action: #selector(onSettingItemClicked(button:)), for: .touchUpInside)
            }
        }
        for view in bottomMenu!.subviews.first!.subviews {
            if view is UIButton {
                let button = view as! UIButton
                button.addTarget(self, action: #selector(onSettingItemClicked(button:)), for: .touchUpInside)
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
    @objc func onSettingViewClicked(ges: UITapGestureRecognizer) {
        let topMenu: UIView = msettingView.subviews.first!
        let bottomMenu: UIView = msettingView.subviews.last!
        UIView.animate(withDuration: 0.2, animations: {() in
            self.statusBarHidden = true
            topMenu.frame = CGRect(x: 0, y: -80, width: self.view.width, height: 80)
            bottomMenu.frame = CGRect(x: 0, y: self.view.height, width: self.view.width, height: 200)
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
    
    @objc func onSettingItemClicked(button: UIButton) {
        switch button.tag {
//            上菜单
        case 100:
            print("退出阅读器")
            navigationController?.popViewController(animated: true)
            reader = nil
            msettingView.removeFromSuperview()
        case 101:
            print("书签")
//            self.saveBookMarks(button: button)
            
//            下菜单
        case 200:
            print("切换上一章")
            reader.readChapterBy(index: curChapter - 1, pageIndex: 1)
        case 201:
            print("切换下一章")
            reader.readChapterBy(index: curChapter + 1, pageIndex: 1)
        case 202:
            print("仿真翻页")
            reader.config.scrollType = .curl
        case 203:
            print("平移翻页")
            reader.config.scrollType = .horizontal
        case 204:
            print("竖向滚动翻页")
            reader.config.scrollType = .vertical
        case 205:
            print("无动画翻页")
            reader.config.scrollType = .none
        case 206:
            print("设置背景1")
            reader.config.backgroundImage = UIImage.init(named: "backImg.jpg")
        case 207:
            print("设置背景2")
            reader.config.backgroundImage = UIImage.init(named: "backImg1.jpg")
        case 208:
            print("设置背景3")
            reader.config.backgroundImage = UIImage.init(named: "backImg2.jpg")
        case 209:
            print("展示章节目录")
//            self.showSideBar()
        case 210:
            print("调小字号")
            reader.config.fontSize -= 1
        case 211:
            print("调大字号")
            reader.config.fontSize += 1
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
        configuration.textColor = R.color.b1e3c()!
        reader.config = configuration
        reader.delegate = self
        view.addSubview(reader.view)
        reader.view.snp.makeConstraints { $0.edges.equalTo(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))  }
    }
}
