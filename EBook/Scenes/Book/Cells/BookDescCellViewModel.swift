//
//  BookDescCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/10.
//

import Foundation
import RxSwift
import RxCocoa

protocol BookDescCellViewModelOutput {
    var intro: Observable<NSAttributedString> { get }
    var isArrowHidden: Observable<Bool> { get }
}

protocol BookDescCellViewModelType {
    var output: BookDescCellViewModelOutput { get }
}

class BookDescCellViewModel: BookDescCellViewModelType, BookDescCellViewModelOutput {
    
    var output: BookDescCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var intro: Observable<NSAttributedString> = {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 5
        let attriStr = NSMutableAttributedString(string: detail.intro, attributes: [.paragraphStyle: paragraph, .foregroundColor: R.color.b5bcce()!, .font: UIFont.regularFont(ofSize: 12)])
        return .just(attriStr)
    }()
    
    let isArrowHidden: Observable<Bool>
    
    private let arrowHiddenProperty = BehaviorRelay<Bool>(value: true)
    private let detail: BookDetail
    
    init(detail: BookDetail, isHidden: Bool) {
        self.detail = detail
        isArrowHidden = arrowHiddenProperty.asObservable()
        arrowHiddenProperty.accept(isHidden)
    }
}
