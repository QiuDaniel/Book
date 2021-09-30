//
//  ProfileCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/29.
//

import Foundation
import RxSwift

protocol ProfileCellViewModelOutput {
    var image: Observable<UIImage?> { get }
    var title: Observable<String> { get }
}

protocol ProfileCellViewModelType {
    var output: ProfileCellViewModelOutput { get }
}

class ProfileCellViewModel: ProfileCellViewModelType, ProfileCellViewModelOutput {
    var output: ProfileCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var image: Observable<UIImage?> = {
        return .just(images[index]).share()
    }()
    
    lazy var title: Observable<String> = {
        return .just(titles[index]).share()
    }()
    
    // MARK: - Property
    private let images:[UIImage?] = [R.image.icon_faq(), R.image.icon_workorder(), R.image.icon_widget(), R.image.icon_darkmode(), R.image.icon_about()]
    private let titles: [String] = ["我想找书", "浏览记录", "阅读喜好", "黑夜模式", "关于我们"]
    private let index: Int
    
    init(index: Int) {
        self.index = index
    }
}
