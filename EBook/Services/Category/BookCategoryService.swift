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
        return book.rx.request(.bookPath(path)).subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)).observe(on: MainScheduler.instance).map([BookTag].self, atKeyPath: "data").asObservable().catchAndReturn([])
    }
    
    func getBookCategories(byGender gender: ReaderType) -> Observable<[BookCategory]> {
        let path = Constants.staticDomain.value + "/static/category/\(App.appId)/\(gender.rawValue)/all.json"
        return book.rx.request(.bookPath(path)).subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)).observe(on: MainScheduler.instance).map([BookCategory].self, atKeyPath: "data").asObservable().catchAndReturn([])
    }
    
    func getCategoryList(byId id: Int, categoryStyle: CategoryStyle, page: Int) -> Observable<BookList> {
        let path = Constants.staticDomain.value + "/static/book/category/\(App.appId)/\(id)/\(categoryStyle.rawValue)/\(page).json"
        return book.rx.request(.bookPath(path)).subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)).observe(on: MainScheduler.instance).map(BookList.self, atKeyPath: "data").asObservable()
    }
    
    func getTagList(byId id: Int, page: Int) -> Observable<BookList> {
        let path = Constants.staticDomain.value + "/static/book/tag/\(App.appId)/\(id)/\(page).json"
        return book.rx.request(.bookPath(path)).subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)).observe(on: MainScheduler.instance).map(BookList.self, atKeyPath: "data").asObservable()
    }
    
}

