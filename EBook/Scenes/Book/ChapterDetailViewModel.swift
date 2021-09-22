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
    func readerProgressUpdate(curChapter curChapterIndex: Int, curPage: Int, totalPages: Int)
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
    
    func readerProgressUpdate(curChapter curChapterIndex: Int, curPage: Int, totalPages: Int) {
        guard let idx = realChapters.firstIndex(where: { $0.sort == curChapterIndex + 1 }) else {
            return
        }
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
        sceneCoordinator.transition(to: Scene.chapterList(ChapterListViewModel(book:book, chapters: chapters, catalog: catalog)))
    }
    
    func loadNewChapter(withIndex index: Int) {
        pageIndex = 1
        chapterIndexProperty.accept(index)
    }
    
    lazy var backAction: CocoaAction = {
        return CocoaAction { [unowned self] in
            return sceneCoordinator.pop(animated: true)
        }
    }()
    
    // MARK: - Output

    lazy var chapterList: Observable<([DUAChapterModel], Int, Int)> = {
        return chapterIndexProperty.asObservable().flatMapLatest { [unowned self] index -> Observable<([DUAChapterModel], Int, Int)> in
            guard let index = index else {
                return .empty()
            }
            return getChapterList(withStartIndex: index)
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
    private let loadingProperty = BehaviorRelay<Bool>(value: false)
    private let addChaptersProperty = BehaviorRelay<AdditionalChaptersWay>(value: .none)
    private let chapterIndexProperty = BehaviorRelay<Int?>(value: nil)
    private var notLoad = true
    private let sceneCoordinator: SceneCoordinatorType
    private let service: BookServiceType
    private let book: Book
    private let chapters: [Chapter]
    private var pageIndex: Int
    
#if DEBUG
    deinit {
        print("====dealloc=====\(self)")
    }
#endif
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: BookService = BookService(), book: Book, chapterIndex: Int, chapters:[Chapter], pageIndex: Int = 1) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
        self.book = book
        self.chapters = chapters
        self.pageIndex = pageIndex
        loading = loadingProperty.asObservable()
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
        
    func getChapterList(withStartIndex startIndex: Int) -> Observable<([DUAChapterModel], Int, Int)> {
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
}
