//
//  TagListViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/9/8.
//

import Foundation
import RxDataSources
import RxSwift
import Action

protocol TagListViewModelInput {
    var tagAction: Action<BookTag, Void> { get }
}

protocol TagListViewModelOutput {
    var sections: Observable<[SectionModel<String, BookTag>]> { get }
}

protocol TagListViewModelType {
    var input: TagListViewModelInput { get }
    var output: TagListViewModelOutput { get }
}

class TagListViewModel: TagListViewModelType, TagListViewModelOutput, TagListViewModelInput {
    
    var input: TagListViewModelInput { return self }
    var output: TagListViewModelOutput { return self }
    
    // MARK: - Input
    
    lazy var tagAction: Action<BookTag, Void> = {
        return Action() { [unowned self] tag in
            return sceneCoordinator.transition(to: Scene.tagDetail(TagDetailViewModel(tag: tag)))
        }
    }()
    
    // MARK: - Output
    
    lazy var sections: Observable<[SectionModel<String, BookTag>]> = {
        return .just([SectionModel(model: "", items: tags)])
    }()
    
    private let sceneCoordinator: SceneCoordinatorType
    private let tags: [BookTag]
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, tags:[BookTag]) {
        self.sceneCoordinator = sceneCoordinator
        self.tags = tags
    }
    
}
