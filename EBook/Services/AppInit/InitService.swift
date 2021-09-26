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
        return book.rx.request(.appConfig(device, pkgName)).subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)).observe(on: MainScheduler.instance).map(AppConfig.self, atKeyPath: "data").asObservable().catchAndReturn(AppConfig(staticDomain: "http://statics.rungean.com", commentSwitch: 0))
    }
    
    func getBookCity() -> Observable<BookCity> {
        return getBookCity(device: UIDevice.current.uniqueID)
    }
}

private extension InitService {
    
    func getBookCity(device: String, pkgName: String = Constants.pkgName.value) -> Observable<BookCity> {
        let path = Constants.staticDomain.value + "/static/column_index/\(App.appId).json"
        return book.rx.request(.bookPath(path))
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .observe(on: MainScheduler.instance)
            .map(BookCity.self, atKeyPath: "data") .asObservable()
    }
}
