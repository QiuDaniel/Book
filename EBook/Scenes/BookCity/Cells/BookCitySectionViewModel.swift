//
//  BookCitySectionViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/2.
//

import Foundation
import RxSwift

protocol BookCitySectioinViewModelOutput {
    var title: Observable<String> { get }
}

protocol BookCitySectionViewModelType {
    var output: BookCitySectioinViewModelOutput { get }
}

class BookCitySectionViewModel: BookCitySectionViewModelType, BookCitySectioinViewModelOutput {
    var output: BookCitySectioinViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var title: Observable<String> = {
        return .just(cate.name)
    }()
    
    private let cate: BookCityCate
    
    init(cate: BookCityCate) {
        self.cate = cate
    }
}
