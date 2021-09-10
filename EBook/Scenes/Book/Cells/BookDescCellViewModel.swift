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
    var intro: Observable<String> { get }
    var isArrowHidden: Observable<Bool> { get }
}

protocol BookDescCellViewModelType {
    var output: BookDescCellViewModelOutput { get }
}

class BookDescCellViewModel: BookDescCellViewModelType, BookDescCellViewModelOutput {
    
    var output: BookDescCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var intro: Observable<String> = {
        return .just(detail.intro)
    }()
    
    let isArrowHidden: Observable<Bool>
    
    private let arrowHiddenProperty = BehaviorRelay<Bool>(value: true)
    private let detail: BookDetail
    
    init(detail: BookDetail, isHidden: Bool) {
        self.detail = detail
        isArrowHidden = arrowHiddenProperty.asObservable()
//        let height = CGFloat(ceilf(Float(detail.intro.size(withAttributes: [.font: UIFont.regularFont(ofSize: 12)], forStringSize: CGSize(width: App.screenWidth - 30 , height: CGFloat.greatestFiniteMagnitude)).height))) + 20
//        arrowHiddenProperty.accept(height <= 70)
        arrowHiddenProperty.accept(isHidden)
    }
}
