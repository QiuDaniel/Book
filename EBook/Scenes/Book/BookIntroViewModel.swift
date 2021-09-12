//
//  BookIntroViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/6.
//

import Foundation
import RxSwift
import RxCocoa
import Kingfisher

protocol BookIntroViewModelInput {
    func loadNewData()
    func go2Catalog(withChapters chapters: [Chapter])
}

protocol BookIntroViewModelOutput {
    var cover: Observable<Resource?> { get }
    var sections: Observable<[BookIntroSection]> { get }
    var headerRefreshing: Observable<MJRefreshHeaderRxStatus> { get }
    var loading: Observable<Bool> { get }
    var backImage: Observable<UIImage?> { get }
}

protocol BookIntroViewModelType {
    var input: BookIntroViewModelInput { get }
    var output: BookIntroViewModelOutput { get }
}

class BookIntroViewModel: BookIntroViewModelType, BookIntroViewModelOutput, BookIntroViewModelInput {
    var output: BookIntroViewModelOutput { return self }
    var input: BookIntroViewModelInput { return self }
    
    // MARK: - Input
    
    func loadNewData() {
        refreshProperty.accept(.refresh)
    }
    
    func go2Catalog(withChapters chapters: [Chapter]) {
        
    }
    
    // MARK: - Output
    
    lazy var cover: Observable<Resource?> = {
        return .just(URL(string: picture))
    }()
    
    lazy var sections: Observable<[BookIntroSection]> = {
        return sectionModels.mapMany{ $0 }
    }()
    
    lazy var backImage: Observable<UIImage?> = {
        return .just(R.image.nav_back_white())
    }()
    
    let headerRefreshing: Observable<MJRefreshHeaderRxStatus>
    let loading: Observable<Bool>
    
    private let refreshProperty = BehaviorRelay<MJRefreshHeaderRxStatus>(value: .default)
    private var sectionModels: Observable<[BookIntroSection]>!
    private let loadingProperty = BehaviorRelay<Bool>(value: false)
    
    private let service: BookServiceType
    private let picture: String
    private let bookName: String
    private let bookId: Int
    private let categoryId: Int
    private let author: String
    private let zip: String
    
    let disposeBag = DisposeBag()
    
    init(service: BookService = BookService(), bookId: Int, categoryId: Int, bookName:String, picture: String, author: String, zip: String? = nil) {
        self.service = service
        self.bookName = bookName
        self.picture = picture
        self.bookId = bookId
        self.categoryId = categoryId
        self.author = author
        let strArr = picture.split(separator: "/").map{ String($0) }
        let idx = strArr.firstIndex(where: { $0 == "cover" })
        var zipId = "\(categoryId)"
        if idx != NSNotFound && idx! < strArr.count - 1 {
            zipId = strArr[idx! + 1]
        }
        self.zip = zip == nil ? Constants.staticDomain.value + "/static/book/zip/\(zipId)/\(bookId).zip" : zip!
        headerRefreshing = refreshProperty.asObservable()
        loading = loadingProperty.asObservable()
        
        sectionModels = headerRefreshing.flatMapLatest{ [unowned self] status -> Observable<([Book], [Book], BookInfo?)> in
            guard status != .end else {
                return .empty()
            }
            if status == .default {
                loadingProperty.accept(true)
            }
            return getBookInfo()
        }.map{ [unowned self] (authorBooks, releationBooks, info) in
            loadingProperty.accept(false)
            refreshProperty.accept(.end)
            guard let info = info else {
                return []
            }
            var sectionArr = [BookIntroSection]()
            sectionArr.append(.bookBlankSection(items: [.bookBlankItem]))
            sectionArr.append(.bookInfoSection(items: [.bookInfoItem(detail: info.detail)]))
            sectionArr.append(.bookIndexSection(items: [.bookIndexItem(detail: info.detail)]))
            if info.detail.tags.count > 0 {
                sectionArr.append(.bookTagSection(items: [.bookTagItem(tags: info.detail.tags)]))
            }
            sectionArr.append(.bookDescSection(items: [.bookDescItem(detail: info.detail)]))
            sectionArr.append(.bookCatalogSection(items: [.bookCatalogItem(info: info)]))
            if releationBooks.count > 0 {
                let bookItems: [BookIntroSectionItem] = releationBooks.prefix(8).map { .bookReleationItem(book: $0) }
                sectionArr.append(.bookReleationSection(items: bookItems))
            }
            return sectionArr
        }
    }
    
}

private extension BookIntroViewModel {
    func getBookInfo() -> Observable<([Book], [Book], BookInfo?)> {
        return Observable.zip(service.getAuthorBooks(byName: author), service.getRelationBooks(byId: categoryId), service.downloadBook(path: zip))
    }
}
