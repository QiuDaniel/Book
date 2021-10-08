//
//  ProfileServiceType.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/10/8.
//

import Foundation
import RxSwift

protocol ProfileServiceType {
    func findBook(byBookName bookName: String, keyword: String?) -> Observable<FindBook>
}
