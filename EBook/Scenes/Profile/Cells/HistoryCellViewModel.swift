//
//  HistoryCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/29.
//

import Foundation
import RxSwift
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
        return CocoaAction(enabledIf: bookInBookcase) { [unowned self] in
            addBookcase()
            return .empty()
        }
    }()
    
    lazy var deleteAction: CocoaAction = {
        return CocoaAction {
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
    
    lazy var bookInBookcase: Observable<Bool> = {
        return .just(bookcaseIncludeThisBook()).share()
    }()
    
    // MARK: - Property
    
    private let record: BookRecord
    
    init(record: BookRecord) {
        self.record = record
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
        NotificationCenter.default.post(name: SPNotification.bookcaseUpdate.name, object: nil)
        Toast.show("已加入书架")
    }
}
