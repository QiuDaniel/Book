//
//  LaunchViewModel.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/25.
//

import Foundation
import RxSwift
import NSObject_Rx
import Kingfisher

class LaunchViewModel: HasDisposeBag {
    
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
        getAppConfig()
    }
}

private extension LaunchViewModel {

    func getAppConfig() {
        service.getAppConfigs(device: UIDevice.current.uniqueID).subscribe(onNext: handleConfig).disposed(by: disposeBag)
    }

    func handleConfig(_ config: AppConfig) {
        AppStorage.shared.setObject(config.staticDomain, forKey: .staticDomain)
        AppStorage.shared.synchronous()
        sceneCoordinator.transition(to: Scene.launch(.home()))
    }
    
    
//    func handleConfig(_ result: JSONObject) {
//        var lauchStyle: AppLaunchStyle = AppManager.shared.isLogin ? .home() : .login(BasicLoginViewModel())
//        if let config = result["config"] as? JSONObject, let configArr = config["components"] as? [JSONObject] {
//            for component in configArr {
//                if let domain = component["domain"] as? String {
//                    switch domain {
//                    case "app_update_prod_sparkpool":
//                        AppManager.shared.getAppBaseInfo(component["data"] as! JSONObject)
//                    case "i18nVersion":
//                        if let data = component["data"] as? JSONObject, let value = data[App.appBuild] as? String {
//                            if versionCompare(v1: value, v2: AppManager.shared.i18nVersion) {
//                                AppManager.shared.i18nVersion = value
//                            }
//                        }
//                    case "tokens":
//                        if let data = component["data"] as? JSONObject, let info = data["currencies"] as? [JSONObject] {
//                            AppManager.shared.getAppCryptoCurrency(info)
//                        }
//                    default:
//                        break
//                    }
//                }
//            }
//        }
//
//        if let ad = result["lanuchImage"] as? JSONObject, let adArr = ad["components"] as? [JSONObject] {
//            let adModels = jsonToModels(adArr, AdModel.self)
//            for model in adModels {
//                var key: AppStorageKey = .default
//                if AppManager.shared.isChinese && model.domain.contains("iOS-zh") {
//                    key = .launchImage
//                } else if !AppManager.shared.isChinese && model.domain.contains("iOS-en") {
//                    key = .launchImageEN
//                }
//                if key != .default {
//                    let dic = modelToJson(model)
//                    if let adDic = AppStorage.shared.object(forKey: key) as? String, let lastModel = jsonToModel(adDic, AdModel.self) {
//                        if let lastCover = lastModel.cover, let cover = model.cover {
//                            if lastCover != cover {
//                                saveImage(byUrl: cover)
//                                AppStorage.shared.setObject(dic, forKey: key)
//                                AppStorage.shared.synchronous()
//
//                            } else {
//                                if lastModel.updatedAt != model.updatedAt {
//                                    AppStorage.shared.setObject(dic, forKey: key)
//                                    AppStorage.shared.synchronous()
//                                }
//                                lauchStyle = .advertisement
//                            }
//                        }
//                    } else {
//                        if let cover = model.cover, !cover.isEmpty {
//                            saveImage(byUrl: cover)
//                            AppStorage.shared.setObject(dic, forKey: key)
//                            AppStorage.shared.synchronous()
//                        } else {
//                            AppStorage.shared.setObject(nil, forKey: key)
//                            AppStorage.shared.synchronous()
//                        }
//                    }
//                }
//            }
//        }
//
//        if let walletConfig = result["wallet-config"] as? JSONObject, let configArr = walletConfig["components"] as? [JSONObject] {
//            for configDic in configArr {
//                if let domain = configDic["domain"] as? String {
//                    guard let data = configDic["data"] as? JSONObject else { continue }
//                    if domain.contains("zh") {
//                        saveWalletBizType(data, forKey: .walletBizType)
//                    } else if domain.contains("en") {
//                        saveWalletBizType(data, forKey: .walletBizTypeEN)
//                    }
//                }
//            }
//        }
//        sceneCoordinator.transition(to: Scene.launch(lauchStyle))
//    }
//
//    func saveImage(byUrl url: String) {
//        guard let imageURL = URL(string: url) else { return }
//        ImageDownloader.default.downloadImage(with: imageURL, completionHandler:  { downloadResult in
//            if case let .success(result) = downloadResult {
//                ImageCache.default.store(result.image, forKey: url)
//            }
//        })
//    }
//
//    func saveWalletBizType(_ bizType: JSONObject, forKey key: AppStorageKey) {
//        AppManager.shared.saveWalletBizType(bizType, forKey: key)
//    }
}
