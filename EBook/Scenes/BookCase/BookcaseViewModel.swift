//
//  BookcaseViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/9/24.
//

import Foundation
import RxDataSources
import RxSwift
import RxCocoa
import Action

protocol BookcaseViewModelInput {
    var searchAction: CocoaAction { get }
    func loadNewData()
    func initData()
    var itemAction: Action<(BookRecord, BookUpdateModel?), Void> { get }
    var emptyAction: CocoaAction { get }
    func sortBooks(_ isUpdate: Bool)
}

protocol BookcaseViewModelOutput {
    var sections: Observable<[SectionModel<String, (BookRecord, BookUpdateModel?)>]> { get }
    var headerRefreshing: Observable<MJRefreshHeaderRxStatus> { get }
}

protocol BookcaseViewModelType {
    var input: BookcaseViewModelInput { get }
    var output: BookcaseViewModelOutput { get }
}

class BookcaseViewModel: BookcaseViewModelType, BookcaseViewModelOutput, BookcaseViewModelInput {
    
    var input: BookcaseViewModelInput { return self }
    var output: BookcaseViewModelOutput { return self }
    
    // MARK: - Input
    
    lazy var searchAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            return sceneCoordinator.transition(to: Scene.search(BookSearchViewModel()))
        }
    }()
    
    func initData() {
        refreshProperty.accept(.default)
    }
    
    func loadNewData() {
        refreshProperty.accept(.refresh)
    }
    
    lazy var itemAction: Action<(BookRecord, BookUpdateModel?), Void> = {

        return Action<(BookRecord, BookUpdateModel?), Void>() { [unowned self] item in
            var zipurl = item.1?.zipurl
            if zipurl == nil {
                let strArr = item.0.picture.split(separator: "/").map{ String($0) }
                let idx = strArr.firstIndex(where: { $0 == "cover" })
                let zipId = strArr[idx! + 1]
                zipurl = Constants.staticDomain.value + "/static/book/zip/\(zipId)/\(item.0.bookId).zip"
            }
            return sceneCoordinator.transition(to: Scene.chapterDetail(ChapterDetailViewModel(bookId: item.0.bookId, bookName: item.0.bookName, author: item.0.author, categoryId: item.0.categoryId, chapterName: (item.1?.chapterName ?? item.0.lastChapterName), picture: item.0.picture, chapterIndex: item.0.chapterIndex, chapters: item.0.chapters, pageIndex: item.0.pageIndex, zipurl: zipurl)))
        }
    }()
    
    lazy var emptyAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            return sceneCoordinator.tabBarSelected(0)
        }
    }()
    
    func sortBooks(_ isUpdate: Bool) {
        self.isUpdate = isUpdate
        refreshProperty.accept(.default)
    }
    
    // MARK: - Output
    
    lazy var sections: Observable<[SectionModel<String, (BookRecord, BookUpdateModel?)>]> = {
        return sectionModels.mapMany{ $0 }
    }()
    
    let headerRefreshing: Observable<MJRefreshHeaderRxStatus>
    
    // MARK: - Property
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter.dateFormatterForCurrentThread()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+08:00"
        return formatter
    }()
    private var isUpdate = AppStorage.shared.bool(forKey: .bookCaseSortByUpdateTime)
    private var sectionModels: Observable<[SectionModel<String, (BookRecord, BookUpdateModel?)>]>!
    private let refreshProperty = BehaviorRelay<MJRefreshHeaderRxStatus>(value: .default)
    private let sceneCoordinator: SceneCoordinatorType
    private let service: BookServiceType
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: BookService = BookService()) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
        headerRefreshing = refreshProperty.asObservable()
        let requestFirst = headerRefreshing.flatMapLatest { [unowned self] status -> Observable<[SectionModel<String, (BookRecord, BookUpdateModel?)>]> in
            guard status != .end else {
                return .empty()
            }
            if AppManager.shared.bookcase.count > 0 {
                let bookRecords = AppManager.shared.bookcase.sorted(by: {$0.timestamp > $1.timestamp})
                let bookIds = bookRecords.map { "\($0.bookId)" }.joined(separator: ",")
                return getBookcaseUpdate(byBookIds: bookIds).map { updateModels in
                    var sectionItems: [(BookRecord, BookUpdateModel?)] = []
                    if self.isUpdate {
                        if updateModels.count > 0 {
                            let updates = updateModels.sorted(by: { self.dateFormatter.date(from: $0.chapterUpdateTime)?.compare(self.dateFormatter.date(from: $1.chapterUpdateTime)!) == .orderedDescending })
                            updates.forEach { model in
                                if let record = bookRecords.first(where: { $0.bookId == model.bookId }) {
                                    sectionItems.append((record, model))
                                }
                            }
                        } else {
                            bookRecords.forEach { record in
                                let model = updateModels.first(where: { $0.bookId == record.bookId })
                                sectionItems.append((record, model))
                            }
                        }
                    } else {
                        bookRecords.forEach { record in
                            let model = updateModels.first(where: { $0.bookId == record.bookId })
                            sectionItems.append((record, model))
                        }
                    }
  
                    return [SectionModel(model: "", items: sectionItems)]
                }
            }
            return .just([])
        }
        sectionModels = requestFirst.map { [unowned self] sections in
            refreshProperty.accept(.end)
            return sections
        }
    }
}

private extension BookcaseViewModel {
    
    func getBookcaseUpdate(byBookIds bookIds: String) -> Observable<[BookUpdateModel]> {
        return service.checkBookcaseUpdate(byBookIds: bookIds)
    }
    
}
