//
//  TagDetailViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/9/8.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import Action

protocol TagDetailViewModelInput {
    func loadNewData()
    func loadMore()
    var itemSelectAction: Action<Book, Void> { get }
}

protocol TagDetailViewModelOutput {
    var title: Observable<String> { get }
    var sections: Observable<[SectionModel<String, Book>]> { get }
    var headerRefreshing: Observable<MJRefreshHeaderRxStatus> { get }
    var footerRefreshing: Observable<MJRefreshFooterRxStatus> { get }
    var isFooterHidden: Observable<Bool> { get }
}

protocol TagDetailViewModelType {
    var input: TagDetailViewModelInput { get }
    var output: TagDetailViewModelOutput { get }
}

class TagDetailViewModel: TagDetailViewModelType, TagDetailViewModelOutput, TagDetailViewModelInput {
    var input: TagDetailViewModelInput { return self }
    var output: TagDetailViewModelOutput { return self }
    
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
            moreProperty.accept(.noMoreData)
            return
        }
        moreProperty.accept(.more)
    }
    
    lazy var itemSelectAction: Action<Book, Void> = {
        return Action() { [unowned self] book in
            return sceneCoordinator.transition(to: Scene.bookDetail(BookIntroViewModel(book: book)))
        }
    }()
    
    // MARK: - Output
    
    lazy var title: Observable<String> = {
        return .just(tag.name)
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
    private let service: BookCategoryServiceType
    private let tag: BookTag
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: BookCategoryService = BookCategoryService(), tag: BookTag) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
        self.tag = tag
        headerRefreshing = refreshProperty.asObservable()
        footerRefreshing = moreProperty.asObservable()
        isFooterHidden = footerHiddenProperty.asObservable()
        var bookArray = [Book]()
        let requestFirst = headerRefreshing.flatMapLatest { [unowned self] status -> Observable<[Book]> in
            guard status != .end else {
                return .empty()
            }
            return getTagList()
        }.do { _ in
            bookArray = []
        }
        
        let requestNext = footerRefreshing.flatMapLatest { [unowned self] status -> Observable<[Book]> in
            guard status == .more else {
                return .empty()
            }
            return getTagList()
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

private extension TagDetailViewModel {
    func getTagList() -> Observable<[Book]> {
        return service.getTagList(byId: tag.id, page: currentPage) .map{ [unowned self] result in
            totalPage = result.totalPage
            return result.list
        }.catchAndReturn([])
    }
}
