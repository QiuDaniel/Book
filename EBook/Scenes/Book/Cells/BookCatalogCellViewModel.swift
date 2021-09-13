//
//  BookCatalogCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/10.
//

import Foundation
import RxSwift

protocol BookCatalogCellViewModelOutput {
    var chapterName: Observable<String> { get }
}

protocol BookCatalogCellViewModelType {
    var output: BookCatalogCellViewModelOutput { get }
}

class BookCatalogCellViewModel: BookCatalogCellViewModelType, BookCatalogCellViewModelOutput {
    var output: BookCatalogCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var chapterName: Observable<String> = {
        if detail.bookType == 2 {
            return .just("\(detail.chapterNum)章 · 完本")
        }
        let date = dateFormatter.date(from: detail.chapterUpdateTime)
        let currentDate = Date.localDateFormatAnyDate(date!)
        return .just("连载至\(detail.chapterNum)章 · \(Date.timeAgoSinceDate(currentDate))更新")
    }()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter.dateFormatterForCurrentThread()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss+08:00"
        return formatter
    }()
    
    private let detail: BookDetail
    
    init(detail: BookDetail) {
        self.detail = detail
    }
}
