//
//  BookCityService.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import Foundation
import RxSwift

struct BookCityService: BookCityServiceType {
    private let book: NetworkProvider
    init(book: NetworkProvider = NetworkProvider.shared) {
        self.book = book
    }
    
    func getBookCityCate(byId id: Int, readerType: ReaderType) -> Observable<[Book]> {
        let path = Constants.staticDomain.value + "/static/book/index/\(App.appId)/\(readerType.rawValue)/\(id).json"
        return getBookCityCate(staticPath: path)
    }
    
    func getBookCityBanner(byReaderType type: ReaderType) -> Observable<[Banner]> {
        let path = Constants.staticDomain.value + "/static/banner/\(App.appId)/\(type.rawValue)/all.json"
        return getBookCityBanner(staticPath: path)
    }
    
    func getBookList(staticPath: String, page: Int) -> Observable<BookList> {
        let path = staticPath.replacingOccurrences(of: "{page}", with: "\(page)")
        return book.rx.request(.bookPath(path)).subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)).observe(on: MainScheduler.instance).map(BookList.self, atKeyPath: "data").asObservable()
    }
}

extension BookCityService {

    
    func getBookCityCate(staticPath: String) -> Observable<[Book]> {
        return book.rx.request(.bookPath(staticPath))
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observe(on: MainScheduler.instance)
            .map([Book].self, atKeyPath: "data") .asObservable()
    }
    
    func getBookCityBanner(staticPath: String) -> Observable<[Banner]> {
        return book.rx.request(.bookPath(staticPath))
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observe(on: MainScheduler.instance)
            .map([Banner].self, atKeyPath: "data") .asObservable()
    }
}
