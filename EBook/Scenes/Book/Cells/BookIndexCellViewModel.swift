//
//  BookIndexCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/10.
//

import Foundation
import RxSwift

protocol BookIndexCellViewModelOutput {
    var collectNum: Observable<String> { get }
    var bookStatus: Observable<String> { get }
    var wordNum: Observable<String> { get }
    var heatNum: Observable<String> { get }
    var popularityNum: Observable<String> { get }
}

protocol BookIndexCellViewModelType {
    var output: BookIndexCellViewModelOutput { get }
}

class BookIndexCellViewModel:BookIndexCellViewModelType, BookIndexCellViewModelOutput {
    
    var output: BookIndexCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var collectNum: Observable<String> = {
        return .just(convertNum(bookDetail.bookshelf))
    }()
    
    lazy var bookStatus: Observable<String> = {
        return .just(bookDetail.bookStatus)
    }()
    
    lazy var wordNum: Observable<String> = {
        return .just(convertWordsCount(bookDetail.wordNum))
    }()
    
    lazy var heatNum: Observable<String> = {
        return .just(convertNum(bookDetail.heat))
    }()
    
    lazy var popularityNum: Observable<String> = {
        return .just(convertNum(bookDetail.view))
    }()
    
    private let bookDetail: BookDetail
    
    init(bookDetail: BookDetail) {
        self.bookDetail = bookDetail
    }
    
}
