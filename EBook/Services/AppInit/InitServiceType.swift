//
//  InitServiceType.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/28.
//

import Foundation
import RxSwift

protocol InitServiceType {
    func getAppConfigs(device: String, pkgName: String) -> Observable<AppConfig>
    func getBookCity() -> Observable<BookCity>
}
