//
//  BookCategoryCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/8.
//

import Foundation
import RxSwift
import Kingfisher

protocol BookCategoryCellViewModelOutput {
    var title: Observable<String> { get }
    var cover: Observable<Resource?> { get }
}

protocol BookCategoryCellViewModelType {
    var output: BookCategoryCellViewModelOutput { get }
}

class BookCategoryCellViewModel: BookCategoryCellViewModelType, BookCategoryCellViewModelOutput {
    
    var output: BookCategoryCellViewModelOutput { return self }
    
    // MARK: - Output
    lazy var title: Observable<String> = {
        return .just(category.name)
    }()
    
    lazy var cover: Observable<Resource?> = {
        return .just(URL(string: category.picture))
    }()
    
    private let category: BookCategory
    
    init(category: BookCategory) {
        self.category = category
    }
    
}
