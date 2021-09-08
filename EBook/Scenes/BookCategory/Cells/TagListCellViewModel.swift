//
//  TagListCellViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/9/8.
//

import Foundation
import RxSwift
import Kingfisher

protocol TagListCellViewModelOutput {
    var cover: Observable<Resource?> { get }
    var title: Observable<String> { get }
}

protocol TagListCellViewModelType {
    var output: TagListCellViewModelOutput { get }
}

class TagListCellViewModel: TagListCellViewModelType, TagListCellViewModelOutput {    
    var output: TagListCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var cover: Observable<Resource?> = {
        return .just(URL(string: Constants.staticDomain.value + tag.coverPicture))
    }()
    
    lazy var title: Observable<String> = {
        return .just(tag.name)
    }()
    
    
    private let tag: BookTag
    init(tag: BookTag) {
        self.tag = tag
    }
}
