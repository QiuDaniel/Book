//
//  BookTagCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/8.
//

import Foundation
import RxSwift
import Kingfisher

protocol BookTagCellViewModelOutput {
    var title: Observable<String> { get }
    var bigImage: Observable<Resource?> { get }
}

protocol BookTagCellViewModelType {
    var output: BookTagCellViewModelOutput { get }
}

class BookTagCellViewModel: BookTagCellViewModelType, BookTagCellViewModelOutput {
    var output: BookTagCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var title: Observable<String> = {
        return .just(tag.name)
    }()
    
    lazy var bigImage: Observable<Resource?> = {
        return .just(URL(string: Constants.staticDomain.value + tag.coverPicture))
    }()
    
    private let tag: BookTag
    
    init(tag: BookTag) {
        self.tag = tag
    }
}
