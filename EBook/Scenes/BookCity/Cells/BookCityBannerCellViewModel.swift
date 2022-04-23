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
import Action

protocol BookCityBannerCellViewModelInput {
    var selectedIndex: Action<Int, Void> { get }
}

protocol BookCityBannerCellViewModelOutput {
    var imageRes: Observable<[Banner]> { get }
    var sections: Observable<[SectionModel<String, Resource>]> { get }
}

protocol BookCityBannerCellViewModelType {
    var input: BookCityBannerCellViewModelInput { get }
    var output: BookCityBannerCellViewModelOutput { get }
}

class BookCityBannerCellViewModel: BookCityBannerCellViewModelType, BookCityBannerCellViewModelOutput, BookCityBannerCellViewModelInput {
    var input: BookCityBannerCellViewModelInput { return self }
    var output: BookCityBannerCellViewModelOutput { return self }
    
    // MARK: - Input
    
    lazy var selectedIndex: Action<Int, Void> = {
        return Action() { [unowned self] idx in
            printLog("index:\(idx)")
            let banner = self.banners[idx]
            let jump = banner.jumpUrl.toJSON()
            let id = Int(jump!["content"] as! String)
            return service.searchNovel(withKeyword: banner.name, pageIndex: 1, pageSize: 20, reader: ReaderType(rawValue: banner.gender)!).flatMap { result -> Observable<Void> in
                let book = result.list.filter{ $0.bookId == id }.first!
                let model = Book(id: book.bookId, name: book.name, picture: book.picture, score: book.score, intro: book.intro, bookType: book.bookType, wordNum: book.wordNum, author: book.author, aliasAuthor: book.aliasName, protagonist: book.protagonist, categoryId: book.categoryId, categoryName: book.categoryName, zipurl: nil)
                return self.sceneCoordinator.transition(to: Scene.bookDetail(BookIntroViewModel(book: model)))
            }
            
        }
    }()
    
    // MARK: - Output
    
    lazy var imageRes: Observable<[Banner]> = {
        return .just(banners).share()
    }()
    
    lazy var sections: Observable<[SectionModel<String, Resource>]> = {
        return .just([SectionModel(model: "", items: banners.map{ URL(string: $0.pictureUrl)!})])
    }()
    
    private let banners: [Banner]
    private let service: NovelSearchServiceType
    private let sceneCoordinator: SceneCoordinatorType
    
    init(service: NovelSearchService = NovelSearchService(), sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, banners: [Banner]) {
        self.sceneCoordinator = sceneCoordinator
        self.banners = banners
        self.service = service
    }
}
