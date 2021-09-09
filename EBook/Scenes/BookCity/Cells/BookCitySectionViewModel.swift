//
//  BookCitySectionViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/2.
//

import Foundation
import RxSwift
import Action

protocol BookCitySectionViewModelInput {
    var moreAction: CocoaAction { get }
}

protocol BookCitySectioinViewModelOutput {
    var title: Observable<String> { get }
}

protocol BookCitySectionViewModelType {
    var input: BookCitySectionViewModelInput { get }
    var output: BookCitySectioinViewModelOutput { get }
}

class BookCitySectionViewModel: BookCitySectionViewModelType, BookCitySectioinViewModelOutput, BookCitySectionViewModelInput {
    var input: BookCitySectionViewModelInput { return self }
    var output: BookCitySectioinViewModelOutput { return self }
    
    // MARK: - Input
    
    lazy var moreAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            return sceneCoordinator.transition(to: Scene.bookList(BookListViewModel(cate: cate)))
        }
    }()
    
    // MARK: - Output
    
    lazy var title: Observable<String> = {
        return .just(cate.name)
    }()
    
    private let sceneCoordinator: SceneCoordinatorType
    private let cate: BookCityCate
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, cate: BookCityCate) {
        self.sceneCoordinator = sceneCoordinator
        self.cate = cate
    }
}
