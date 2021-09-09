//
//  BookIntroViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/6.
//

import Foundation
import RxSwift
import Kingfisher

protocol BookIntroViewModelOutput {
    var cover: Observable<Resource?> { get }
}

protocol BookIntroViewModelType {
    var output: BookIntroViewModelOutput { get }
}

class BookIntroViewModel: BookIntroViewModelType, BookIntroViewModelOutput {
    var output: BookIntroViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var cover: Observable<Resource?> = {
        return .just(URL(string: picture))
    }()
    
    private let service: BookServiceType
    private let picture: String
    private let bookName: String
    private let bookId: Int
    private let categoryId: Int
    private let author: String
    private let zip: String
    
    let disposeBag = DisposeBag()
    
    init(service: BookService = BookService(), bookId: Int, categoryId: Int, bookName:String, picture: String, author: String, zip: String? = nil) {
        self.service = service
        self.bookName = bookName
        self.picture = picture
        self.bookId = bookId
        self.categoryId = categoryId
        self.author = author
        let strArr = picture.split(separator: "/").map{ String($0) }
        let idx = strArr.firstIndex(where: { $0 == "cover" })
        var zipId = "\(categoryId)"
        if idx != NSNotFound && idx! < strArr.count - 1 {
            zipId = strArr[idx! + 1]
        }
        self.zip = zip == nil ? Constants.staticDomain.value + "/static/book/zip/\(zipId)/\(bookId).zip" : zip!
    }
    
}

private extension BookIntroViewModel {
    func getBookInfo() -> Observable<([Book], [Book], BookInfo?)> {
        return Observable.zip(service.getAuthorBooks(byName: author), service.getRelationBooks(byId: categoryId), service.downloadBook(path: zip))
    }
}
