//
//  HistoryViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/29.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import Action

protocol HistoryViewModelInput {
    func deleteHistory()
    var itemAction: Action<BookRecord, Void> { get }
    var emptyAction: CocoaAction { get }
}

protocol HistoryViewModelOutput {
    var sections: Observable<[SectionModel<String, BookRecord>]> { get }
    var sectionReload: Observable<Void> { get }
}

protocol HistoryViewModelType {
    var input: HistoryViewModelInput { get }
    var output: HistoryViewModelOutput { get }
}

class HistoryViewModel: HistoryViewModelType, HistoryViewModelOutput, HistoryViewModelInput {
    var input: HistoryViewModelInput { return self }
    var output: HistoryViewModelOutput { return self }
    
    // MARK: - Input
    
    func deleteHistory() {
        refreshHistoryProperty.accept(true)
    }
    
    lazy var itemAction: Action<BookRecord, Void> = {
        return Action<BookRecord, Void>() { [unowned self] record in
            let book = Book(id: record.bookId, name: record.bookName, picture: record.picture, score: 0, intro: "", bookType: 1, wordNum: 1, author: record.author, aliasAuthor: "", protagonist: "", categoryId: record.categoryId, categoryName: "", zipurl: nil)
            return sceneCoordinator.transition(to: Scene.bookDetail(BookIntroViewModel(book: book)))
        }
    }()
    
    lazy var emptyAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            return sceneCoordinator.tabBarSelected(0)
        }
    }()
    
    // MARK: - Output
    
    lazy var sections: Observable<[SectionModel<String, BookRecord>]> = {
        return refreshHistoryProperty.asObservable().map { [unowned self] _ in
            let records = AppManager.shared.browseHistory.sorted { $0.timestamp > $1.timestamp }
            sectionsPublisher.onNext(())
            return [SectionModel(model: "", items: records)]
        }
    }()
    
    let sectionReload: Observable<Void>
    
    // MARK: - Property
    private let refreshHistoryProperty = BehaviorRelay<Bool>(value: true)
    private let sectionsPublisher = PublishSubject<Void>()
    private let sceneCoordinator: SceneCoordinatorType
    
    init(sceneCoordinaotr: SceneCoordinator = SceneCoordinator.shared) {
        self.sceneCoordinator = sceneCoordinaotr
        sectionReload = sectionsPublisher.asObservable()
    }
}
