//
//  BookCityBannerCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/8/29.
//

import Foundation
import RxSwift
import Kingfisher

protocol BookCityBannerCellViewModelOutput {
    var imageRes: Observable<[Resource?]> { get }
}

protocol BookCityBannerCellViewModelType {
    var output: BookCityBannerCellViewModelOutput { get }
}

class BookCityBannerCellViewModel: BookCityBannerCellViewModelType, BookCityBannerCellViewModelOutput {
    var output: BookCityBannerCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var imageRes: Observable<[Resource?]> = {
        return .just(banners.map{ URL(string: $0.pictureUrl) })
    }()
    
    private let banners: [Banner]
    
    init(banners: [Banner]) {
        self.banners = banners;
    }
}
