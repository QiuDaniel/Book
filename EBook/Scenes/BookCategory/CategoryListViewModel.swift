//
//  CategoryListViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/9/8.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

enum CategoryStyle: String {
    case hot = "hot"
    case praise = "praise"
    case new = "new"
    case finish = "finish"
}

protocol CategoryListViewModelInput {
    func loadNewData()
    func loadMore()
}

protocol CategoryListViewModelOutput {
    var sections: Observable<[SectionModel<String, Book>]> { get }
    var headerRefreshing: Observable<MJRefreshHeaderRxStatus> { get }
    var footerRefreshing: Observable<MJRefreshFooterRxStatus> { get }
    var isFooterHidden: Observable<Bool> { get }
}

protocol CategoryListViewModelType {
    var input: CategoryListViewModelInput { get }
    var output: CategoryListViewModelOutput { get }
}

class CategoryListViewModel: CategoryListViewModelType, CategoryListViewModelInput, CategoryListViewModelOutput {
    var input: CategoryListViewModelInput { return self }
    var output: CategoryListViewModelOutput { return self }
    
    // MARK: - Input
    
    func loadNewData() {
        currentPage = 1
        refreshProperty.accept(.refresh)
    }
    
    func loadMore() {
        if moreProperty.value == .noMoreData {
            return
        }
        currentPage += 1
        if currentPage > totalPage {
            moreProperty.accept(.end)
            return
        }
        moreProperty.accept(.more)
    }
    
    // MARK: - Output

    lazy var sections: Observable<[SectionModel<String, Book>]> = {
        return sectionModels.mapMany{ $0 }
    }()
    
    let headerRefreshing: Observable<MJRefreshHeaderRxStatus>
    let footerRefreshing: Observable<MJRefreshFooterRxStatus>
    let isFooterHidden: Observable<Bool>
    
    private var currentPage = 1
    private var totalPage = 0
    private var sectionModels: Observable<[SectionModel<String, Book>]>!
    private let refreshProperty = BehaviorRelay<MJRefreshHeaderRxStatus>(value: .default)
    private let moreProperty = BehaviorRelay<MJRefreshFooterRxStatus>(value: .end)
    private let footerHiddenProperty = BehaviorRelay<Bool>(value: true)
    private let sceneCoordinator: SceneCoordinatorType
    private let service: BookCategoryServiceType
    private let category: BookCategory
    private let categoryStyle: CategoryStyle
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: BookCategoryService = BookCategoryService(), categoryStyle: CategoryStyle = .hot, category: BookCategory) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
        self.category = category
        self.categoryStyle = categoryStyle
        headerRefreshing = refreshProperty.asObservable()
        footerRefreshing = moreProperty.asObservable()
        isFooterHidden = footerHiddenProperty.asObservable()
        var bookArray = [Book]()
        let requestFirst = headerRefreshing.flatMapLatest { [unowned self] status -> Observable<[Book]> in
            guard status != .end else {
                return .empty()
            }
            return getCategoryList()
        }.do { _ in
            bookArray = []
        }
        
        let requestNext = footerRefreshing.flatMapLatest { [unowned self] status -> Observable<[Book]> in
            guard status == .more else {
                return .empty()
            }
            return getCategoryList()
        }
        
        sectionModels = requestFirst.merge(with: requestNext).map{ [unowned self] books in
            bookArray += books
            refreshProperty.accept(.end)
            moreProperty.accept(currentPage == totalPage ? .noMoreData: .end)
            footerHiddenProperty.accept(bookArray.count == 0)
            return [SectionModel(model: "", items: bookArray)]
        }
    }
}

private extension CategoryListViewModel {
    
    func getCategoryList() -> Observable<[Book]> {
        return service.getCategoryList(byId: category.id, categoryStyle: categoryStyle, page: currentPage).map{ [unowned self] result in
            totalPage = result.totalPage
            return result.list
        }.catchAndReturn([])
    }
    
}
