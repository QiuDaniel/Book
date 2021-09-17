//
//  ChapterDetailViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/9/14.
//

import Foundation
import RxSwift
import RxCocoa

enum AdditionalChaptersWay {
    case tail
    case head
    case none
}

protocol ChapterDetailViewModelInput {
    func readerProgressUpdate(curChapter curChapterIndex: Int, curPage: Int, totalPages: Int)
    func readerStateChanged(_ state: DUAReaderState)
    func userInterfaceChanged(_ dark: Bool)
}

protocol ChapterDetailViewModelOutput {
    var chapterList: Observable<([DUAChapterModel], Int)> { get }
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
        if idx == realChapters.count - 2 && curChapterIndex > lastChapterIndex { // 向后加载到倒数第一个，下载新chapter并预加载
            printLog("向后加载到倒数第一个")
            addChaptersProperty.accept(.tail)
        } else if idx == 1 && curChapterIndex < lastChapterIndex { //向前加载到第二个, 下载新chapter并预加载
            printLog("向前加载到第二个")
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
    
    // MARK: - Output

    lazy var chapterList: Observable<([DUAChapterModel], Int)> = {
        return getChapterList()
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
    private var notLoad = true
    private let service: BookServiceType
    private let chapterIndex: Int
    private let chapters: [Chapter]
    
    init(service: BookService = BookService(), chapterIndex: Int, chapters:[Chapter]) {
        self.service = service
        self.chapterIndex = chapterIndex
        self.chapters = chapters
        loading = loadingProperty.asObservable()
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
                paths.filter{ $0 != nil }.map{ $0! }.forEach { path in
                    let localLocation = URL(fileURLWithPath: path)
                    let targetPath = chapterPath + "/\(localLocation.lastPathComponent)"
                    let assertName = localLocation.lastPathComponent.replacingOccurrences(of: localLocation.pathExtension, with: "").replacingOccurrences(of: ".", with: "")
                    if FileUtils.moveFile(source: path, target: targetPath) {
                        if let chapter = chapters.first(where: { "\($0.id)" == assertName }) {
                            chapter.isDownload = true
                        } else {
                            printLog("===warning======!!!!!!!!, chapter 未找到")
                        }
                    }
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
    
    func getChapterList() -> Observable<([DUAChapterModel], Int)> {
        let chapterPath = DefaultDownloadDir.path + "/\(chapters[0].bookId)" + "/chapter"
        let selectChapter = chapters[chapterIndex]
        let afterChapters = Array(chapters.dropFirst(chapterIndex + 1).prefix(5))
        let beforeChapters = Array(chapters.prefix(chapterIndex).suffix(3))
        realChapters = beforeChapters + [selectChapter] + afterChapters
        let idx = selectChapter.sort - 1
        lastChapterIndex = idx;
        let requests = realChapters.filter{ !($0.isDownload ?? false) }.map{ service.downloadChapter(bookId: $0.bookId, path: $0.contentUrl) }
        if requests.count > 0 {
            notLoad = true
            loadingProperty.accept(true)
            return Observable.zip(requests).map { [unowned self] paths in
                loadingProperty.accept(false)
                paths.filter{ $0 != nil }.map { $0! }.forEach { path in
                    let localLocation = URL(fileURLWithPath: path)
                    let targetPath = chapterPath + "/\(localLocation.lastPathComponent)"
                    let assertName = localLocation.lastPathComponent.replacingOccurrences(of: localLocation.pathExtension, with: "").replacingOccurrences(of: ".", with: "")
                    printLog("已下载的chapter id:\(assertName)\n")
                    if FileUtils.moveFile(source: path, target: targetPath) {
                        if let chapter = chapters.first(where: { "\($0.id)" == assertName }) {
                            chapter.isDownload = true
                        } else {
                            printLog("===warning======!!!!!!!!, chapter 未找到")
                        }
                        
                    }
                }
                return (chapters.map { DUAChapterModel(title: $0.name, path: ($0.isDownload ?? false) ? chapterPath + "/\($0.id).txt" : nil, chapterIndex: $0.sort - 1) }, idx)
            }
        }
        return .just((chapters.map { DUAChapterModel(title: $0.name, path: ($0.isDownload ?? false) ? chapterPath + "/\($0.id).txt" : nil, chapterIndex: $0.sort - 1) }, idx))
    }
}
