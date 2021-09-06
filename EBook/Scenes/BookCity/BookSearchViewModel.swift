//
//  BookSearchViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/4.
//

import Foundation
import RxDataSources
import RxSwift
import Action
import RxCocoa

enum BookSearchStyle {
    case `default`
    case mixture // author and book
    case book
}

protocol BookSearchViewModelInput {
    func searchBook(withKeyword keyword: String, isReturnKey: Bool)
    func clearHistory()
    var keywordSelectAction: Action<BookSearchSectionItem, Void> { get }
}

protocol BookSearchViewModelOutput {
    var searchSections: Observable<[BookSearchSection]> { get }
}

protocol BookSearchViewModelType {
    var input: BookSearchViewModelInput { get }
    var output: BookSearchViewModelOutput { get }
}

class BookSearchViewModel: BookSearchViewModelType, BookSearchViewModelOutput, BookSearchViewModelInput {
    var input: BookSearchViewModelInput { return self }
    var output: BookSearchViewModelOutput { return self }
    
    // MARK: - Input
    
    lazy var keywordSelectAction: Action<BookSearchSectionItem, Void> = {
        let action: Action<BookSearchSectionItem, Void> = Action() { [unowned self] item in
            switch item {
            case let .historySearchItem(name: name), let .hotSearchItem(name: name):
                searchBook(withKeyword: name, isReturnKey: true)
                return .empty()
            }
        }
        return action
    }()
    
    func searchBook(withKeyword keyword: String, isReturnKey: Bool) {
        if isEmpty(keyword) {
            return
        }
        if let results = AppStorage.shared.object(forKey: .searchHistory) as? [String], results.count > 0 {
            if !results.contains(keyword) {
                var tmpResults = results
                tmpResults.insert(keyword, at: 0)
                if tmpResults.count >= 20 {
                    tmpResults = tmpResults.dropLast()
                }
                AppStorage.shared.setObject(tmpResults, forKey: .searchHistory)
                AppStorage.shared.synchronous()
            }
        } else {
            AppStorage.shared.setObject([keyword], forKey: .searchHistory)
            AppStorage.shared.synchronous()
        }
        bookSearchProperty.accept(isReturnKey ? .book : .mixture)
    }
    
    func clearHistory() {
        AppStorage.shared.setObject(nil, forKey: .searchHistory)
        AppStorage.shared.synchronous()
        bookSearchProperty.accept(.default)
    }

    
    // MARK: - Output
    
    lazy var searchSections: Observable<[BookSearchSection]> = {
        return bookSearchProperty.asObservable().flatMapLatest { [unowned self] style -> Observable<[BookSearchSection]> in
            switch style {
            case .default:
                return getSearchHeat()
            case .mixture:
                return .just([])
            case .book:
                return .just([])
            }
        }
    }()
    
    private let bookSearchProperty: BehaviorRelay<BookSearchStyle> = BehaviorRelay(value: .default)
    private let sceneCoordinator: SceneCoordinatorType
    private let service: NovelSearchServiceType
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: NovelSearchService = NovelSearchService()) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
    }
}

private extension BookSearchViewModel {
    func getSearchHeat() -> Observable<[BookSearchSection]> {
        return service.searchHeat(withAppId: App.appId).catchErrorJustReturn([]).map {  heats in
            var sectionArr = [BookSearchSection]()
            if heats.count > 0 {
                let hotItems:[BookSearchSectionItem] = heats.map { .hotSearchItem(name: $0.name) }
                sectionArr.append(.hotSearchSection(title: "热门搜索", items: hotItems))
            }
            guard let results = AppStorage.shared.object(forKey: .searchHistory) as? [String], results.count > 0 else {
                return sectionArr
            }
            let historyItems:[BookSearchSectionItem] = results.map { .historySearchItem(name: $0) }
            sectionArr.append(.historySearchSection(title: "搜索历史", items: historyItems))
            return sectionArr
        }
    }
    
    func getSearchResult(byKeyword keywrod: String) -> Observable<SearchResult> {
        return service.searchNovel(withKeyword: keywrod, pageIndex: 1, pageSize: 20, reader: .female)
    }
}
