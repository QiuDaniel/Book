//
//  SceneCoordinator.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/19.
//

import UIKit
import RxSwift
import RxCocoa
import DQPopup

class SceneCoordinator: NSObject, SceneCoordinatorType {
    static var shared: SceneCoordinator!
    
    private (set) var window: UIWindow
    private (set) var currentController: UIViewController! {
        didSet {
            currentController.navigationController?.delegate = self
            currentController.tabBarController?.delegate = self
        }
    }
    
    required init(window: UIWindow) {
        self.window = window
//        currentController = window.rootViewController
    }
    
    static func actualViewController(for viewController: UIViewController) -> UIViewController {
        var controller = viewController
        if let tabBarController = controller as? UITabBarController {
            guard let selectedViewController = tabBarController.selectedViewController else {
                return tabBarController
            }
            controller = actualViewController(for: selectedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController {
            guard let lastController = navigationController.viewControllers.last else { return navigationController }
            controller = lastController
        }
        
        return controller
    }
    
    @discardableResult
    func transition(to scene: TargetScene) -> Observable<Void> {
        let subject = PublishSubject<Void>()
        
        switch scene.transition {
        case let .tabBar(tabBarController):
            guard let selectedViewController = tabBarController.selectedViewController else { fatalError("SelectedViewController doesn't exists") }
            currentController = SceneCoordinator.actualViewController(for: selectedViewController)
            let anim = CATransition()
            anim.type = .fade
            anim.duration = 0.5
            window.rootViewController = tabBarController
            window.layer.add(anim, forKey: nil)
            window.makeKeyAndVisible()
            subject.onCompleted()
            
        case let .root(viewController):
            currentController = SceneCoordinator.actualViewController(for: viewController)
            animateRoot(window, controller: viewController)
            subject.onCompleted()
            
        case let .guide(viewController):
            currentController = SceneCoordinator.actualViewController(for: viewController)
            let anim = CATransition()
            anim.type = .fade
            anim.duration = 0.5
            window.rootViewController = viewController
            window.layer.add(anim, forKey: nil)
            window.makeKeyAndVisible()
            subject.onCompleted()
            
        case let .push(viewController, animated):
            var navigationController: UINavigationController
            if currentController.isKind(of: UINavigationController.self) {
                navigationController = currentController as! UINavigationController
            } else {
                guard let navigation = currentController.navigationController else {
                    fatalError("Can't push a viewcontroller without a current navigationcontroller")
                }
                navigationController = navigation
            }
            _ = navigationController.rx.delegate.sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:))).take(1)
                .ignoreAll()
                .bind(to: subject)
            navigationController.pushViewController(viewController, animated: animated)
            subject.onCompleted()
        case let .present(viewController):
            
            currentController.present(viewController, animated: true) {
                subject.onCompleted()
            }
            currentController = SceneCoordinator.actualViewController(for: viewController)
            if let navigationControler = currentController.navigationController {
                navigationControler.presentationController?.delegate = self
            } else {
                currentController.presentationController?.delegate = self
            }
        case let .alert(viewController):
            currentController.present(viewController, animated: true) {
                subject.onCompleted()
            }
        case .show(let view, let style):
            var animation: DQPopupAnimationType
            switch style {
            case .drop:
                animation = DQPopupAnimationDrop()
            case .fade:
                animation = DQPopupAnimationFade()
            case .spring:
                animation = DQPopupAnimationSpring()
            case .slide:
                animation = DQPopupAnimationSlide(style: .bottombottom)
            }
            currentController.dq.present(view, animation: animation)
            subject.onCompleted()
        }
        return subject.asObserver().take(1)
    }
    
    @discardableResult
    func hide() -> Observable<Void> {
        let subject = PublishSubject<Void>()
        currentController.dq.dismiss()
        subject.onCompleted()
        return subject.asObservable().take(1).ignoreAll()
    }
    
    @discardableResult
    func hide(completion: @escaping (() -> Void)) -> Observable<Void> {
        let subject = PublishSubject<Void>()
        currentController.dq.dismiss {
            completion()
            subject.onCompleted()
        }
        return subject.asObservable().take(1).ignoreAll()
    }
    
    @discardableResult
    func pop(animated: Bool) -> Observable<Void> {
        
        let subject = PublishSubject<Void>()
        var navigationController: UINavigationController
        if currentController.isKind(of: UINavigationController.self) {
            navigationController = currentController as! UINavigationController
        } else {
            guard let navigation = currentController.navigationController else {
                fatalError("Can't push a viewcontroller without a current navigationcontroller")
            }
            navigationController = navigation
        }
        _ = navigationController.rx.delegate.sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:))).take(1).ignoreAll().bind(to: subject)
        guard navigationController.popViewController(animated: animated) != nil else {
            fatalError("cann't navigate back from \(String(describing: currentController))")
        }
        currentController = SceneCoordinator.actualViewController(for: navigationController.viewControllers.last!)
        subject.onCompleted()
        return subject.asObservable().take(1).ignoreAll()
        /*
        
        var isDisposed = false
        let source = Observable<Void>.create { [unowned self] observer in
            if let navigationController = self.currentController.navigationController {
                _ = navigationController.rx.delegate.sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:))).ignoreAll().bind(to: observer)
            }
            return Disposables.create {
                isDisposed = true
            }
        }
        
        if let navigationController = currentController.navigationController {
            guard navigationController.popViewController(animated: animated) != nil else {
                fatalError("cann't navigate back from \(currentController)")
            }
            
            if !isDisposed {
                currentController = SceneCoordinator.actualViewController(for: navigationController.viewControllers.last!)
            }
        } else {
            fatalError("no navigationcontroller: cann't navigate back from \(currentController)")
        }
        
        return source.take(1).ignoreAll()
        */
    }
    
    @discardableResult
    func pop(to viewController: AnyClass, animated: Bool = true) -> Observable<Void> {
        var isDisposed = false
        let source = Observable<Void>.create { observer in
            if viewController != UIViewController.self {
                return Disposables.create {
                    isDisposed = true
                }
            }
            if let navigationController = self.currentController.navigationController {
                _ = navigationController
                    .rx
                    .delegate
                    .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                    .ignoreAll()
                    .bind(to: observer)
            }
            return Disposables.create {
                isDisposed = true
            }
        }
        

        if let navigationController = currentController.navigationController {
            navigationController.viewControllers.forEach { vc in
                if vc.isKind(of: viewController) {
                    guard navigationController.popToViewController(vc, animated: animated) != nil else {
                        fatalError("cann't navigate back from \(String(describing: currentController))")
                    }
                    
                    if !isDisposed {
                        currentController = SceneCoordinator.actualViewController(for: navigationController.viewControllers.last!)
                    }
                    return
                }
            }
        } else {
            fatalError("no navigation controller: cann't navigate back from \(String(describing: currentController))")
        }
        return source
            .take(1)
            .ignoreAll()
        
    }
    
    @discardableResult
    func dismiss(animated: Bool) -> Observable<Void> {
        var isDisposed = false
        var currentObserver: AnyObserver<Void>?
        let source = Observable<Void>.create { observer in
            currentObserver = observer
            return Disposables.create {
                isDisposed = true
            }
        }
        if let navigationControler = currentController.navigationController {
            navigationControler.presentationController?.delegate = nil
        } else {
            currentController.presentationController?.delegate = nil
        }
        if let presentingViewController = currentController.presentingViewController {
            currentController.dismiss(animated: animated) {
                if !isDisposed {
                    
                    self.currentController = SceneCoordinator.actualViewController(for: presentingViewController)
                    currentObserver?.on(.completed)
                }
            }
        } else {
            
            fatalError("Not a modal, no navigation controller: cann't navigate back from \(String(describing: currentController))")
        }
        
        return source.take(1).ignoreAll()
    }
    
    @discardableResult
    func dismiss(animated: Bool, completion: @escaping (() -> Void)) -> Observable<Void> {
        var isDisposed = false
        var currentObserver: AnyObserver<Void>?
        let source = Observable<Void>.create { observer in
            currentObserver = observer
            return Disposables.create {
                isDisposed = true
            }
        }
        if let navigationControler = currentController.navigationController {
            navigationControler.presentationController?.delegate = nil
        } else {
            currentController.presentationController?.delegate = nil
        }
        if let presentingViewController = currentController.presentingViewController {
            currentController.dismiss(animated: animated) {
                if !isDisposed {
                    self.currentController = SceneCoordinator.actualViewController(for: presentingViewController)
                    completion()
                    currentObserver?.on(.completed)
                }
            }
        } else {
            fatalError("Not a modal, no navigation controller: cann't navigate back from \(String(describing: currentController))")
        }
        return source.take(1).ignoreAll()
    }
    
    @discardableResult
    func tabBarSelected(_ index: Int) -> Observable<Void> {
        let subject = PublishSubject<Void>()
        if let tabBarController = window.rootViewController as? SPTabBarController {
            tabBarController.selectedIndex = index
        } else {
            currentController.tabBarController?.selectedIndex = index
        }
        subject.onCompleted()
        return subject.asObservable().take(1).ignoreAll()
    }
    
    @discardableResult
    func resetTabBar(language: Bool, insertController: UIViewController?) -> Observable<Void> {
        let subject = PublishSubject<Void>()
        if language {
            if let tabBarController = window.rootViewController as? SPTabBarController {
                tabBarController.setupViews()
                window.makeKeyAndVisible()
                if let nav = tabBarController.selectedViewController as? SPNavigationController, let insertController = insertController {
                    var viewContrllers = nav.viewControllers
                    let set = viewContrllers.first
                    set?.loadViewIfNeeded()
                    viewContrllers.append(insertController)
                    nav.viewControllers = viewContrllers
                    currentController = SceneCoordinator.actualViewController(for: nav)
                }
            }
        }
        
        subject.onCompleted()
        return subject.asObservable().take(1).ignoreAll()
    }
    
}

extension SceneCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        currentController = SceneCoordinator.actualViewController(for: viewController)
    }
    
}

extension SceneCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        currentController = SceneCoordinator.actualViewController(for: viewController)
    }
}

/*
 https://medium.com/%E5%BD%BC%E5%BE%97%E6%BD%98%E7%9A%84-swift-ios-app-%E9%96%8B%E7%99%BC%E5%95%8F%E9%A1%8C%E8%A7%A3%E7%AD%94%E9%9B%86/ios-13-%E7%9A%84-present-modally-%E8%AE%8A%E6%88%90%E6%9B%B4%E6%96%B9%E4%BE%BF%E7%9A%84%E5%8D%A1%E7%89%87%E8%A8%AD%E8%A8%88-fb6b31f0e20e
https://developer.apple.com/documentation/uikit/view_controllers/disabling_pulling_down_a_sheet
 
 fixed iOS13 presentedController closed by guesture
*/
extension SceneCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        NotificationCenter.default.post(name: SPNotification.dragDismiss.name, object: nil)
        currentController = SceneCoordinator.actualViewController(for: presentationController.presentingViewController)
        
    }
}

private extension SceneCoordinator {
    func animateRoot(_ window: UIWindow, controller: UIViewController) {
        let anim = CATransition()
        anim.type = .fade
        anim.duration = 0.5
        window.rootViewController = controller
        window.layer.add(anim, forKey: nil)
        window.makeKeyAndVisible()
    }
}
