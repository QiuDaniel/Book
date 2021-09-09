//
//  BookServiceType.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/9.
//

import Foundation
import RxSwift

protocol BookServiceType {
    func getAuthorBooks(byName name: String) -> Observable<[Book]>
    func getRelationBooks(byId id: Int) -> Observable<[Book]>
    func getBook(byName name: String, bookId:Int, readerType: ReaderType) -> Observable<SearchBook?>
    func downloadBook(path: String) -> Observable<BookInfo?>
}
