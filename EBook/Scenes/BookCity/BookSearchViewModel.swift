//
//  BookSearchViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/4.
//

import Foundation

protocol BookSearchViewModelOutput {
    
}

protocol BookSearchViewModelType {
    var output: BookSearchViewModelOutput { get }
}

class BookSearchViewModel: BookSearchViewModelType, BookSearchViewModelOutput {
    var output: BookSearchViewModelOutput { return self }
    
    private let sceneCoordinator: SceneCoordinatorType
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared) {
        self.sceneCoordinator = sceneCoordinator
    }
}
