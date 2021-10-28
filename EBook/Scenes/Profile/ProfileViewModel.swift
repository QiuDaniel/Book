//
//  ProfileViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/9/28.
//

import Foundation
import RxSwift
import Action

protocol ProfileViewModelInput {
    var itemAction: Action<ProfileSectionItem, Void> { get }
}

protocol ProfileViewModelOuput {
    var sections: Observable<[ProfileSection]> { get }
}

protocol ProfileViewModelType {
    var input: ProfileViewModelInput { get }
    var output: ProfileViewModelOuput { get }
}

class ProfileViewModel: ProfileViewModelType, ProfileViewModelOuput, ProfileViewModelInput {
    var input: ProfileViewModelInput { return self }
    var output: ProfileViewModelOuput { return self }
    
    // MARK: - Input
    
    lazy var itemAction: Action<ProfileSectionItem, Void> = {
        return Action() { [unowned self] item in
            switch item {
            case .normalFunctionItem(index: let idx):
                if idx == 0 {
                    return sceneCoordinaotr.transition(to: Scene.findBook(FindBookViewModel()))
                } else if idx == 1 {
                    return sceneCoordinaotr.transition(to: Scene.history(HistoryViewModel()))
                } else if idx == 2 {
                    return sceneCoordinaotr.transition(to: Scene.preferences(PreferencesViewModel()))
                }
                return .empty()
            case .otherItem(index: let idx):
                if idx == 3 {
                    return sceneCoordinaotr.transition(to: Scene.darkMode(UserInterfaceViewModel()))
                } else if idx == 4 {
                    return sceneCoordinaotr.transition(to: Scene.about(AboutViewModel()))
                }
                return .empty()
            }
        }
    }()
    
    // MARK: - Output
    
    lazy var sections: Observable<[ProfileSection]> = {
        var sectionArr = [ProfileSection]()
        var normalItems = [ProfileSectionItem]()
        for idx in 0...2 {
            normalItems.append(.normalFunctionItem(index: idx))
        }
        sectionArr.append(.normalFunctionSection(items: normalItems))
        var otherItems = [ProfileSectionItem]()
        for idx in 3...4 {
            otherItems.append(.otherItem(index: idx))
        }
        sectionArr.append(.otherSection(items: otherItems))
        return .just(sectionArr)
    }()
    
    // MARK: - Property
    
    private let sceneCoordinaotr: SceneCoordinatorType
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared) {
        self.sceneCoordinaotr = sceneCoordinator
    }
}
