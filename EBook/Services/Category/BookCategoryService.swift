//
//  BookCategoryService.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/8.
//

import Foundation
import RxSwift

struct BookCategoryService: BookCategoryServiceType {
    
    private let book: NetworkProvider
    init(book: NetworkProvider = NetworkProvider.shared) {
        self.book = book
    }
    
    func getBookTags(byGender gender: ReaderType) -> Observable<[BookTag]> {
        let path = Constants.staticDomain.value + "/static/tag/\(App.appId)/\(gender.rawValue).json"
        return book.rx.request(.bookPath(path)).map([BookTag].self, atKeyPath: "data").asObservable().catchAndReturn([])
    }
    
    func getBookCategories(byGender gender: ReaderType) -> Observable<[BookCategory]> {
        let path = Constants.staticDomain.value + "/static/category/\(App.appId)/\(gender.rawValue)/all.json"
        return book.rx.request(.bookPath(path)).map([BookCategory].self, atKeyPath: "data").asObservable().catchAndReturn([])
    }
    
    func getCategoryList(byId id: Int, categoryStyle: CategoryStyle, page: Int) -> Observable<[Book]> {
        let path = Constants.staticDomain.value + "/static/book/category/\(App.appId)/\(id)/\(categoryStyle.rawValue)/\(page).json"
        return book.rx.request(.bookPath(path)).map([Book].self, atKeyPath: "data").asObservable().catchAndReturn([])
    }
    
}

