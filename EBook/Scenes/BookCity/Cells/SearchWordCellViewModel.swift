//
//  SearchWordCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/5.
//

import Foundation
import RxSwift

protocol SearchWordCellViewModelOutput {
    var title: Observable<String> { get }
}

protocol SearchWordCellViewModelType {
    var output: SearchWordCellViewModelOutput { get }
}

class SearchWordCellViewModel: SearchWordCellViewModelType, SearchWordCellViewModelOutput {
    var output: SearchWordCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var title: Observable<String> = {
        return .just(keyword)
    }()
    
    private let keyword: String
    
    init(keyword: String) {
        self.keyword = keyword
    }
}
