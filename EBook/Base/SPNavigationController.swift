//
//  SPNavigationController.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/22.
//

import UIKit

class SPNavigationController: UINavigationController {

    private var shouldIgnorePushingViewControllers: Bool = false
    
    override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
    }
    
    fileprivate func configureNavBar() {
        navigationBar.setBackgroundImage(UIColor.white.toImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.mediumFont(ofSize: 17)]
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if !shouldIgnorePushingViewControllers {
            if children.count > 0 {
                viewController.hidesBottomBarWhenPushed = true
            }
            super.pushViewController(viewController, animated: animated)
            shouldIgnorePushingViewControllers = true
        }
    }
    
    override func didShowViewController(_ viewController: UIViewController, animated: Bool) {
        super.didShowViewController(viewController, animated: animated)
        shouldIgnorePushingViewControllers = false
    }

}

extension UINavigationController {
    @objc func didShowViewController(_ viewController: UIViewController, animated: Bool) {}

}
