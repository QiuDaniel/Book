//
//  BookCityServiceType.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import Foundation
import RxSwift

protocol BookCityServiceType {
    func getBookCity(device: String, pkgName: String) -> Observable<BookCity>
    func getBookCityCate(byId id: Int, readerType: ReaderType) -> Observable<[Book]>
    func getBookCityBanner(byReaderType type: ReaderType) -> Observable<[Banner]>
}
