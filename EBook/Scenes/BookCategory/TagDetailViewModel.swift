//
//  TagDetailViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/9/8.
//

import Foundation
import RxSwift

protocol TagDetailViewModelOutput {
    var title: Observable<String> { get }
}

protocol TagDetailViewModelType {
    var output: TagDetailViewModelOutput { get }
}

class TagDetailViewModel: TagDetailViewModelType, TagDetailViewModelOutput {
    
    var output: TagDetailViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var title: Observable<String> = {
        return .just(tag.name)
    }()
    
    private let sceneCoordinator: SceneCoordinatorType
    private let tag: BookTag
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, tag: BookTag) {
        self.sceneCoordinator = sceneCoordinator
        self.tag = tag
    }
    
}
