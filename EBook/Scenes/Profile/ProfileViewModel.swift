//
//  ProfileViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/9/28.
//

import Foundation
import RxSwift
import Alamofire

protocol ProfileViewModelOuput {
    
}

protocol ProfileViewModelType {
    var output: ProfileViewModelOuput { get }
}

class ProfileViewModel: ProfileViewModelType, ProfileViewModelOuput {
    var output: ProfileViewModelOuput { return self }
    
    
    // MARK: - Property
    
    private let sceneCoordinaotr: SceneCoordinatorType
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared) {
        self.sceneCoordinaotr = sceneCoordinator
    }
}
