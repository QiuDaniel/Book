//
//  HistoryCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/29.
//

import Foundation
import RxSwift
import RxCocoa
import Kingfisher
import Action

protocol HistoryCellViewModelInput {
    var addAction: CocoaAction { get }
    var deleteAction: CocoaAction { get }
}

protocol HistoryCellViewModelOutput {
    var cover: Observable<Resource?> { get }
    var title: Observable<String> { get }
    var time: Observable<String> { get }
    var bookInBookcase: Observable<Bool> { get }
}

protocol HistoryCellViewModelType {
    var input: HistoryCellViewModelInput { get }
    var output: HistoryCellViewModelOutput { get }
}

class HistoryCellViewModel: HistoryCellViewModelType, HistoryCellViewModelOutput, HistoryCellViewModelInput {
    var input: HistoryCellViewModelInput { return self }
    var output: HistoryCellViewModelOutput { return self }
    
    // MARK: - Input
    
    lazy var addAction: CocoaAction = {
        return CocoaAction(enabledIf: bookInBookcase.map{ !$0 }) { [unowned self] in
            addBookcase()
            return .empty()
        }
    }()
    
    lazy var deleteAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            var books = AppManager.shared.browseHistory
            if let idx = AppManager.shared.browseHistory.firstIndex(where: { $0.bookId == record.bookId }) {
                books.remove(at: idx)
                let str = modelToJson(books)
                AppStorage.shared.setObject(str, forKey: .browseHistory)
                AppStorage.shared.synchronous()
                NotificationCenter.default.post(name: SPNotification.browseHistoryDelete.name, object: nil)
            }
            return .empty()
        }
    }()
    
    // MARK: - Output
    
    lazy var cover: Observable<Resource?> = {
        return .just(URL(string: record.picture)).share()
    }()
    
    lazy var title: Observable<String> = {
        return .just(record.bookName).share()
    }()
    
    lazy var time: Observable<String> = {
        let date = Date(timeIntervalSince1970: record.timestamp)
        return .just(Date.bookHistoryTimeSinceDate(date)).share()
    }()
    
    let bookInBookcase: Observable<Bool>
    
    // MARK: - Property
    private let includeProperty = BehaviorRelay<Bool>(value: false)
    private let record: BookRecord
    
    init(record: BookRecord) {
        self.record = record
        bookInBookcase = includeProperty.asObservable()
        includeProperty.accept(bookcaseIncludeThisBook())
    }
}

private extension HistoryCellViewModel {
    func bookcaseIncludeThisBook() -> Bool {
        var isInclude = false
        let books = AppManager.shared.bookcase
        isInclude = books.filter { $0.bookId == record.bookId }.count > 0
        return isInclude
    }
    
    func addBookcase() {
        var books = AppManager.shared.bookcase
        var tmpRecord = record
        tmpRecord.changeTimestamp(Date().timeIntervalSince1970)
        books.insert(record, at: 0)
        let str = modelToJson(books)
        AppStorage.shared.setObject(str, forKey: .bookcase)
        AppStorage.shared.synchronous()
        includeProperty.accept(true)
        NotificationCenter.default.post(name: SPNotification.bookcaseUpdate.name, object: nil)
        Toast.show("已加入书架")
    }
}
