//
//  BookcaseCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/25.
//

import Foundation
import RxSwift
import Kingfisher

protocol BookcaseCellViewModelOutput {
    var cover: Observable<Resource?> { get }
    var bookName: Observable<String> { get }
    var author: Observable<String> { get }
    var newChapter: Observable<Bool> { get }
    var status: Observable<String> { get }
}

protocol BookcaseCellViewModelType {
    var output: BookcaseCellViewModelOutput { get }
}

class BookcaseCellViewModel: BookcaseCellViewModelType, BookcaseCellViewModelOutput {
    
    var output: BookcaseCellViewModelOutput { return self }
    
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
            let leftChapter = (update.chapterNum - 1) - record.chapterIndex
            if leftChapter > 0 {
                str = "\(leftChapter)章未读"
            }
        }
        
        return .just(update.author + " · " + str)
    }()
    
    lazy var newChapter: Observable<Bool> = {
        return .just(update.chapterNum == record.totalChapter)
    }()
    
    lazy var status: Observable<String> = {
        var str = "连载"
        let leftChapter = (update.chapterNum - 1) - record.chapterIndex
        if leftChapter > 0 {
            let date = dateFormatter.date(from: update.chapterUpdateTime)
            let currentDate = Date.localDateFormatAnyDate(date!)
            str = Date.timeAgoSinceDate(currentDate)
        }
        if update.bookType == 2 {
            str = "完本"
        }
        return .just(str + " · " + update.chapterName)
    }()
    
    // MARK: - Property
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter.dateFormatterForCurrentThread()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+08:00"
        return formatter
    }()
    private let record: BookRecord
    private let update: BookUpdateModel
    
    init(record: BookRecord, update: BookUpdateModel) {
        self.record = record
        self.update = update
    }
    
}
