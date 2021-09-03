//
//  BaseViewController.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/22.
//

import UIKit
import Action
import RxSwift
import RxCocoa
@_exported import RxBinding
@_exported import SnapKit
@_exported import NSObject_Rx

class BaseViewController: UIViewController {
    
    var navigationBar: NavigationBar {
        get {
            return _navigationBar
        }
    }
    
    private lazy var _navigationBar: NavigationBar = {
        let bar = NavigationBar(frame: CGRect(x: 0, y: 0, width: App.screenWidth, height: App.naviBarHeight))
        bar.backgroundView.backgroundColor = R.color.windowBgColor()
        bar.titleLabel?.textColor = R.color.b1e3c()
        bar.bottomBorderColor = R.color.e8e8e8()
        return bar
    }()
    
    fileprivate lazy var backBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        btn.imageEdgeInsets = .zero
        btn.setImage(R.image.nav_back(), for: .normal)
        btn.setImage(R.image.nav_back(), for: .highlighted)
        btn.isExclusiveTouch = true
        btn.contentHorizontalAlignment = .center
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return btn
    }()
    
//    fileprivate lazy var rightBtn: UIButton = {
//        let btn = UIButton(type: .custom)
//        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
//        btn.imageEdgeInsets = .zero
//        btn.setImage(R.image.nav_back(), for: .normal)
//        btn.setImage(R.image.nav_back(), for: .highlighted)
//        btn.isExclusiveTouch = true
//        btn.contentHorizontalAlignment = .center
//        return btn
//    }()
    
    private var isCustomNavBarSetted = false
#if DEBUG
    deinit {
        printLog("====qd====dealloc===\(self)")
    }
#endif

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarLeft()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.isNavigationBarHidden = true
    }
}

// MARK: - ResponseEvent

private extension BaseViewController {
    @objc
    func backAction(_ sender: UIButton) {
        guard let _ = sender.rx.action else {
            if let navigationController = navigationController {
                navigationController.popViewController(animated: true)
            } else if let _ = presentingViewController {
                dismiss(animated: true, completion: nil)
            }
            return
        }
    }
}

// MARK: - Private method

private extension BaseViewController {
    
    func setup() {
        edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        extendedLayoutIncludesOpaqueBars = false
        view.backgroundColor = R.color.windowBgColor()
        view.addSubview(_navigationBar)
    }
    
    func setupNavigationBarLeft() {
        if !isCustomNavBarSetted {
            if let navigationController = navigationController, navigationController.viewControllers.count > 1 {
                _navigationBar.leftBarView = backBtn
            }
            isCustomNavBarSetted = true
        }
    }
    
}


extension Reactive where Base: BaseViewController {
    var backAction: CocoaAction? {
        get {
            return base.backBtn.rx.action
        }
        
        set {
            base.backBtn.rx.action = newValue
        }
    }
    
    var backImage: Binder<UIImage?> {
        return Binder(base) { view, image in
            if let image = image {
                view.backBtn.setImage(image, for: .normal)
                view.backBtn.setImage(image, for: .highlighted)
            } else {
                view.navigationBar.leftBarView = nil
            }
            
        }
    }
}
