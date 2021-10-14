//
//  LaunchViewModel.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/25.
//

import Foundation
import RxSwift
import GoogleMobileAds

protocol LaunchViewModelInput {
    func go2Main()
    func go2Ads(withOpenAd openAd: GADAppOpenAd?)
}

protocol LaunchViewModelOutput {
    var initInfo: Observable<(AppConfig, BookCity)> { get }
}

protocol LaunchViewModelType {
    var input: LaunchViewModelInput { get }
    var output: LaunchViewModelOutput { get }
}

class LaunchViewModel: LaunchViewModelType, LaunchViewModelOutput, LaunchViewModelInput {
    var input: LaunchViewModelInput { return self }
    var output: LaunchViewModelOutput { return self }
    
    // MARK: - Input
    
    func go2Main() {
        sceneCoordinator.transition(to: Scene.launch(.home()))
    }
    
    func go2Ads(withOpenAd openAd: GADAppOpenAd?) {
        if let openAd = openAd {
            sceneCoordinator.transition(to: Scene.launch(.advertisement(openAd)))
        } else {
            go2Main()
        }
    }
    
    // MARK: - Output
    
    lazy var initInfo: Observable<(AppConfig, BookCity)> = {
        return Observable.zip(getAppConfig(), getBookCity())
    }()
    
    private let sceneCoordinator: SceneCoordinator
    private let service: InitService
#if DEBUG
    deinit {
        printLog("====dealloc===\(self)")
    }
#endif
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: InitService = InitService()) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
    }
}

private extension LaunchViewModel {

    func getAppConfig() -> Observable<AppConfig> {
        return service.getAppConfigs(device: UIDevice.current.uniqueID)
    }
    
    func getBookCity() -> Observable<BookCity> {
        return service.getBookCity()
    }
}
