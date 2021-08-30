//
//  InitService.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/28.
//

import Foundation
import RxSwift

struct InitService: InitServiceType {
    private let book: NetworkProvider
    init(book: NetworkProvider = NetworkProvider.shared) {
        self.book = book
    }
    
    func getAppConfigs(device: String, pkgName: String = Constants.pkgName.value) -> Observable<AppConfig> {
        return book.rx.request(.appConfig(device, pkgName)).map(AppConfig.self, atKeyPath: "data").asObservable()
    }
}
