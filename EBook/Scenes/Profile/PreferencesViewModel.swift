//
//  PreferencesViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/10/18.
//

import Foundation

protocol PreferencesViewModelOutput {
    
}

protocol PreferencesViewModelType {
    var output: PreferencesViewModelOutput { get }
}

class PreferencesViewModel: PreferencesViewModelType, PreferencesViewModelOutput {
    var output: PreferencesViewModelOutput { return self }
    
    private let sceneCoordinator: SceneCoordinatorType
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared) {
        self.sceneCoordinator = sceneCoordinator
    }
}
