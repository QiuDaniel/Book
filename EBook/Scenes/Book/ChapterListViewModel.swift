//
//  ChapterListViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/13.
//

import Foundation
import RxSwift
import RxDataSources

protocol ChapterListViewModelOutput {
    var sections: Observable<[SectionModel<String, Chapter>]> { get }
}

protocol ChapterListViewModelType {
    var output: ChapterListViewModelOutput { get }
}

class ChapterListViewModel: ChapterListViewModelType, ChapterListViewModelOutput {
    
    var output: ChapterListViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var sections: Observable<[SectionModel<String, Chapter>]> = {
        return .just([SectionModel(model: "", items: chapters)])
    }()
    
    private let sceneCoordinator: SceneCoordinatorType
    private let chapters: [Chapter]
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, chapters: [Chapter]) {
        self.sceneCoordinator = sceneCoordinator
        self.chapters = chapters
    }
}
