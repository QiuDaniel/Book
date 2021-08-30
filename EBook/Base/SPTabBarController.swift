//
//  SPTabBarController.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/22.
//

import UIKit

class SPTabBarController: UITabBarController {

    private var indexFlag = 0
    
//    override var selectedIndex: Int {
//        get {
//            return super.selectedIndex
//        }
//        set {
//            if newValue < 0 || newValue >= self.viewControllers!.count {
//                return
//            }
//            super.selectedIndex = newValue
//            AppStorage.shared.setObject(newValue, forKey: .tabSelected)
//            AppStorage.shared.synchronous()
//        }
//    }
    
    private var titles: [String] {
        return ["书架", "书城", "分类", "设置"]
    }
    
    private var tabBarImages: [UIImage?] {
        return [R.image.tab_data(), R.image.tab_worker(), R.image.tab_pool(), R.image.tab_settings()]
    }
    
    private var tabBarSelectedImages: [UIImage?] {
        return [R.image.tab_data_sl(), R.image.tab_worker_sl(), R.image.tab_pool_sl(), R.image.tab_settings_sl()]
    }
    
    private let url: String?
    
    deinit {
        printLog("===qd===dealloc===\(self)")
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return selectedViewController
    }
    
    init(url: String?) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTabbar()
        setupViews()
    }
}

extension SPTabBarController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item) else { return }
        if index != indexFlag {
            itemAnimatioin(with: index)
        }
        indexFlag = index
//        AppStorage.shared.setObject(index, forKey: .tabSelected)
//        AppStorage.shared.synchronous()
    }
}

extension SPTabBarController {
    func setupViews() {
        indexFlag = 1
        var controllers:[SPNavigationController] = []
        for (idx, title) in titles.enumerated()  {
            var vc = BaseViewController()
            switch idx {
            case 0:
                var bookCity = BookCaseViewController()
//                minerVC.bind(to: MinerViewModel())
                vc = bookCity
            case 1:
                vc = BookCityViewController()
            case 2:
                vc = BookCategoryViewController()
            case 3:
                vc = ProfileViewController()
            default:
                break
            }
            let root = createRoot(with: vc, title: title, image: tabBarImages[idx], selectedImage: tabBarSelectedImages[idx])
            controllers.append(root)
        }
        if controllers.count > 0 {
            setViewControllers(controllers, animated: true)
//            if indexFlag != controllers.count - 1 || AppManager.shared.isLogin {
//                selectedIndex = indexFlag
//            }
        }
        //TODO: - showBadgeOnProfile
        #warning("showBadgeOnProfile")
    }
}

private extension SPTabBarController {
    
    func createRoot(with controller: BaseViewController, title:String, image: UIImage?, selectedImage: UIImage?) -> SPNavigationController {
        let tabBarItem = UITabBarItem(title: title, image: image, selectedImage: selectedImage?.withRenderingMode(.alwaysOriginal))
        tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -3)
        tabBarItem.imageInsets = UIEdgeInsets(top: -1, left: 0, bottom: 1, right: 0)
        controller.tabBarItem = tabBarItem
        let root = SPNavigationController(rootViewController: controller)
        return root
    }
    
    func configTabbar() {
        tabBar.barTintColor = R.color.barTintColor()
        tabBar.tintColor = R.color.tintColor()
        tabBar.unselectedItemTintColor = R.color.unselectedItemTintColor()
        tabBar.isTranslucent = false
    }
    
    func itemAnimatioin(with index: Int) {
        
        var array = Array<UIView>()
        
        for btn in tabBar.subviews {
            if btn.isKind(of: NSClassFromString("UITabBarButton")!) {
                for imageView in btn.subviews {
                    if imageView.isKind(of: UIImageView.self) {
                        array.append(imageView)
                    }
                }
            }
        }
        
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.duration = 0.23
        animation.repeatCount = 1
        animation.autoreverses = true
        animation.fromValue = 0.0
        animation.toValue = 1.0
        
        let basicAnimation = CABasicAnimation(keyPath: "opacity")
        basicAnimation.fromValue = 0.0
        basicAnimation.toValue = 1.0
        basicAnimation.duration = 0.23
        basicAnimation.autoreverses = true
        
        let group = CAAnimationGroup()
        group.duration = 0.23
        group.repeatCount = 1
        group.animations = [basicAnimation, animation]
        
        array[index].layer.add(group, forKey: "op")
    }
    
}
