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
    func go2Main()
}

protocol GoogleAdViewModelOutput {

}

protocol GoogleAdViewModelType {
    var input: GoogleAdViewModelInput { get }
    var output: GoogleAdViewModelOutput { get }
}

class GoogleAdViewModel: GoogleAdViewModelType, GoogleAdViewModelInput, GoogleAdViewModelOutput {
    var input: GoogleAdViewModelInput { return self }
    var output: GoogleAdViewModelOutput { return self }
    
    // MARK: - Input
    
    func go2Main() {
        sceneCoordinator.transition(to: Scene.launch(.home()))
    }
    
    // MARK: - Output
    

    
    // MARK: - Property
    

    
    private let sceneCoordinator: SceneCoordinatorType
    
#if DEBUG
    deinit {
        printLog("====dealloc===\(self)")
    }
#endif
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared) {
        self.sceneCoordinator = sceneCoordinator
    }
    
}
