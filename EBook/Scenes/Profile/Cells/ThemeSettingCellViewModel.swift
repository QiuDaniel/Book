//
//  ThemeSettingCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/12.
//

import Foundation
import RxSwift

protocol ThemeSettingCellViewModelOutput {
    var title: Observable<String> { get }
    var cellIndex: Int { get }
}

protocol ThemeSettingCellViewModelType {
    var output: ThemeSettingCellViewModelOutput { get }
}

class ThemeSettingCellViewModel: ThemeSettingCellViewModelType, ThemeSettingCellViewModelOutput {
    var output: ThemeSettingCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var title: Observable<String> = {
        return .just(titles[index])
    }()
    
    var cellIndex: Int {
        return index
    }
    
    
    private var titles = ["普通模式",
                          "深色模式",]
    private let index: Int
    
    init(index: Int) {
        self.index = index
    }
}
