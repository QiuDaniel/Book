//
//  ChapterDetailViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/9/14.
//

import Foundation
import RxSwift
import RxCocoa

protocol ChapterDetailViewModelInput {
    func readerProgressUpdate(curChapter curChapterIndex: Int, curPage: Int, totalPages: Int)
    func readerStateChanged(_ state: DUAReaderState)
    func userInterfaceChanged(_ dark: Bool)
}

protocol ChapterDetailViewModelOutput {
    var chapterList: Observable<([DUAChapterModel], Int)> { get }
    var loading: Observable<Bool> { get }
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
    
    let loading: Observable<Bool>
    
    private let loadingProperty = BehaviorRelay<Bool>(value: false)
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
    func getChapterList() -> Observable<([DUAChapterModel], Int)> {
        let chapterPath = DefaultDownloadDir.path + "/\(chapters[0].bookId)" + "/chapter"
        let selectChapter = chapters[chapterIndex]
        let afterChapters = Array(chapters.dropFirst(chapterIndex + 1).prefix(5))
        let beforeChapters = Array(chapters.prefix(chapterIndex).suffix(3))
        let realChapters = beforeChapters + [selectChapter] + afterChapters
        let idx = realChapters.firstIndex(where: { $0.id == selectChapter.id })
        let requests = realChapters.filter{ !($0.isDownload ?? false) }.map{ service.downloadChapter(bookId: $0.bookId, path: $0.contentUrl) }
        if requests.count > 0 {
            notLoad = true
            loadingProperty.accept(true)
            return Observable.zip(requests).map { [unowned self] paths in
                loadingProperty.accept(false)
                paths.filter{ $0 != nil }.forEach { path in
                    if path != nil {
                        let localLocation = URL(fileURLWithPath: path!)
                        let targetPath = chapterPath + "/\(localLocation.lastPathComponent)"
                        let assertName = localLocation.lastPathComponent.replacingOccurrences(of: localLocation.pathExtension, with: "").replacingOccurrences(of: ".", with: "")
                        if FileUtils.moveFile(source: path!, target: targetPath) {
                            let chapter = realChapters.first(where: { "\($0.id)" == assertName })
                            chapter?.isDownload = true
                        }
                    }
                }
                return (realChapters.map { DUAChapterModel(title: $0.name, path: chapterPath + "/\($0.id).txt", chapterIndex: $0.sort - 1) }, idx ?? 0)
            }
        }
        return .just((realChapters.map { DUAChapterModel(title: $0.name, path: chapterPath + "/\($0.id).txt", chapterIndex: $0.sort - 1) }, idx ?? 0))
    }
}
