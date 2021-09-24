//
//  BookCopyrightCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/24.
//

import Foundation
import RxSwift

protocol BookCopyrightCellViewModelOutput {
    var createTime: Observable<String> { get }
}

protocol BookCopyrightCellViewModelType {
    var output: BookCopyrightCellViewModelOutput { get }
}

class BookCopyrightCellViewModel: BookCopyrightCellViewModelType, BookCopyrightCellViewModelOutput {
    var output: BookCopyrightCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var createTime: Observable<String> = {
        let date = dateFormatter.date(from: detail.createdTime)
        dateFormatter.dateFormat = "yyyy年M月d日"
        return .just(dateFormatter.string(from: date!) + "上架")
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
