//
//  Scene.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/19.
//

import Foundation
import GoogleMobileAds

enum AppLaunchStyle {
    case `default`
    case advertisement(GADAppOpenAd)
    case home(String? = nil)
//    case login(BasicLoginViewModelType)
}

protocol TargetScene {
    var transition: SceneTransitionType { get }
}

enum Scene {
    case launch(AppLaunchStyle)
    case alert(AlertViewModelType)
    case search(BookSearchViewModelType)
    case tagList(TagListViewModelType)
    case tagDetail(TagDetailViewModelType)
    case categoryList(BookCategory)
    case bookList(BookListViewModelType)
    case bookDetail(BookIntroViewModelType)
    case chapterList(ChapterListViewModelType)
    case chapterDetail(ChapterDetailViewModelType)
    case bookcaseMore(BookcaseMoreViewModelType)
    case chapterEnd(ChapterEndViewModelType)
    case history(HistoryViewModelType)
    case darkMode(UserInterfaceViewModelType)
    case findBook(FindBookViewModelType)
    case preferences(PreferencesViewModelType)
    case about(AboutViewModelType)
    case h5(H5ViewModelType)
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
            case let .advertisement(openAd):
                var adVC = GoogleAdViewController(withOpenAd: openAd)
                adVC.bind(to: GoogleAdViewModel())
                return .root(adVC)
            case .home(let url):
                let tabBarVC = SPTabBarController(url: url)
                return .tabBar(tabBarVC)
            }
        case .alert(let viewModel):
            var alertView = AlertView(withStyle: .noclose, actionCount: 2)
            alertView.bind(to: viewModel)
            return .show(alertView, .fade)
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
        case .bookDetail(let viewModel):
            var vc = BookIntroViewController()
            vc.bind(to: viewModel)
            return .push(vc, true)
        case .chapterList(let viewModel):
            var vc = ChapterListViewController()
            vc.bind(to: viewModel)
            return .push(vc, true)
        case .chapterDetail(let viewModel):
            var vc = ChapterDetailViewController()
            vc.bind(to: viewModel)
            return .push(vc, true)
        case .bookcaseMore(let viewModel):
            var vc = BookcaseMoreViewController()
            vc.bind(to: viewModel)
            return .present(vc)
        case .chapterEnd(let viewModel):
            var vc = ChapterEndViewController()
            vc.bind(to: viewModel)
            return .push(vc, true )
        case .history(let viewModel):
            var vc = HistoryViewController()
            vc.bind(to: viewModel)
            return .push(vc, true)
        case .darkMode(let viewModel):
            var vc = UserInterfaceViewController()
            vc.bind(to: viewModel)
            return .push(vc, true)
        case .findBook(let viewModel):
            var vc = FindBookViewController()
            vc.bind(to: viewModel)
            return .push(vc, true)
        case .preferences(let viewModel):
            var vc = PreferencesViewController(nib: R.nib.preferencesViewController)
            vc.bind(to: viewModel)
            return .push(vc, true)
        case .about(let viewModel):
            var vc = AboutViewController()
            vc.bind(to: viewModel)
            return .push(vc, true)
        case .h5(let viewModel):
            var vc = H5ViewController()
            vc.bind(to: viewModel)
            return .push(vc, true)
        }
    }
}
