//
//  SearchBookCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/7.
//

import Foundation
import RxSwift
import Kingfisher

protocol SearchBookCellViewModelOutput {
    var title: Observable<NSAttributedString> { get }
    var intro: Observable<NSAttributedString> { get }
    var cate: Observable<String> { get }
    var postImage: Observable<Resource?> { get }
}

protocol SearchBookCellViewModelType {
    var output: SearchBookCellViewModelOutput { get }
}

class SearchBookCellViewModel: SearchBookCellViewModelType, SearchBookCellViewModelOutput {
    
    var output: SearchBookCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var title: Observable<NSAttributedString> = {
        let attri = NSMutableAttributedString(string: book.name)
        let range = (book.name as NSString).range(of: keyword)
        attri.addAttribute(.foregroundColor, value: R.color.ff4c42()!, range: range)
        return .just(attri)
    }()
    
    lazy var intro: Observable<NSAttributedString> = {
        let attri = NSMutableAttributedString(string: book.intro)
        let range = (book.intro as NSString).range(of: keyword)
        attri.addAttribute(.foregroundColor, value: R.color.ff4c42()!, range: range)
        return .just(attri)
    }()
    
    lazy var cate: Observable<String> = {
        let str = book.author + " · " + book.categoryName + " · " + book.bookStatus + " · " + convertWordsCount(book.wordNum)
        return .just(str)
    }()
    
    lazy var postImage: Observable<Resource?> = {
        return .just(URL(string: book.picture))
    }()
    
    private let book: SearchBook
    private let keyword: String
    init(book: SearchBook, keyword: String) {
        self.book = book
        self.keyword = keyword
    }
}
