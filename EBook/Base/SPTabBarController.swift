//
//  SPTabBarController.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/22.
//

import UIKit

class SPTabBarController: UITabBarController {

    private var indexFlag = 0
    
    private var titles: [String] {
        return ["书城", "书架", "分类", "设置"]
    }
    
    #warning("这里tabbar 图片没有按照设置的mode进行变化")
    
    private var tabBarImages: [UIImage?] {
        return [R.image.tab_data(), R.image.tab_worker(), R.image.tab_pool(), R.image.tab_settings()]
    }
    
    private var tabBarSelectedImages: [UIImage?] {
        return [R.image.tab_data_sl(), R.image.tab_worker_sl(), R.image.tab_pool_sl(), R.image.tab_settings_sl()]
    }
    
    private let tabbarImageNames: [String] = ["tab_data", "tab_worker", "tab_pool", "tab_settings"]
    private let tabbarTitles: [String: String] = ["tab_data": "书城", "tab_worker":"书架", "tab_pool": "分类", "tab_settings": "设置"]
    
    private let url: String?
    private weak var bookCity: BookCityViewController!
    private weak var bookcase: BookcaseViewController!
    private weak var categoryContainer: BookCategoryContainerController!
    private weak var profile: ProfileViewController!
    
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            userStyleChanged(traitCollection)
        }
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
    }
}

extension SPTabBarController {
    func setupViews() {
        indexFlag = 1
        var controllers:[SPNavigationController] = []
        var bookCity = BookCityViewController()
        bookCity.bind(to: BookCityViewModel())
        self.bookCity = bookCity
        var bookcase = BookcaseViewController()
        bookcase.bind(to: BookcaseViewModel())
        self.bookcase = bookcase
        
        let vc = BookCategoryContainerController()
        self.categoryContainer = vc
        var profile = ProfileViewController()
        profile.bind(to: ProfileViewModel())
        self.profile = profile
        userStyleChanged(traitCollection)
        
        let bookCityRoot = SPNavigationController(rootViewController: bookCity)
        controllers.append(bookCityRoot)
        let bookcaseRoot = SPNavigationController(rootViewController: bookcase)
        controllers.append(bookcaseRoot)
        let containerRoot = SPNavigationController(rootViewController: vc)
        controllers.append(containerRoot)
        let profileRoot = SPNavigationController(rootViewController: profile)
        controllers.append(profileRoot)
        if controllers.count > 0 {
            setViewControllers(controllers, animated: true)
        }
    }
}

private extension SPTabBarController {
    
    func userStyleChanged(_ traitCollection: UITraitCollection) {
       
        let tabBarItems = tabbarImageNames.map { imageName -> UITabBarItem in
            let tabBarItem = UITabBarItem(title: tabbarTitles[imageName], imageName: imageName, selectedImageName: "\(imageName)_sl", traitCollection: traitCollection)
            tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -3)
            tabBarItem.imageInsets = UIEdgeInsets(top: -1, left: 0, bottom: 1, right: 0)
            return tabBarItem
        }
        bookCity.tabBarItem = tabBarItems[0]
        bookcase.tabBarItem = tabBarItems[1]
        categoryContainer.tabBarItem = tabBarItems[2]
        profile.tabBarItem = tabBarItems[3]
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

extension UITabBarItem {
    
    convenience init(title: String?, imageName: String, selectedImageName: String, traitCollection: UITraitCollection) {
        switch UserinterfaceManager.shared.interfaceStyle {
        case .system:
            switch traitCollection.userInterfaceStyle {
            case .dark:
                self.init(title: title, image: UIImage(named: "\(imageName)_dark"), selectedImage: UIImage(named: "\(selectedImageName)_dark")?.withRenderingMode(.alwaysOriginal))
            default:
                self.init(title: title, image: UIImage(named: imageName), selectedImage: UIImage(named: selectedImageName)?.withRenderingMode(.alwaysOriginal))
            }
            break
        case .light:
            self.init(title: title, image: UIImage(named: imageName), selectedImage: UIImage(named: selectedImageName)?.withRenderingMode(.alwaysOriginal))
        case .dark:
            self.init(title: title, image: UIImage(named: "\(imageName)_dark"), selectedImage: UIImage(named: "\(selectedImageName)_dark")?.withRenderingMode(.alwaysOriginal))
        }
    }
}
