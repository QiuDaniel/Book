//
//  BookInfoCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/10.
//

import Foundation
import RxSwift
import Kingfisher

protocol BookInfoCellViewModelOutput {
    var name: Observable<String> { get }
    var cover: Observable<Resource?> { get }
    var author: Observable<String> { get }
    var type: Observable<String> { get }
}

protocol BookInfoCellViewModelType {
    var output: BookInfoCellViewModelOutput { get }
}

class BookInfoCellViewModel: BookInfoCellViewModelType, BookInfoCellViewModelOutput {
    
    var output: BookInfoCellViewModelOutput { return self }
    
    lazy var name: Observable<String> = {
        return .just(bookDetail.name)
    }()
    
    lazy var cover: Observable<Resource?> = {
        return .just(URL(string: bookDetail.picture))
    }()
    
    lazy var author: Observable<String> = {
        return .just(bookDetail.author)
    }()
    
    lazy var type: Observable<String> = {
        var str = bookDetail.categoryName
//        if bookDetail.tags.count > 0 {
//            let tmpStr = bookDetail.tags.map { $0.tagName }.joined(separator: " · ")
//            str = str + " · " + tmpStr
//        }
        return .just(str)
    }()
    
    // MARK: - Output
    
    private let bookDetail: BookDetail
    
    init(bookDetail: BookDetail) {
        self.bookDetail = bookDetail
    }
}
