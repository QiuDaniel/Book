//
//  BookEndStatusCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/28.
//

import Foundation
import RxSwift
import Action

protocol BookEndStatusCellViewModelInput {
    var bookCityAction: CocoaAction { get }
}

protocol BookEndStatusCellViewModelOutput {
    var bookStatus: Observable<String> { get }
}

protocol BookEndStatusCellViewModelType {
    var input: BookEndStatusCellViewModelInput { get }
    var output: BookEndStatusCellViewModelOutput { get }
}

class BookEndStatusCellViewModel: BookEndStatusCellViewModelType, BookEndStatusCellViewModelOutput, BookEndStatusCellViewModelInput {
    var input: BookEndStatusCellViewModelInput { return self }
    var output: BookEndStatusCellViewModelOutput { return self }
    
    // MARK: - Input
    
    lazy var bookCityAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            return sceneCoordinator.tabBarSelected(0)
        }
    }()
    
    // MARK: - Output
    
    lazy var bookStatus: Observable<String> = {
        let str = book.bookType == 2 ? "已完本": "已连载至最新章节"
        return .just(str)
    }()
    
    // MARK: - Property
    private let sceneCoordinator: SceneCoordinatorType
    private let book: BookDetail
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, book: BookDetail) {
        self.sceneCoordinator = sceneCoordinator
        self.book = book
    }
}
