//
//  PreferencesViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/10/18.
//

import Foundation
import RxSwift
import RxCocoa
import Action

protocol PreferencesViewModelInput {
    var boyAction: CocoaAction { get }
    var girlAction: CocoaAction { get }
}

protocol PreferencesViewModelOutput {
    var boySelected: Observable<Bool> { get }
}

protocol PreferencesViewModelType {
    var input: PreferencesViewModelInput { get }
    var output: PreferencesViewModelOutput { get }
}

class PreferencesViewModel: PreferencesViewModelType, PreferencesViewModelOutput, PreferencesViewModelInput {
    var input: PreferencesViewModelInput { return self }
    var output: PreferencesViewModelOutput { return self }
    
    // MARK: - Input
    
    lazy var boyAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            if AppManager.shared.gender != .male {
                AppStorage.shared.setObject(1, forKey: .gender)
                AppStorage.shared.synchronous()
                boySelectedProperty.accept(true)
                NotificationCenter.default.post(name: SPNotification.genderChanged.name, object: nil)
            }
            return .empty()
        }
    }()
    
    lazy var girlAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            if AppManager.shared.gender != .female {
                AppStorage.shared.setObject(2, forKey: .gender)
                AppStorage.shared.synchronous()
                boySelectedProperty.accept(false)
                NotificationCenter.default.post(name: SPNotification.genderChanged.name, object: nil)
            }
            return .empty()
        }
    }()
    
    // MARK: - Output
    
    let boySelected: Observable<Bool>
    
    private let boySelectedProperty = BehaviorRelay<Bool>(value: AppManager.shared.gender == .male)
    private let sceneCoordinator: SceneCoordinatorType
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared) {
        self.sceneCoordinator = sceneCoordinator
        boySelected = boySelectedProperty.asObservable()
    }
}
