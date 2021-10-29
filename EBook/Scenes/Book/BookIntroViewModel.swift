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
    func go2BookDetail(withBook book: Book)
    func go2BookList(withName name: String)
    func go2BookChapterDetail()
    func addBookcase()
    func reloadBookcaseStatus()
}

protocol BookIntroViewModelOutput {
    var title: Observable<String> { get }
    var cover: Observable<Resource?> { get }
    var sections: Observable<[BookIntroSection]> { get }
    var headerRefreshing: Observable<MJRefreshHeaderRxStatus> { get }
    var loading: Observable<Bool> { get }
    var backImage: Observable<UIImage?> { get }
    var bookcaseStatus: Observable<Bool> { get }
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
        sceneCoordinator.transition(to: Scene.chapterList(ChapterListViewModel(bookId: bookId, bookName: bookName, author: author, categoryId: categoryId, chapterName: bookInfo.detail.chapterName, picture: picture, chapters: chapters)))
    }
    
    func go2BookDetail(withBook book: Book) {
        sceneCoordinator.transition(to: Scene.bookDetail(BookIntroViewModel(book: book)))
    }
    
    func go2BookList(withName name: String) {
        if name == "看过此书的人还看过" {
            let list = BookList(list: self.releationBooks, totalPage: 1, name: "看过此书的人还看过")
            sceneCoordinator.transition(to: Scene.bookList(BookListViewModel(list: list)))
        } else if name == "作者还写过" {
            let list = BookList(list: self.authorBooks, totalPage: 1, name: "作者还写过")
            sceneCoordinator.transition(to: Scene.bookList(BookListViewModel(list: list)))
        }
    }
    
    func addBookcase() {
        var books = AppManager.shared.bookcase
        if let idx = books.firstIndex(where: { $0.bookId == bookId }) {
            books.remove(at: idx)
            bookcaseProperty.accept(false)
            Toast.show("已从书架中移除")
        } else {
            var record = BookRecord(bookId: bookId, bookName: bookName, pageIndex: 1, chapterIndex: 0, lastChapterName: bookInfo.detail.chapterName, totalChapter: bookInfo.chapters.count, picture: bookInfo.detail.picture, categoryId: bookInfo.detail.categoryId, author: bookInfo.detail.author, chapters: bookInfo.chapters, timestamp: (Date().timeIntervalSince1970))
            let hisotry = AppManager.shared.browseHistory.filter{ $0.bookId == bookId }
            if hisotry.count > 0 {
                record = hisotry.first!
                record.changeTimestamp((Date().timeIntervalSince1970))
            }
            books.insert(record, at: 0)
            bookcaseProperty.accept(true)
            Toast.show("已加入书架")
        }
        let str = modelToJson(books)
        AppStorage.shared.setObject(str, forKey: .bookcase)
        AppStorage.shared.synchronous()
        NotificationCenter.default.post(name: SPNotification.bookcaseUpdate.name, object: nil)
    }
    
    func go2BookChapterDetail() {
        let bookList = AppManager.shared.browseHistory.filter({ $0.bookId == bookId })
        if bookList.count > 0, let book = bookList.first {
            let chapterPath = DefaultDownloadDir.path + "/\(bookInfo.chapters[0].bookId)" + "/chapter"
            if let chapterNames = FileUtils.listFolder(chapterPath) as? [String] {
                var count = 0
                for chapter in bookInfo.chapters {
                    if count == chapterNames.count {
                        break
                    }
                    if chapterNames.contains("\(chapter.id).txt") {
                        chapter.isDownload = true
                        count += 1
                    }
                }
            }
            sceneCoordinator.transition(to: Scene.chapterDetail(ChapterDetailViewModel(bookId: bookId, bookName: bookName, author: author, categoryId: categoryId, chapterName: bookInfo.detail.chapterName, picture: picture, chapterIndex: book.chapterIndex, chapters: bookInfo.chapters, pageIndex: book.pageIndex)))
        } else {
            sceneCoordinator.transition(to: Scene.chapterDetail(ChapterDetailViewModel(bookId: bookId, bookName: bookName, author: author, categoryId: categoryId, chapterName: bookInfo.detail.chapterName, picture: picture, chapterIndex: 0, chapters: bookInfo.chapters, pageIndex: 1)))
        }
    }
    
    func reloadBookcaseStatus() {
        let books = AppManager.shared.bookcase
        bookcaseProperty.accept(books.filter{ $0.bookId == bookId }.count > 0)
    }
    
    // MARK: - Output
    
    lazy var title: Observable<String> = {
        return .just(bookName)
    }()
    
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
    let bookcaseStatus: Observable<Bool>
    
    private let refreshProperty = BehaviorRelay<MJRefreshHeaderRxStatus>(value: .default)
    private var sectionModels: Observable<[BookIntroSection]>!
    private let loadingProperty = BehaviorRelay<Bool>(value: false)
    private let bookcaseProperty = BehaviorRelay<Bool>(value: false)
    
    private var authorBooks: [Book]!
    private var releationBooks: [Book]!
    private var bookInfo: BookInfo!
    private let service: BookServiceType
    private let sceneCoordinator: SceneCoordinatorType
    private let book: Book
    private let picture: String
    private let bookName: String
    private let bookId: Int
    private let categoryId: Int
    private let author: String
    private let zip: String
    
#if DEBUG
    deinit {
        print("====dealloc=====\(self)")
    }
#endif
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: BookService = BookService(), book: Book) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
        self.book = book
        self.bookName = book.name
        self.picture = book.picture
        self.bookId = book.id
        self.categoryId = book.categoryId
        self.author = book.author
        let strArr = picture.split(separator: "/").map{ String($0) }
        let idx = strArr.firstIndex(where: { $0 == "cover" })
        var zipId = "\(categoryId)"
        if idx != NSNotFound && idx! < strArr.count - 1 {
            zipId = strArr[idx! + 1]
        }
        self.zip = book.zipurl == nil ? Constants.staticDomain.value + "/static/book/zip/\(zipId)/\(bookId).zip" : book.zipurl!
        headerRefreshing = refreshProperty.asObservable()
        loading = loadingProperty.asObservable()
        bookcaseStatus = bookcaseProperty.asObservable()
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
            self.bookInfo = info
            self.authorBooks = authorBooks
            self.releationBooks = releationBooks
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
            if authorBooks.count > 0 {
                let bookItems: [BookIntroSectionItem] = authorBooks.filter{ $0.id != bookId }.prefix(4).map{ .bookAuthorItem(book: $0) }
                sectionArr.append(.bookAuthorSection(items: bookItems))
            }
            sectionArr.append(.bookCopyrightSection(items: [.bookCopyrightItem(detail: bookInfo.detail)]))
            return sectionArr
        }
    }
    
}

private extension BookIntroViewModel {
    func getBookInfo() -> Observable<([Book], [Book], BookInfo?)> {
        return Observable.zip(service.getAuthorBooks(byName: author), service.getRelationBooks(byId: categoryId), service.downloadBook(path: zip))
    }
}
