//
//  BookCategoryServiceType.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/8.
//

import Foundation
import RxSwift

protocol BookCategoryServiceType {
    func getBookTags(byGender gender: ReaderType) -> Observable<[BookTag]>
    func getBookCategories(byGender gender: ReaderType) -> Observable<[BookCategory]>
    func getCategoryList(byId id: Int, categoryStyle: CategoryStyle, page: Int) -> Observable<[Book]>
}
