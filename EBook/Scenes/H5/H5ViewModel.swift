//
//  H5ViewModel.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/2.
//

import Foundation
import RxSwift


protocol H5ViewModelOutput {
    var h5Url: Observable<String> { get }
    var h5Title: Observable<String> { get }
}

protocol H5ViewModelInput {
}

protocol H5ViewModelType {
    var output: H5ViewModelOutput { get }
    var input: H5ViewModelInput { get }
}

class H5ViewModel: H5ViewModelType, H5ViewModelOutput, H5ViewModelInput, HasDisposeBag {
    var input: H5ViewModelInput { return self }
    var output: H5ViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var h5Url: Observable<String> = {
        return .just(url)
    }()
    
    lazy var h5Title: Observable<String> = {
        return .just(self.title)
    }()
    
    private let title: String
    private let url: String
    private let sceneCoordinator: SceneCoordinatorType
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, url: String, title: String = "") {
        self.sceneCoordinator = sceneCoordinator
        self.url = url
        self.title = title
    }
}

