//
//  AdViewModel.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/28.
//

import Foundation
import RxSwift
import RxCocoa
import Action
import Kingfisher
import NSObject_Rx

protocol AdViewModelOutput {
    var adImage: Observable<UIImage?> { get }
    var countdown: Observable<Int> { get }
}

protocol AdViewModelInput {
    var skipAction: CocoaAction { get }
    var tapAction: CocoaAction { get }
}

protocol AdViewModelType {
    var output: AdViewModelOutput { get }
    var input: AdViewModelInput { get }
}

class AdViewModel: AdViewModelType, AdViewModelOutput, AdViewModelInput, HasDisposeBag {
    var output: AdViewModelOutput { return self }
    var input: AdViewModelInput { return self }
    
    // MARK: - Input
    
    lazy var skipAction: CocoaAction = {
        return CocoaAction { [unowned self] _ in
            gotoMain()
            return .empty()
        }
    }()
    
    lazy var tapAction: CocoaAction = {
        return CocoaAction { [unowned self] _ in
            guard let url = self.url else {
                return .empty()
            }
            gotoMain(url: url)
            return .empty()
        }
    }()
    
    // MARK: - Output
    lazy var adImage: Observable<UIImage?> = {
        return .just(nil)
//        return Single.create { single in
//            guard let adDic = AppStorage.shared.object(forKey: AppManager.shared.isChinese ? .launchImage: .launchImageEN) as? String else {
//                single(.success(nil))
//                return Disposables.create()
//            }
//            guard let model = jsonToModel(adDic, AdModel.self), let cover = model.cover else {
//                single(.success(nil))
//                return Disposables.create()
//            }
//            ImageCache.default.retrieveImageInDiskCache(forKey: cover) { cacheResult in
//                if case let .success(result) = cacheResult {
//                    single(.success(result))
//                } else {
//                    single(.success(nil))
//                }
//            }
//            return Disposables.create()
//        }.asObservable()
    }()
    
    let countdown: Observable<Int>
    
    
    // MARK: - Property
    
    private let countdownProperty = BehaviorRelay<Int>(value: 0)
    private var url: String?
    private let sceneCoordinator: SceneCoordinatorType
#if DEBUG
    deinit {
        printLog("====dealloc===\(self)")
    }
#endif
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared) {
        self.sceneCoordinator = sceneCoordinator
        countdown = countdownProperty.asObservable()
        downCount()
    }
    
}

private extension AdViewModel {
    
    func downCount() {
//        guard let adDic = AppStorage.shared.object(forKey: AppManager.shared.isChinese ? .launchImage: .launchImageEN) as? String, let model = jsonToModel(adDic, AdModel.self)  else {
//            gotoMain()
//            return
//        }
//        url = model.url
//        var time = model.expire
//        self.countdownProperty.accept(time)
//        Observable<Int>.timer(.seconds(1), period: .seconds(1), scheduler: MainScheduler.instance).subscribe(onNext: { [unowned self] _ in
//            time -= 1
//            self.countdownProperty.accept(time)
//            if time <= 0 {
//                gotoMain()
//                disposeBag = DisposeBag()
//            }
//        }).disposed(by: disposeBag)
    }
    
    func gotoMain(url: String? = nil) {
        let style: AppLaunchStyle = .home(url)
        sceneCoordinator.transition(to: Scene.launch(style))
    }
    
}
