//
//  BookCityViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/8/20.
//

import Foundation
import RxSwift

protocol BookCityViewModelInput {
    
}

protocol BookCityViewModelOutput {
    var sections: Observable<[BookCitySection]> { get }
}

protocol BookCityViewModelType {
    var input: BookCityViewModelInput { get }
    var ouput: BookCityViewModelOutput { get }
}

class BookCityViewModel: BookCityViewModelType, BookCityViewModelInput, BookCityViewModelOutput {
    var input: BookCityViewModelInput { return self }
    var ouput: BookCityViewModelOutput { return self }
    
    // MARK: - Output
    
    lazy var sections: Observable<[BookCitySection]> = {
        return getBanner().map { banners in
            var sectionArr = [BookCitySection]()
            var bannerItems = [BookCitySectionItem]()
            bannerItems.append(.bannerSectionItem(banners: banners))
            sectionArr.append(.bannerSection(items: bannerItems))
            return sectionArr
        }
    }()
    
    // MARK: - Property
    
    private let service: BookCityServiceType
    private let sceneCoordinator: SceneCoordinatorType
    
    init(service: BookCityServiceType = BookCityService(), sceneCoordinator: SceneCoordinatorType = SceneCoordinator.shared) {
        self.service = service
        self.sceneCoordinator = sceneCoordinator
    }
}

private extension BookCityViewModel {
    
    func getBanner() -> Observable<[Banner]> {
        return service.getBookCityBanner(byReaderType: .male)
    }
    
}
