//
//  Scene.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/19.
//

import Foundation

enum AppLaunchStyle {
    case `default`
//    case advertisement
    case home(String? = nil)
//    case login(BasicLoginViewModelType)
}

protocol TargetScene {
    var transition: SceneTransitionType { get }
}

enum Scene {
    case launch(AppLaunchStyle)
    case search(BookSearchViewModelType)
    case tagList(TagListViewModelType)
    case tagDetail(TagDetailViewModelType)
    case categoryList(BookCategory)
    case bookList(BookListViewModelType)
}

extension Scene: TargetScene {
    var transition: SceneTransitionType {
        switch self {
        case .launch(let style):
            switch style {
            case .default:
                var launchVC = LaunchViewController(nib: R.nib.launchViewController)
                launchVC.bind(to: LaunchViewModel())
                return .root(launchVC)
//            case .advertisement:
//                var adVC = AdViewController(nib: R.nib.adViewController)
//                adVC.bind(to: AdViewModel())
//                return .root(adVC)
            case .home(let url):
                let tabBarVC = SPTabBarController(url: url)
                return .tabBar(tabBarVC)
            }
        case .search(let viewModel):
            var searchVC = BookSearchViewController()
            searchVC.bind(to: viewModel)
            return .push(searchVC, true)
        case .tagList(let viewModel):
            var vc = TagListViewController()
            vc.bind(to: viewModel)
            return .push(vc, true)
        case .tagDetail(let viewModel):
            var vc = TagDetailViewController()
            vc.bind(to: viewModel)
            return .push(vc, true)
        case .categoryList(let category):
            let vc = CategoryListContainerViewController(category: category)
            return .push(vc, true)
        case .bookList(let viewModel):
            var vc = BookListViewController()
            vc.bind(to: viewModel)
            return .push(vc, true)
        }
    }
}
