//
//  SearchSectionViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/5.
//

import Foundation
import RxSwift

protocol SearchSectionViewModelOutput {
    var content: Observable<String> { get }
    var isClearHidden: Observable<Bool> { get }
}

protocol SearchSectionViewModelType {
    var output: SearchSectionViewModelOutput { get }
}

class SearchSectionViewModel: SearchSectionViewModelType, SearchSectionViewModelOutput {
    var output: SearchSectionViewModelOutput { return self }
    
    lazy var content: Observable<String> = {
        return .just(title)
    }()
    
    lazy var isClearHidden: Observable<Bool> = {
        return .just(index == 0)
    }()
    
    // MARK: - Output
    
    private let title: String
    private let index: Int
    
    init(title: String, index: Int) {
        self.title = title
        self.index = index
    }
}
