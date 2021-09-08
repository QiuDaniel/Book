//
//  CategoryListViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/9/8.
//

import Foundation
import RxSwift
import RxDataSources

enum CategoryStyle: String {
    case hot = "hot"
    case praise = "praise"
    case new = "new"
    case finish = "finish"
}

protocol CategoryListViewModelInput {
    
}

protocol CategoryListViewModelOutput {
    var title: Observable<String> { get }
    var sections: Observable<[SectionModel<String, Book>]> { get }
}

protocol CategoryListViewModelType {
    var input: CategoryListViewModelInput { get }
    var output: CategoryListViewModelOutput { get }
}

class CategoryListViewModel: CategoryListViewModelType, CategoryListViewModelInput, CategoryListViewModelOutput {
    var input: CategoryListViewModelInput { return self }
    var output: CategoryListViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var title: Observable<String> = {
        return .just(category.name)
    }()
    
    lazy var sections: Observable<[SectionModel<String, Book>]> = {
        return getCategoryList().map { [SectionModel(model: "", items: $0)] }
    }()
    
    private let sceneCoordinator: SceneCoordinatorType
    private let service: BookCategoryServiceType
    private let category: BookCategory
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: BookCategoryService = BookCategoryService(), category: BookCategory) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
        self.category = category
    }
}

private extension CategoryListViewModel {
    
    func getCategoryList() -> Observable<[Book]> {
        return service.getCategoryList(byId: category.id, categoryStyle: .hot, page: 1)
    }
    
}
