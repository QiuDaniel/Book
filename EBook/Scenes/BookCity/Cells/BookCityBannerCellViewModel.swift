//
//  BookCityBannerCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/8/29.
//

import Foundation

protocol BookCityBannerCellViewModelOutput {
    
}

protocol BookCityBannerCellViewModelType {
    var output: BookCityBannerCellViewModelOutput { get }
}

class BookCityBannerCellViewModel: BookCityBannerCellViewModelType, BookCityBannerCellViewModelOutput {
    var output: BookCityBannerCellViewModelOutput { return self }
    
    private let banners: [Banner]
    
    init(banners: [Banner]) {
        self.banners = banners;
    }
}
