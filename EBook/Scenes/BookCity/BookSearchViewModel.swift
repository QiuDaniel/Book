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

protocol BookSearchViewModelInput {
    func searchBook(withKeyword keyword: String)
    func clearHistory()
    var keywordSelectAction: Action<String, Void> { get }
}

protocol BookSearchViewModelOutput {
    var sections: Observable<[SectionModel<String, String>]> { get }
}

protocol BookSearchViewModelType {
    var input: BookSearchViewModelInput { get }
    var output: BookSearchViewModelOutput { get }
}

class BookSearchViewModel: BookSearchViewModelType, BookSearchViewModelOutput, BookSearchViewModelInput {
    var input: BookSearchViewModelInput { return self }
    var output: BookSearchViewModelOutput { return self }
    
    // MARK: - Input
    
    lazy var keywordSelectAction: Action<String, Void> = {
        let action: Action<String, Void> = Action() { [unowned self] word in
            searchBook(withKeyword: word)
            return .empty()
        }
        return action
    }()
    
    func searchBook(withKeyword keyword: String) {
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
    }
    
    func clearHistory() {
        AppStorage.shared.setObject(nil, forKey: .searchHistory)
        AppStorage.shared.synchronous()
        searchResultProperty.accept(true)
    }

    
    // MARK: - Output
    
    lazy var sections: Observable<[SectionModel<String, String>]> = {
        return searchResultProperty.asObservable().flatMapLatest { [unowned self] _ -> Observable<[SectionModel<String, String>]> in
            return getSearchHeat().map { heats in
                guard let results = AppStorage.shared.object(forKey: .searchHistory) as? [String], results.count > 0 else {
                    return [SectionModel(model: "热门搜索", items: heats.map{ $0.name })]
                }
                return [SectionModel(model: "热门搜索", items: heats.map{ $0.name }), SectionModel(model: "搜索历史", items: results)]
            }
        }
    }()
    
    private let searchResultProperty: BehaviorRelay<Bool> = BehaviorRelay(value: true)
    private let sceneCoordinator: SceneCoordinatorType
    private let service: NovelSearchServiceType
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: NovelSearchService = NovelSearchService()) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
    }
}

private extension BookSearchViewModel {
    func getSearchHeat() -> Observable<[SearchHeat]> {
        return service.searchHeat(withAppId: App.appId).catchErrorJustReturn([])
    }
}
