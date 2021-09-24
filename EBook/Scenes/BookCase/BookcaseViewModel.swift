//
//  BookcaseViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/9/24.
//

import Foundation
import RxSwift
import Action

protocol BookcaseViewModelInput {
    var searchAction: CocoaAction { get }
}

protocol BookcaseViewModelOutput {
    
}

protocol BookcaseViewModelType {
    var input: BookcaseViewModelInput { get }
}

class BookcaseViewModel: BookcaseViewModelType, BookcaseViewModelOutput, BookcaseViewModelInput {
    
    var input: BookcaseViewModelInput { return self }
    
    // MARK: - Input
    
    lazy var searchAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            return sceneCoordinator.transition(to: Scene.search(BookSearchViewModel()))
        }
    }()
    
    
    private let sceneCoordinator: SceneCoordinatorType
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared) {
        self.sceneCoordinator = sceneCoordinator
    }
}
