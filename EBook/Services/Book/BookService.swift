//
//  BookService.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/9.
//

import Foundation
import RxSwift

struct BookService: BookServiceType {
    private let book: NetworkProvider
    init(book: NetworkProvider = NetworkProvider.shared) {
        self.book = book
    }
    
    func getAuthorBooks(byName name: String) -> Observable<[Book]> {
        let path = Constants.host.value + "/static/book/author/\(name.md5String).json"
        return book.rx.request(.bookPath(path)).subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)).observe(on: MainScheduler.instance).map([Book].self, atKeyPath: "data").asObservable().catchAndReturn([])
    }
    
    func getRelationBooks(byId id: Int) -> Observable<[Book]> {
        let path = Constants.host.value + "/static/book/relationread/\(id).json"
        return book.rx.request(.bookPath(path)).subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)).observe(on: MainScheduler.instance).map([Book].self, atKeyPath: "data").asObservable().catchAndReturn([])
    }
    
    func getBook(byName name: String, bookId: Int, readerType: ReaderType) -> Observable<SearchBook?> {
        return book.rx.request(.bookSearch(name, UIDevice.current.uniqueID, 1, 20, Constants.pkgName.value, readerType.rawValue)).subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)).observe(on: MainScheduler.instance).map(SearchResult.self, atKeyPath: "data").asObservable().map{ $0.list.first{ $0.bookId == bookId } }.catchAndReturn(nil)
    }
    
    func downloadBook(path: String) -> Observable<String> {
        return book.rx.request(.downloadAsset(path)).asObservable().map { _ in
            printLog("assetName:\(URL(string: path)!.lastPathComponent)")
            let localLocation: URL = DefaultDownloadDir.appendingPathComponent(URL(string: path)!.lastPathComponent)
            let success = SSZipArchive.unzipFile(atPath: localLocation.path, toDestination: DefaultDownloadDir.path)
            if success {
                let detailPath = URL(fileURLWithPath: DefaultDownloadDir.path + "/detail.json")
                let chapterPath = URL(fileURLWithPath: DefaultDownloadDir.path + "/chapter.json")
                let detailData = try! Data(contentsOf: detailPath)
                let chapterData = try! Data(contentsOf: chapterPath)
                let detail = try! JSONSerialization.jsonObject(with: detailData, options: .allowFragments) as! JSONObject
                let chatper = try! JSONSerialization.jsonObject(with: detailData, options: .allowFragments) as! JSONObject
            }
            return localLocation.path
        }
    }
}
