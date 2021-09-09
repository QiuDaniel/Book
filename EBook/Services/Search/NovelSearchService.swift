//
//  NovelSearchService.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/8/20.
//

import Foundation
import RxSwift

struct NovelSearchService: NovelSearchServiceType {
    
    private let book: NetworkProvider
    init(book: NetworkProvider = NetworkProvider.shared) {
        self.book = book
    }
    
    func searchHeat(withAppId id: String) -> Observable<[SearchHeat]> {
        let path = Constants.staticDomain.value + "/static/book/heat/\(id)/heat.json"
        return book.rx.request(.bookHeatPath(path)).subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)).observe(on: MainScheduler.instance).map([SearchHeat].self, atKeyPath: "data").asObservable()
    }
    
    func searchNovel(withKeyword keyword: String, pageIndex: Int, pageSize: Int, reader: ReaderType) -> Observable<SearchResult> {
        return book.rx.request(.bookSearch(keyword, UIDevice.current.uniqueID, pageIndex, pageSize, Constants.pkgName.value, reader.rawValue)).subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)).observe(on: MainScheduler.instance).map(SearchResult.self, atKeyPath: "data").asObservable()
    }
}

