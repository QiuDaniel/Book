//
//  BookIntroTagCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/10.
//

import Foundation

import RxSwift

protocol BookIntroTagCellViewModelOutput {
    var tagNames: Observable<[String]> { get }
}

protocol BookIntroTagCellViewModelType {
    var output: BookIntroTagCellViewModelOutput { get }
}

class BookIntroTagCellViewModel: BookIntroTagCellViewModelType, BookIntroTagCellViewModelOutput {
    
    var output: BookIntroTagCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var tagNames: Observable<[String]> = {
        return .just(tags.map { $0.tagName })
    }()
    
    private let tags: [Tag]
    
    init(tags: [Tag]) {
        self.tags = tags
    }
}
