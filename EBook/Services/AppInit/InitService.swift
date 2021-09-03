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
    
    func getBookCity() -> Observable<BookCity> {
        return getBookCity(device: UIDevice.current.uniqueID)
    }
}

private extension InitService {
    func getBookCity(device: String, pkgName: String = Constants.pkgName.value) -> Observable<BookCity> {
        return book.rx.request(.bookCity(device, pkgName))
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observeOn(MainScheduler.instance)
            .map(BookCity.self, atKeyPath: "data") .asObservable()
    }
}
