//
//  SearchResultCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/7.
//

import Foundation
import RxSwift

protocol SearchResultCellViewModelOutput {
    var title: Observable<NSAttributedString> { get }
    var isAuthorTipHidden: Observable<Bool> { get }
    var iconImage: Observable<UIImage?> { get }
}

protocol SearchResultCellViewModelType {
    var output: SearchResultCellViewModelOutput { get }
}

class SearchResultCellViewModel: SearchResultCellViewModelType, SearchResultCellViewModelOutput {
    var output: SearchResultCellViewModelOutput { return self }
    
    // MARK: - Output
    lazy var title: Observable<NSAttributedString> = {
        let attri = NSMutableAttributedString(string: model.name)
        let range = (model.name as NSString).range(of: model.keyword)
        attri.addAttribute(.foregroundColor, value: R.color.ff4c42()!, range: range)
        return .just(attri)
    }()
    
    lazy var isAuthorTipHidden: Observable<Bool> = {
        return .just(!model.isAuthor)
    }()
    
    lazy var iconImage: Observable<UIImage?> = {
        return .just(UIImage(systemName: model.isAuthor ? "person.fill": "book.closed.fill")?.withRenderingMode(.alwaysOriginal))
    }()
    
    private let model: SearchModel
    
    init(model: SearchModel) {
        self.model = model
    }
}


