//
//  BookCityViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/8/20.
//

import Foundation
import RxSwift
import RxCocoa
import Action

protocol BookCityViewModelInput {
    func refreshData()
    func go2Search()
    var bookAction: Action<BookCitySectionItem, Void> { get }
}

protocol BookCityViewModelOutput {
    var sections: Observable<[BookCitySection]> { get }
    var headerRefreshing: Observable<MJRefreshHeaderRxStatus> { get }
}

protocol BookCityViewModelType {
    var input: BookCityViewModelInput { get }
    var ouput: BookCityViewModelOutput { get }
}

class BookCityViewModel: BookCityViewModelType, BookCityViewModelInput, BookCityViewModelOutput {
    var input: BookCityViewModelInput { return self }
    var ouput: BookCityViewModelOutput { return self }
    
    // MARK: - Input
    
    func refreshData() {
        refreshProperty.accept(.refresh)
    }
    
    func go2Search() {
        sceneCoordinator.transition(to: Scene.search(BookSearchViewModel()))
    }
    
    lazy var bookAction: Action<BookCitySectionItem, Void> = {
        return Action() { [unowned self] item in
            switch item {
            case .bannerSectionItem:
                return .empty()
            case .categorySectionItem(book: let book):
                return sceneCoordinator.transition(to: Scene.bookDetail(BookIntroViewModel(bookId: book.id, categoryId: book.categoryId, bookName: book.name, picture: book.picture, author: book.author, zip: book.zipurl)))
            }
        }
    }()
    
    // MARK: - Output
    
    lazy var sections: Observable<[BookCitySection]> = {
        return refresh().map { [unowned self] banners, books in
            refreshProperty.accept(.end)
            var sectionArr = [BookCitySection]()
            var bannerItems = [BookCitySectionItem]()
            bannerItems.append(.bannerSectionItem(banners: (banners)))
            sectionArr.append(.bannerSection(items: bannerItems))
            books.forEach { items in
                var cateItems = [BookCitySectionItem]()
                items[randomPick: 3].forEach { book in
                    cateItems.append(.categorySectionItem(book: book))
                }
                sectionArr.append(.categorySection(items: cateItems))
            }
            return sectionArr
        }
    }()
    
    let headerRefreshing: Observable<MJRefreshHeaderRxStatus>
    
    // MARK: - Property
    private let refreshProperty = BehaviorRelay<MJRefreshHeaderRxStatus>(value: .default)
    private let service: BookCityServiceType
    private let sceneCoordinator: SceneCoordinatorType
    
    init(service: BookCityServiceType = BookCityService(), sceneCoordinator: SceneCoordinatorType = SceneCoordinator.shared) {
        self.service = service
        self.sceneCoordinator = sceneCoordinator
        headerRefreshing = refreshProperty.asObservable()
    }
}

private extension BookCityViewModel {
    
    func getBanner() -> Observable<[Banner]> {
        return service.getBookCityBanner(byReaderType: .male)
    }
    
    func getBookCity() -> [Observable<[Book]>] {
        var requests = [Observable<[Book]>]()
        AppManager.shared.bookCity?.male.forEach({ cate in
            requests.append(service.getBookCityCate(byId: cate.id, readerType: .male))
        })
        return requests
    }
    
    func getBookCityInfo() -> Observable<([Banner], [[Book]])> {
        return Observable.zip(getBanner(), Observable.zip(getBookCity()))
    }
    
    func refresh() -> Observable<([Banner], [[Book]])> {
        return headerRefreshing.flatMapLatest { [unowned self] status -> Observable<([Banner], [[Book]])> in
            guard status != .end else {
                return .empty()
            }
            return getBookCityInfo()
        }.catch { [unowned self] _ in
            refreshProperty.accept(.end)
            return .empty()
        }
    }
}
