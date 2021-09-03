//
//  BookIntroCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/3.
//

import Foundation
import RxSwift
import Kingfisher

protocol BookIntroCellViewModelOutput {
    var postImage: Observable<Resource?> { get }
    var title: Observable<String> { get }
    var intro: Observable<String> { get }
}

protocol BookIntroCellViewModelType {
    var output: BookIntroCellViewModelOutput { get }
}

class BookIntroCellViewModel: BookIntroCellViewModelType, BookIntroCellViewModelOutput {
    
    var output: BookIntroCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var postImage: Observable<Resource?> = {
        return .just(URL(string: book.picture))
    }()
    
    lazy var title: Observable<String> = {
        return .just(book.name)
    }()
    
    lazy var intro: Observable<String> = {
        return .just(book.intro)
    }()
    
    private let book: Book
    
    init(book: Book) {
        self.book = book
    }
}
