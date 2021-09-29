//
//  ChapterEndViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/27.
//

import Foundation
import RxSwift
import RxCocoa
import Action

protocol ChapterEndViewModelInput {
    func loadNewData()
    var backAction: CocoaAction { get }
    var itemAction: Action<ChapterEndSectionItem, Void> { get }
}

protocol ChapterEndViewModelOutput {
    var title: Observable<String> { get }
    var sections: Observable<[ChapterEndSection]> { get }
    var headerRefreshing: Observable<MJRefreshHeaderRxStatus> { get }
    var bottomMenuHidden: Observable<Bool> { get }
}

protocol ChapterEndViewModelType {
    var input: ChapterEndViewModelInput { get }
    var output: ChapterEndViewModelOutput { get }
}

class ChapterEndViewModel: ChapterEndViewModelType, ChapterEndViewModelOutput, ChapterEndViewModelInput {
    var input: ChapterEndViewModelInput { return self }
    var output: ChapterEndViewModelOutput { return self }
    
    // MARK: - Input
    
    func loadNewData() {
        refreshProperty.accept(.refresh)
    }
    
    lazy var backAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            return sceneCoordinator.pop(to: BookcaseViewController.self, animated: true)
        }
    }()
    
    lazy var itemAction: Action<ChapterEndSectionItem, Void> = {
        return Action() { [unowned self] item in
            switch item {
            case .bookReleationItem(book: let book):
                return sceneCoordinator.transition(to: Scene.bookDetail(BookIntroViewModel(book: book)))
            default:
                return .empty()
            }
            
        }
    }()
    
    // MARK: - Output
    
    lazy var title: Observable<String> = {
        return .just(book.name).share()
    }()
    
    lazy var sections: Observable<[ChapterEndSection]> = {
        return sectionModels.mapMany{ $0 }
    }()
    
    lazy var bottomMenuHidden: Observable<Bool> = {
        return .just(!bookcaseIncludeThisBook()).share()
    }()
    
    let headerRefreshing: Observable<MJRefreshHeaderRxStatus>
    
    // MARK: - Property
    
    private let refreshProperty = BehaviorRelay<MJRefreshHeaderRxStatus>(value: .default)
    private var sectionModels: Observable<[ChapterEndSection]>!
    private let sceneCoordinator: SceneCoordinatorType
    private let service: BookServiceType
    private let book: BookDetail
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: BookService = BookService(), book: BookDetail) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
        self.book = book
        headerRefreshing = refreshProperty.asObservable()
        sectionModels = headerRefreshing.flatMapLatest{ [unowned self] status -> Observable<[Book]> in
            guard status != .end else {
                return .empty()
            }
            return getReleationBook()
        }.map{ [unowned self] books in
            refreshProperty.accept(.end)
            var sectionArr:[ChapterEndSection] = []
            sectionArr.append(.bookEndSection(items: [.bookEndItem(book: book)]))
            if books.count > 0 {
                let bookItems: [ChapterEndSectionItem] = books[randomPick: 8].map { .bookReleationItem(book: $0) }
                sectionArr.append(.bookReleationSection(items: bookItems))
            }
            return sectionArr
        }
    }
}

// MARK: - Private

private extension ChapterEndViewModel {
    func getReleationBook() -> Observable<[Book]> {
        return service.getRelationBooks(byId: book.categoryId)
    }
    
    func bookcaseIncludeThisBook() -> Bool {
        var isInclude = false
        let books = AppManager.shared.bookcase
        isInclude = books.filter { $0.bookId == book.id }.count > 0
        return isInclude
    }
}
