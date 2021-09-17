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
    
    func downloadBook(path: String) -> Observable<BookInfo?> {
        return book.rx.request(.downloadAsset(path)).asObservable().map { _ in
            printLog("assetName:\(URL(string: path)!.lastPathComponent)")
            let assetName = URL(string: path)!.lastPathComponent.replacingOccurrences(of: ".zip", with: "")
            let localLocation: URL = DefaultDownloadDir.appendingPathComponent(URL(string: path)!.lastPathComponent)
            let unzipPath = DefaultDownloadDir.path + "/\(assetName)"
            let unzipPathURL = URL(fileURLWithPath: unzipPath)
            if !FileManager.default.fileExists(atPath: unzipPath) {
                try FileManager.default.createDirectory(at: unzipPathURL, withIntermediateDirectories: true, attributes: nil)
            }
            let success = SSZipArchive.unzipFile(atPath: localLocation.path, toDestination: unzipPath)
            if success {
                FileUtils.removeFile(source: localLocation.path)
                let detailPath = URL(fileURLWithPath: unzipPath + "/detail.json")
                let chapterPath = URL(fileURLWithPath: unzipPath + "/chapter.json")
                let detailData = try! Data(contentsOf: detailPath)
                let chapterData = try! Data(contentsOf: chapterPath)
                let detailJSON = try! JSONSerialization.jsonObject(with: detailData, options: .allowFragments) as! JSONObject
                let chapterJSON = try! JSONSerialization.jsonObject(with: chapterData, options: .allowFragments) as! JSONObject
                let bookDetail = jsonToModel(detailJSON["data"] as! JSONObject, BookDetail.self)
                let chapters = jsonToModels(chapterJSON["data"] as! [JSONObject], Chapter.self)
                printLog("localLocation.path:\(localLocation.path)")
                return BookInfo(detail: bookDetail!, chapters: chapters)
            }
            return ( nil)
        }
    }
    
    func downloadChapter(bookId: Int, path: String) -> Observable<String?> {
        return book.rx.request(.downloadAsset(path)).asObservable().map { _ in
            let localLocation: URL = DefaultDownloadDir.appendingPathComponent(URL(string: path)!.lastPathComponent)
            let chapterPath = DefaultDownloadDir.path + "/\(bookId)" + "/chapter"
            do {
                if !FileManager.default.fileExists(atPath: chapterPath) {
                    try FileManager.default.createDirectory(at: URL(fileURLWithPath: chapterPath), withIntermediateDirectories: true, attributes: nil)
                }
//                let targetPath = chapterPath + "/\(localLocation.lastPathComponent)"
//                if !FileUtils.fileExists(atPath: targetPath) {
//                    return targetPath
//                }
//                if FileUtils.moveFile(source: localLocation.path, target: targetPath) {
//                    return targetPath
//                }
                return localLocation.path
            } catch {
                return nil
            }
        }.catch { _ in
            #warning("返回一个错误.txt")
            printLog("1111111")
            return .just(nil)
        }
    }
}
