//
//  AboutCellViewModel.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/7/13.
//

import Foundation
import RxSwift

protocol AboutCellViewModelOutput {
    var name: Observable<String?> { get }
    var content: Observable<String?> { get }
    var isLineHidden: Observable<Bool> { get }
    var isBadgeHidden: Observable<Bool> { get }
    var isArrowHidden: Observable<Bool> { get }
}

protocol AboutCellViewModelType {
    var output: AboutCellViewModelOutput { get }
}

class AboutCellViewModel: AboutCellViewModelType, AboutCellViewModelOutput {
    var output: AboutCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var name: Observable<String?> = {
        return .just(info["name"] as? String)
    }()
    
    lazy var content: Observable<String?> = {
        return .just(info["content"] as? String)
    }()
    
    lazy var isLineHidden: Observable<Bool> = {
        var hidden = false
        if let isHidden = info["line"] as? Bool {
            hidden = isHidden
        }
        return .just(hidden)
    }()
    
    lazy var isBadgeHidden: Observable<Bool> = {
        var hidden = true
        if let isHidden = info["badge"] as? Bool {
            hidden = !isHidden
        }
        return .just(hidden)
    }()
    
    lazy var isArrowHidden: Observable<Bool> = {
        var hidden = false
        if let isHidden = info["style"] as? Bool {
            hidden = !isHidden
        }
        return .just(hidden)
    }()
    
    // MARK: - Property
    
    private let info: JSONObject
    
    init(info: JSONObject) {
        self.info = info
    }
}
