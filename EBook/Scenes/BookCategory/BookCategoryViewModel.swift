//
//  BookCategoryViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/8.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

protocol BookCategoryViewModelOutput {
    var sections: Observable<[SectionModel<String, Any>]> { get }
}

protocol BookCategoryViewModelInput {
    func loadData()
}

protocol BookCategoryViewModelType {
    var output: BookCategoryViewModelOutput { get }
    var input: BookCategoryViewModelInput { get }
}

class BookCategoryViewModel: BookCategoryViewModelType, BookCategoryViewModelOutput, BookCategoryViewModelInput {
    var output: BookCategoryViewModelOutput { return self }
    var input: BookCategoryViewModelInput { return self }
    
    // MARK: - Input
    
    func loadData() {
        refreshProperty.accept(true)
    }
    
    // MARK: - Output
    
    lazy var sections: Observable<[SectionModel<String, Any>]> = {
        return getBookCategoryInfo().map { [unowned self] (tags, categories) in
            refreshProperty.accept(false)
            return [ SectionModel(model: "主题", items: Array(tags.prefix(4))),
                     SectionModel(model: "分类", items: categories) ]
        }
    }()
    
    private let refreshProperty = BehaviorRelay<Bool>(value: false)
    private let sceneCoordinator: SceneCoordinatorType
    private let service: BookCategoryServiceType
    private let gender: ReaderType
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: BookCategoryService = BookCategoryService(), gender: ReaderType = .male) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
        self.gender = gender
    }
}


private extension BookCategoryViewModel {
    func getBookCategoryInfo() -> Observable<([BookTag], [BookCategory])> {
        return refreshProperty.asObservable().flatMapLatest { [unowned self] refresh -> Observable<([BookTag], [BookCategory])> in
            guard refresh else {
                return .empty()
            }
            return Observable.zip(service.getBookTags(byGender: gender), service.getBookCategories(byGender: gender))
        }
    }
}
