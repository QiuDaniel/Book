//
//  BookCityBannerCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/8/29.
//

import Foundation
import RxSwift
import Kingfisher
import RxDataSources

protocol BookCityBannerCellViewModelOutput {
    var imageRes: Observable<[Resource?]> { get }
    var sections: Observable<[SectionModel<String, Resource>]> { get }
}

protocol BookCityBannerCellViewModelType {
    var output: BookCityBannerCellViewModelOutput { get }
}

class BookCityBannerCellViewModel: BookCityBannerCellViewModelType, BookCityBannerCellViewModelOutput {
    var output: BookCityBannerCellViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var imageRes: Observable<[Resource?]> = {
        return .just(banners.map{ URL(string: $0.pictureUrl) }).share()
    }()
    
    lazy var sections: Observable<[SectionModel<String, Resource>]> = {
        return .just([SectionModel(model: "", items: banners.map{ URL(string: $0.pictureUrl)!})])
    }()
    
    private let banners: [Banner]
    
    init(banners: [Banner]) {
        self.banners = banners;
    }
}
