//
//  ProfileService.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/10/8.
//

import Foundation
import RxSwift

struct ProfileService: ProfileServiceType {
    
    private let book: NetworkProvider
    
    init(book: NetworkProvider = NetworkProvider.shared) {
        self.book = book
    }
    
    func findBook(byBookName bookName: String, keyword: String?) -> Observable<FindBook> {
        return book.rx.request(.findbook(UIDevice.current.uniqueID, keyword, Constants.pkgName.value, bookName)).subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)).observe(on: MainScheduler.instance).map(FindBook.self, atKeyPath: "data").asObservable()
    }
}
