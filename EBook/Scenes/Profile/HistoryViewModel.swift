//
//  HistoryViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/29.
//

import Foundation
import RxSwift
import RxDataSources

protocol HistoryViewModelOutput {
    var sections: Observable<[SectionModel<String, BookRecord>]> { get }
}

protocol HistoryViewModelType {
    var output: HistoryViewModelOutput { get }
}

class HistoryViewModel: HistoryViewModelType, HistoryViewModelOutput {
    var output: HistoryViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var sections: Observable<[SectionModel<String, BookRecord>]> = {
        let records = AppManager.shared.browseHistory
        return .just([SectionModel(model: "", items: records)])
    }()
    
    // MARK: - Property
    
    private let sceneCoordinator: SceneCoordinatorType
    
    init(sceneCoordinaotr: SceneCoordinator = SceneCoordinator.shared) {
        self.sceneCoordinator = sceneCoordinaotr
    }
}
