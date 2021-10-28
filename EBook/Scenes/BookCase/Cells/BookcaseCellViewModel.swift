//
//  BookcaseCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/25.
//

import Foundation
import RxSwift
import Kingfisher
import Action

protocol BookcaseCellViewModelInput {
    var moreAction: CocoaAction { get }
}

protocol BookcaseCellViewModelOutput {
    var cover: Observable<Resource?> { get }
    var bookName: Observable<String> { get }
    var author: Observable<String> { get }
    var newChapter: Observable<Bool> { get }
    var status: Observable<String> { get }
}

protocol BookcaseCellViewModelType {
    var input: BookcaseCellViewModelInput { get }
    var output: BookcaseCellViewModelOutput { get }
}

class BookcaseCellViewModel: BookcaseCellViewModelType, BookcaseCellViewModelOutput, BookcaseCellViewModelInput {
    
    var input: BookcaseCellViewModelInput { return self }
    var output: BookcaseCellViewModelOutput { return self }
    
    lazy var moreAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            let viewModel = BookcaseMoreViewModel(book: record, completionHandler:{ action in
                switch action {
                case .detail:
                    go2BookDetail()
                case .delete:
                    deleteBookFromBookcase()
                }
            })
            return sceneCoordinator.transition(to: Scene.bookcaseMore(viewModel))
        }
    }()
    
    // MARK: - Output
    
    lazy var cover: Observable<Resource?> = {
        return .just(URL(string: record.picture))
    }()
    
    lazy var bookName: Observable<String> = {
        return .just(record.bookName)
    }()
    
    lazy var author: Observable<String> = {
        var str = "已读至最新章节"
        if AppManager.shared.browseHistory.filter({ $0.bookId == record.bookId }).count == 0 {
            str = "未读过"
        } else {
            if let update = update {
                let leftChapter = (update.chapterNum - 1) - record.chapterIndex
                if leftChapter > 0 {
                    str = "\(leftChapter)章未读"
                }
            }
        }
        return .just(record.author + " · " + str)
    }()
    
    lazy var newChapter: Observable<Bool> = {
        var notNew = true
        if let update = update {
            notNew = update.chapterNum <= record.totalChapter
        }
        return .just(notNew)
    }()
    
    lazy var status: Observable<String> = {
        var str = "连载"
        if let update = update {
            let leftChapter = (update.chapterNum - 1) - record.chapterIndex
            if leftChapter > 0 {
                let date = dateFormatter.date(from: update.chapterUpdateTime)
                let currentDate = Date.localDateFormatAnyDate(date!)
                str = Date.timeAgoSinceDate(currentDate)
            }
            if update.bookType == 2 {
                str = "完本"
            }
        }
        
        return .just(str + " · " + (update?.chapterName ?? record.lastChapterName))
    }()
    
    // MARK: - Property
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter.dateFormatterForCurrentThread()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+08:00"
        return formatter
    }()
    
    private let sceneCoordinator: SceneCoordinatorType
    private let record: BookRecord
    private let update: BookUpdateModel?
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, record: BookRecord, update: BookUpdateModel?) {
        self.sceneCoordinator = sceneCoordinator
        self.record = record
        self.update = update
    }
    
}

private extension BookcaseCellViewModel {
    
    func go2BookDetail() {
        guard let update = update else {
            let book = Book(id: record.bookId, name: record.bookName, picture: record.picture, score: 0, intro: "", bookType: 1, wordNum: 1, author: record.author, aliasAuthor: "", protagonist: "", categoryId: record.categoryId, categoryName: "", zipurl: nil)
            sceneCoordinator.transition(to: Scene.bookDetail(BookIntroViewModel(book: book)))
            return
        }
        let book = Book(id: update.bookId, name: update.name, picture: update.picture, score: update.score, intro: update.intro, bookType: update.bookType, wordNum: update.wordNum, author: update.author, aliasAuthor: update.aliasAuthor, protagonist: update.protagonist, categoryId: update.categoryId, categoryName: update.categoryName, zipurl: update.zipurl)
       sceneCoordinator.transition(to: Scene.bookDetail(BookIntroViewModel(book: book)))
    }
    
    func deleteBookFromBookcase() {
        var bookcase = AppManager.shared.bookcase
        if let idx = bookcase.firstIndex(where: { $0.bookId == record.bookId }) {
            bookcase.remove(at: idx)
            let str = modelToJson(bookcase)
            AppStorage.shared.setObject(str, forKey: .bookcase)
            AppStorage.shared.synchronous()
            NotificationCenter.default.post(name: SPNotification.bookcaseUpdate.name, object: nil)
        }
    }
}
