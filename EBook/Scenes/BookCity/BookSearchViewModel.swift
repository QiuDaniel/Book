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
    func backSearchView()
    func loadMore()
    var keywordSelectAction: Action<BookSearchSectionItem, Void> { get }
}

protocol BookSearchViewModelOutput {
    var searchSections: Observable<[BookSearchSection]> { get }
    var selectedText: Observable<String?> { get }
    var keyboardHide: Observable<Void> { get }
    var isFooterHidden: Observable<Bool> { get }
    var refreshStatus: Observable<MJRefreshFooterRxStatus> { get }
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
                selectedTextProperty.accept(name)
                return .empty()
            case let .resultSearchItem(model: model):
                searchBook(withKeyword: model.name, isReturnKey: true)
                selectedTextProperty.accept(model.name)
                return .empty()
            default:
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
        searchKeyword = keyword
        bookSearchProperty.accept(isReturnKey ? .book : .mixture)
    }
    
    func clearHistory() {
        AppStorage.shared.setObject(nil, forKey: .searchHistory)
        AppStorage.shared.synchronous()
        bookSearchProperty.accept(.default)
    }

    func backSearchView() {
        bookSearchProperty.accept(.default)
    }
    
    func loadMore() {
        if moreProperty.value == .noMoreData {
            return
        }
        currentPage += 1
        moreProperty.accept(.more)
    }
    
    // MARK: - Output
    
    lazy var searchSections: Observable<[BookSearchSection]> = {
        return bookSearchProperty.asObservable().flatMapLatest { [unowned self] style -> Observable<[BookSearchSection]> in
            switch style {
            case .default:
                footerHiddenProperty.accept(true)
                return getSearchHeat()
            case .mixture:
                return getSearchResult(byKeyword: searchKeyword, isBook: false)
            case .book:
                return getSearchResult(byKeyword: searchKeyword, isBook: true)
            }
        }
    }()
    
    let selectedText: Observable<String?>
    let keyboardHide: Observable<Void>
    let isFooterHidden: Observable<Bool>
    let refreshStatus: Observable<MJRefreshFooterRxStatus>
    
    private let bookSearchProperty: BehaviorRelay<BookSearchStyle> = BehaviorRelay(value: .default)
    private let selectedTextProperty: BehaviorRelay<String?> = BehaviorRelay(value: nil)
    private let keyboardHideProperty = PublishSubject<Void>()
    private let footerHiddenProperty = BehaviorRelay<Bool>(value: true)
    private let moreProperty = BehaviorRelay<MJRefreshFooterRxStatus>(value: .end)
    private var searchKeyword = ""
    private var currentPage = 0
    private let sceneCoordinator: SceneCoordinatorType
    private let service: NovelSearchServiceType
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: NovelSearchService = NovelSearchService()) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
        selectedText = selectedTextProperty.asObservable()
        keyboardHide = keyboardHideProperty.asObservable()
        isFooterHidden = footerHiddenProperty.asObservable()
        refreshStatus = moreProperty.asObservable()
    }
}

private extension BookSearchViewModel {
    func getSearchHeat() -> Observable<[BookSearchSection]> {
        return service.searchHeat(withAppId: App.appId).catchAndReturn([]).map {  heats in
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
    
    func loadMoreData() -> Observable<SearchResult> {
        return refreshStatus.flatMapLatest { [unowned self] status -> Observable<SearchResult> in
            guard status == .more else {
                return .empty()
            }
            return getBookResult(self.searchKeyword)
        }
    }
    
    func getSearchResult(byKeyword keyword: String, isBook: Bool) -> Observable<[BookSearchSection]> {
        currentPage = 0
        moreProperty.accept(.more)
        var sectionArr = [BookSearchSection]()
        return loadMoreData().asObservable().map { [unowned self] result in
            keyboardHideProperty.onNext(())
            if result.list.count >= 20 {
                moreProperty.accept(.end)
            } else {
                moreProperty.accept(.noMoreData)
            }
            if result.list.count > 0 {
                if currentPage == 1 {
                    footerHiddenProperty.accept(false)
                }
                if isBook {
                    let bookItems = result.list.map{ BookSearchSectionItem.bookSearchItem(book: $0, keyword: keyword) }
                    sectionArr.append(.bookSearchSection(items: bookItems))
                } else {
                    if currentPage == 1 {
                        let authors = result.list.filter { $0.author.contains(keyword) }.map { $0.author }.unique
                        
                        if authors.count > 0 {
                            let authorItems = authors.map{ BookSearchSectionItem.resultSearchItem(model: SearchModel(keyword: keyword, name: $0, isAuthor: true)) }
                            sectionArr.append(.resultSearchSection(items: authorItems))
                        }
                    }
                    
                    let bookItems = result.list.filter{ $0.name.contains(keyword) }.map{ BookSearchSectionItem.resultSearchItem(model: SearchModel(keyword: keyword, name: $0.name, isAuthor: false)) }
                    sectionArr.append(.resultSearchSection(items: bookItems))
                }
                
                if sectionArr.count >= result.count && moreProperty.value != .noMoreData {
                    moreProperty.accept(.noMoreData)
                }
            } else {
                if currentPage == 1 {
                    footerHiddenProperty.accept(true)
                }
            }
            return sectionArr
            
        }.catch { [unowned self] _ in
            moreProperty.accept(.end)
            keyboardHideProperty.onNext(())
            footerHiddenProperty.accept(true)
            return .just(sectionArr)
        }
    }
    
    func getBookResult(_ keyword: String) -> Observable<SearchResult> {
        return service.searchNovel(withKeyword: keyword, pageIndex: currentPage, pageSize: 20, reader: .female)
    }
        
}
