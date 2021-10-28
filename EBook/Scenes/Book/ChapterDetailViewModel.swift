//
//  ChapterDetailViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/9/14.
//

import Foundation
import RxSwift
import RxCocoa
import Action

enum AdditionalChaptersWay {
    case tail
    case head
    case none
}

protocol ChapterDetailViewModelInput {
    func readerProgressUpdate(curChapter curChapterIndex: Int, curPage: Int)
    func readerStateChanged(_ state: DUAReaderState)
    func userInterfaceChanged(_ dark: Bool)
    func showCatalog(_ catalog: CatalogModel)
    func loadNewChapter(withIndex index: Int)
    var backAction: CocoaAction { get }
}

protocol ChapterDetailViewModelOutput {
    var chapterList: Observable<([DUAChapterModel], Int, Int)> { get }
    var loading: Observable<Bool> { get }
    var updatedChapters: Observable<[DUAChapterModel]> { get }
}

protocol ChapterDetailViewModelType {
    var input: ChapterDetailViewModelInput { get }
    var output: ChapterDetailViewModelOutput { get }
}

class ChapterDetailViewModel: ChapterDetailViewModelType, ChapterDetailViewModelOutput, ChapterDetailViewModelInput {
    var input: ChapterDetailViewModelInput { return self }
    var output: ChapterDetailViewModelOutput { return self }
    
    // MARK: - Input
    
    func readerProgressUpdate(curChapter curChapterIndex: Int, curPage: Int) {
        guard let idx = realChapters.firstIndex(where: { $0.sort == curChapterIndex + 1 }) else {
            if curChapterIndex < chapters.count { // 使用slide滑动
                currentPageIndex = curPage
                lastChapterIndex = curChapterIndex
            }
            return
        }
        currentPageIndex = curPage
        if idx == realChapters.count - 3 && curChapterIndex > lastChapterIndex { // 向后加载到倒数第2个，下载新chapter并预加载
            addChaptersProperty.accept(.tail)
        } else if idx == 2 && curChapterIndex < lastChapterIndex { //向前加载到第3个, 下载新chapter并预加载
            addChaptersProperty.accept(.head)
        }
        lastChapterIndex = curChapterIndex
    }
    
    func readerStateChanged(_ state: DUAReaderState) {
        if notLoad {
            notLoad = false
            return
        }
        loadingProperty.accept(state == .busy)
        if state == .end {
            chapterIndexProperty.accept(-1) // -1 代表书籍进入最后章节，需要下载目录到本地，确认没有新章节，然后进入endviewcontroller
        }
    }
    
    func userInterfaceChanged(_ dark: Bool) {
        if dark && UserinterfaceManager.shared.interfaceStyle != .dark {
            UserinterfaceManager.shared.interfaceStyle = .dark
            NotificationCenter.default.post(name: SPNotification.interfaceChanged.name, object: nil)
        } else if !dark && UserinterfaceManager.shared.interfaceStyle != .light {
            UserinterfaceManager.shared.interfaceStyle = .light
            NotificationCenter.default.post(name: SPNotification.interfaceChanged.name, object: nil)
        }
    }
    
    func showCatalog(_ catalog: CatalogModel) {
        if catalog.index == NSNotFound {
            return
        }
        sceneCoordinator.transition(to: Scene.chapterList(ChapterListViewModel(bookId: bookId, bookName: bookName, author: author, categoryId: categoryId, chapterName: chapterName, picture: picture, chapters: chapters, catalog: catalog)))
    }
    
    func loadNewChapter(withIndex index: Int) {
        if index == lastChapterIndex {
            return
        }
        pageIndex = 1
        currentPageIndex = 1
        lastChapterIndex = index
        chapterIndexProperty.accept(index)
    }
    
    lazy var backAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            if !bookcaseIncludeThisBook() {
                return showAddBookcase()
            }
            saveRecord()
            return sceneCoordinator.pop(animated: true)
        }
    }()
    
    // MARK: - Output

    lazy var chapterList: Observable<([DUAChapterModel], Int, Int)> = {
        return chapterIndexProperty.asObservable().flatMapLatest { [unowned self] index -> Observable<([DUAChapterModel], Int, Int)> in
            guard let index = index else {
                return .empty()
            }
            if index == -1 {
                let strArr = picture.split(separator: "/").map{ String($0) }
                let idx = strArr.firstIndex(where: { $0 == "cover" })
                let zipId = strArr[idx! + 1]
                let zipUrl = Constants.staticDomain.value + "/static/book/zip/\(zipId)/\(bookId).zip"
                loadingProperty.accept(true)
                return service.downloadBook(path: zipUrl).flatMap { bookInfo -> Observable<([DUAChapterModel], Int, Int)> in
                    guard let bookInfo = bookInfo else {
                        loadingProperty.accept(false)
                        return .empty()
                    }
                    if bookInfo.chapters.count > chapters.count {
                        chapters = bookInfo.chapters
                        return getChapterList(withStartIndex: lastChapterIndex + 1, chapters: chapters)
                    }
                    saveRecord()
                    loadingProperty.accept(false)
                    sceneCoordinator.transition(to: Scene.chapterEnd(ChapterEndViewModel(book: bookInfo.detail)))
                    return .empty()
                }
            } else {
                if let zipurl = zipurl {
                    return downloadAllChapters(withURL: zipurl).flatMap { chapters -> Observable<([DUAChapterModel], Int, Int)> in
                        let chapterPath = DefaultDownloadDir.path + "/\(chapters[0].bookId)" + "/chapter"
                        if let chapterNames = FileUtils.listFolder(chapterPath) as? [String] {
                            var count = 0
                            for chapter in chapters {
                                if count == chapterNames.count {
                                    break
                                }
                                if chapterNames.contains("\(chapter.id).txt") {
                                    chapter.isDownload = true
                                    count += 1
                                }
                            }
                        }
                        self.chapters = chapters
                        return getChapterList(withStartIndex: index, chapters: chapters)
                    }
                }
                return getChapterList(withStartIndex: index, chapters: chapters)
            }
        }
    }()
    
    lazy var updatedChapters: Observable<[DUAChapterModel]> = {
        return addChaptersProperty.asObservable().flatMapLatest { [unowned self] way -> Observable<[DUAChapterModel]> in
            guard way != .none else {
                return .empty()
            }
            if way == .tail {
                return downloadChapter(fromIndex: realChapters.last!.sort)
            }
            return downloadChapter(fromIndex: realChapters.first!.sort - 1, isNext: false)
        }
    }()
    
    let loading: Observable<Bool>
    
    
    private var realChapters: [Chapter]!
    private var lastChapterIndex: Int!
    private var currentPageIndex: Int = 1
    private let loadingProperty = BehaviorRelay<Bool>(value: false)
    private let addChaptersProperty = BehaviorRelay<AdditionalChaptersWay>(value: .none)
    private let chapterIndexProperty = BehaviorRelay<Int?>(value: nil)
    private var notLoad = true
    private let sceneCoordinator: SceneCoordinatorType
    private let service: BookServiceType
    private let bookId: Int
    private let bookName: String
    private let categoryId: Int
    private let author: String
    private let chapterName: String
    private let picture: String
    private var chapters: [Chapter]
    private var pageIndex: Int
    private let zipurl: String?
    
#if DEBUG
    deinit {
        print("====dealloc=====\(self)")
    }
#endif
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: BookService = BookService(), bookId: Int, bookName: String, author: String, categoryId: Int, chapterName: String, picture: String, chapterIndex: Int, chapters:[Chapter], pageIndex: Int = 1, zipurl: String? = nil) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
        self.bookId = bookId
        self.bookName = bookName
        self.author = author
        self.categoryId = categoryId
        self.chapterName = chapterName
        self.picture = picture
        self.chapters = chapters
        self.pageIndex = pageIndex
        self.zipurl = zipurl
        loading = loadingProperty.asObservable().distinctUntilChanged()
        chapterIndexProperty.accept(chapterIndex)
    }
}

private extension ChapterDetailViewModel {
    
    func downloadChapter(fromIndex index: Int, isNext: Bool = true) -> Observable<[DUAChapterModel]> {
        var downloadChapters: [Chapter] = []
        if isNext {
            downloadChapters = Array(chapters.dropFirst(index).prefix(5))
        } else {
            downloadChapters = Array(chapters.prefix(index > 0 ? index : 0).suffix(3))
        }
        let requests = downloadChapters.filter{ !($0.isDownload ?? false) }.map{ service.downloadChapter(bookId: $0.bookId, path: $0.contentUrl) }
        if requests.count > 0 {
            let chapterPath = DefaultDownloadDir.path + "/\(chapters[0].bookId)" + "/chapter"
            return Observable.zip(requests).map { [unowned self] paths in
                paths.forEach { path in
                    handleDownloadFile(withDownloadPath: path, chapterPath: chapterPath, chapters: chapters)
                }
                if isNext {
                    realChapters = realChapters + downloadChapters
                } else {
                    realChapters = downloadChapters + realChapters
                }
                return chapters.map { DUAChapterModel(title: $0.name, path:($0.isDownload ?? false) ? chapterPath + "/\($0.id).txt" : nil, chapterIndex: $0.sort - 1) }
            }
        }
        return .just([])
    }
        
    func getChapterList(withStartIndex startIndex: Int, chapters: [Chapter]) -> Observable<([DUAChapterModel], Int, Int)> {
        let chapterPath = DefaultDownloadDir.path + "/\(chapters[0].bookId)" + "/chapter"
        let selectChapter = chapters[startIndex]
        let afterChapters = Array(chapters.dropFirst(startIndex + 1).prefix(5))
        let beforeChapters = Array(chapters.prefix(startIndex).suffix(3))
        realChapters = beforeChapters + [selectChapter] + afterChapters
        lastChapterIndex = startIndex;
        let requests = realChapters.filter{ !($0.isDownload ?? false) }.map{ service.downloadChapter(bookId: $0.bookId, path: $0.contentUrl) }
        if requests.count > 0 {
            notLoad = true
            loadingProperty.accept(true)
            return Observable.zip(requests).map { [unowned self] paths in
                loadingProperty.accept(false)
                paths.forEach { path in
                    handleDownloadFile(withDownloadPath: path, chapterPath: chapterPath, chapters: chapters)
                }
                return (chapters.map { DUAChapterModel(title: $0.name, path: ($0.isDownload ?? false) ? chapterPath + "/\($0.id).txt" : nil, chapterIndex: $0.sort - 1) }, startIndex, pageIndex)
            }
        }
        return .just((chapters.map { DUAChapterModel(title: $0.name, path: ($0.isDownload ?? false) ? chapterPath + "/\($0.id).txt" : nil, chapterIndex: $0.sort - 1) }, startIndex, pageIndex))
    }
    
    
    func downloadAllChapters(withURL url: String) -> Observable<[Chapter]> {
        loadingProperty.accept(true)
        return service.downloadBook(path: url).flatMap{ [unowned self] bookInfo -> Observable<[Chapter]> in
            guard let bookInfo = bookInfo else {
                loadingProperty.accept(false)
                return .empty()
            }
            return .just(bookInfo.chapters)
        }
    }
    
    func saveRecord() {
        let record = BookRecord(bookId: bookId, bookName: bookName, pageIndex: currentPageIndex, chapterIndex: lastChapterIndex, lastChapterName:chapterName, totalChapter: chapters.count, picture: picture, categoryId: categoryId, author: author, timestamp: (Date().timeIntervalSince1970))
        var history = AppManager.shared.browseHistory
        if let idx = history.firstIndex(where: { $0.bookId == bookId }) {
            history[idx] = record
        } else {
            history.insert(record, at: 0)
        }
        let str = modelToJson(history)
        AppStorage.shared.setObject(str, forKey: .browseHistory)
        AppStorage.shared.synchronous()
        var bookcase = AppManager.shared.bookcase
        if let idx = bookcase.firstIndex(where: { $0.bookId == bookId }) {
            bookcase[idx] = record
            let str = modelToJson(bookcase)
            AppStorage.shared.setObject(str, forKey: .bookcase)
            AppStorage.shared.synchronous()
            NotificationCenter.default.post(name: SPNotification.bookcaseUpdate.name, object: nil)
        }
        
    }
    
    func addBookcase() {
        let record = BookRecord(bookId: bookId, bookName: bookName, pageIndex: currentPageIndex, chapterIndex: lastChapterIndex, lastChapterName: chapterName, totalChapter: chapters.count, picture: picture, categoryId: categoryId, author: author, timestamp: (Date().timeIntervalSince1970))
        var bookcase = AppManager.shared.bookcase
        bookcase.insert(record, at: 0)
        let str = modelToJson(bookcase)
        AppStorage.shared.setObject(str, forKey: .bookcase)
        AppStorage.shared.synchronous()
        NotificationCenter.default.post(name: SPNotification.bookcaseUpdate.name, object: nil)
        Toast.show("加入书架成功")
    }
    
    func showAddBookcase() -> Observable<Void> {
        let cancelAction = AlertAction.action(withTitle: "取消", action: { [unowned self] in
            saveRecord()
            sceneCoordinator.pop(animated: true)
        })
        let confirmAction = AlertAction.action(withTitle: "加入书架", action: { [unowned self] in
            saveRecord()
            addBookcase()
            sceneCoordinator.pop(animated: true)
        })
        let viewModel = AlertViewModel(message: "喜欢这本书就加入书架吧？", actions: [cancelAction, confirmAction])
        return sceneCoordinator.transition(to: Scene.alert(viewModel))
    }
    
    func bookcaseIncludeThisBook() -> Bool {
        var isInclude = false
        let books = AppManager.shared.bookcase
        isInclude = books.filter { $0.bookId == bookId }.count > 0
        return isInclude
    }
}
