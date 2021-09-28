//
//  ChapterEndViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/27.
//

import Foundation
import RxSwift
import RxCocoa

protocol ChapterEndViewModelInput {
    func loadNewData()
}

protocol ChapterEndViewModelOutput {
    var sections: Observable<[ChapterEndSection]> { get }
    var headerRefreshing: Observable<MJRefreshHeaderRxStatus> { get }
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
    
    // MARK: - Output
    
    lazy var sections: Observable<[ChapterEndSection]> = {
        return sectionModels.mapMany{ $0 }
    }()
    
    let headerRefreshing: Observable<MJRefreshHeaderRxStatus>
    
    // MARK: - Property
    
    private let refreshProperty = BehaviorRelay<MJRefreshHeaderRxStatus>(value: .refresh)
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
            sectionArr.append(.bookEndSection(items: [.bookEndItem]))
            if books.count > 0 {
                let bookItems: [ChapterEndSectionItem] = books[randomPick: 4].map { .bookReleationItem(book: $0) }
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
}
