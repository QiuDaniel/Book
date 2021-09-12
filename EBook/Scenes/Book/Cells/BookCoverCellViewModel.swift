//
//  BookCoverCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/12.
//

import Foundation
import RxSwift
import Kingfisher

protocol BookCoverCellViewModelOutput {
    var cover: Observable<Resource?> { get }
    var name: Observable<String> { get }
    var otherInfo: Observable<String> { get }
}

protocol BookCoverCellViewModelType {
    var output: BookCoverCellViewModelOutput { get }
}

class BookCoverCellViewModel: BookCoverCellViewModelType, BookCoverCellViewModelOutput {
    var output: BookCoverCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var cover: Observable<Resource?> = {
        return .just(URL(string: book.picture))
    }()
    
    lazy var name: Observable<String> = {
        return .just(book.name)
    }()
    
    lazy var otherInfo: Observable<String> = {
        return .just(convertWordsCount(book.wordNum))
    }()
    
    
    private let book: Book
    
    init(book: Book) {
        self.book = book
    }
}
