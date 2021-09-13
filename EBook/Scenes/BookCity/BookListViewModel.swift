//
//  BookListViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/9.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import Action

protocol BookListViewModelInput {
    func loadNewData()
    func loadMore()
    var itemSelectAction: Action<Book, Void> { get }
}

protocol BookListViewModelOutput {
    var title: Observable<String> { get }
    var sections: Observable<[SectionModel<String, Book>]> { get }
    var headerRefreshing: Observable<MJRefreshHeaderRxStatus> { get }
    var footerRefreshing: Observable<MJRefreshFooterRxStatus> { get }
    var isFooterHidden: Observable<Bool> { get }
}

protocol BookListViewModelType {
    var input: BookListViewModelInput { get }
    var output: BookListViewModelOutput { get }
}

class BookListViewModel:BookListViewModelType, BookListViewModelOutput, BookListViewModelInput  {
    
    var input: BookListViewModelInput { return self }
    var output: BookListViewModelOutput { return self }
    
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
    
    lazy var itemSelectAction: Action<Book, Void> = {
        return Action() { [unowned self] book in
            return sceneCoordinator.transition(to: Scene.bookDetail(BookIntroViewModel(bookId: book.id, categoryId: book.categoryId, bookName: book.name, picture: book.picture, author: book.author, zip: book.zipurl)))
        }
    }()
    
    // MARK: - Output
    
    lazy var title: Observable<String> = {
        return .just(cate != nil ? cate!.name: list!.name!)
    }()

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
    private let service: BookCityServiceType
    private let cate: BookCityCate?
    private let list: BookList?
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: BookCityService = BookCityService(), cate: BookCityCate? = nil, list:BookList? = nil) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
        self.cate = cate
        self.list = list
        headerRefreshing = refreshProperty.asObservable()
        footerRefreshing = moreProperty.asObservable()
        isFooterHidden = footerHiddenProperty.asObservable()
        var bookArray = [Book]()
        let requestFirst = headerRefreshing.flatMapLatest { [unowned self] status -> Observable<[Book]> in
            guard status != .end else {
                return .empty()
            }
            return getBookList()
        }.do { _ in
            bookArray = []
        }
        
        let requestNext = footerRefreshing.flatMapLatest { [unowned self] status -> Observable<[Book]> in
            guard status == .more else {
                return .empty()
            }
            return getBookList()
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

private extension BookListViewModel {
    func getBookList() -> Observable<[Book]> {
        if list != nil {
            totalPage = list!.totalPage
            return .just(list!.list)
        } else {
            return service.getBookList(staticPath: cate!.listStaticPath, page: currentPage).map{ [unowned self] result in
                totalPage = result.totalPage
                return result.list
            }.catchAndReturn([])
        }

    }
}
