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
    
    func getBookCity(device: String, pkgName: String = Constants.pkgName.value) -> Observable<BookCity> {
        return book.rx.request(.bookCity(device, pkgName))
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observeOn(MainScheduler.instance)
            .map(BookCity.self, atKeyPath: "data") .asObservable()
    }
    
    func getBookCityCate(staticPath: String) -> Observable<[Book]> {
        return book.rx.request(.bookCityPath(staticPath))
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observeOn(MainScheduler.instance)
            .map([Book].self, atKeyPath: "data") .asObservable()
    }
    func getBookCityBanner(staticPath: String) -> Observable<[Banner]> {
        return book.rx.request(.bookCityPath(staticPath))
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observeOn(MainScheduler.instance)
            .map([Banner].self, atKeyPath: "data") .asObservable()
    }
}
