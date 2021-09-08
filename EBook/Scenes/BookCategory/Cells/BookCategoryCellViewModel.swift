//
//  BookCategoryCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/8.
//

import Foundation

protocol BookCategoryCellViewModelOutput {
    
}

protocol BookCategoryCellViewModelType {
    
}

class BookCategoryCellViewModel: BookCategoryCellViewModelType, BookCategoryCellViewModelOutput {
    
    private let category: BookCategory
    
    init(category: BookCategory) {
        self.category = category
    }
    
}
