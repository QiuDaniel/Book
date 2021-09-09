//
//  BookListViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/9.
//

import Foundation

protocol BookListViewModelInput {
    
}

protocol BookListViewModelOutput {
    
}

protocol BookListViewModelType {
    var input: BookListViewModelInput { get }
    var output: BookListViewModelOutput { get }
}

class BookListViewModel:BookListViewModelType, BookListViewModelOutput, BookListViewModelInput  {
    
    var input: BookListViewModelInput { return self }
    var output: BookListViewModelOutput { return self }
    
    private let sceneCoordinator: SceneCoordinatorType
    private let service: BookCityServiceType
    private let cate: BookCityCate
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: BookCityService = BookCityService(), cate: BookCityCate) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
        self.cate = cate
        printLog("path:\(cate.listStaticPath)")
    }
}
