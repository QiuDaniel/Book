//
//  GoogleAdViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/10/13.
//

import Foundation
import GoogleMobileAds
import RxSwift
import RxCocoa
import Kingfisher

protocol GoogleAdViewModelInput {
    func loadNativeAd(_ nativeAd: GADNativeAd)
}

protocol GoogleAdViewModelOutput {
    var adImage: Observable<Resource?> { get }
    var iconImage: Observable<Resource?> { get }
}

protocol GoogleAdViewModelType {
    var input: GoogleAdViewModelInput { get }
    var output: GoogleAdViewModelOutput { get }
}

class GoogleAdViewModel: GoogleAdViewModelType, GoogleAdViewModelInput, GoogleAdViewModelOutput {
    var input: GoogleAdViewModelInput { return self }
    var output: GoogleAdViewModelOutput { return self }
    
    // MARK: - Input
    
    func loadNativeAd(_ nativeAd: GADNativeAd) {
        iconProperty.accept(nativeAd.icon?.imageURL)
        adImageProperty.accept(nativeAd.images![randomPick: 1][0].imageURL)
    }
    
    // MARK: - Output
    
    let adImage: Observable<Resource?>
    let iconImage: Observable<Resource?>
    
    // MARK: - Property
    
    private let iconProperty: BehaviorRelay<Resource?> = BehaviorRelay(value: nil)
    private let adImageProperty: BehaviorRelay<Resource?> = BehaviorRelay(value: nil)
    
    private let sceneCoordinator: SceneCoordinatorType
    
#if DEBUG
    deinit {
        printLog("====dealloc===\(self)")
    }
#endif
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared) {
        self.sceneCoordinator = sceneCoordinator
        adImage = adImageProperty.asObservable()
        iconImage = iconProperty.asObservable()
    }
    
}
