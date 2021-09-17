//
//  ChapterListViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/13.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa
import Action

protocol ChapterListViewModelInput {
    var itemAction: Action<Chapter, Void> { get }
}


protocol ChapterListViewModelOutput {
    var sections: Observable<[SectionModel<String, Chapter>]> { get }
    var loading: Observable<Bool> { get }
    var scrollIndex: Observable<Int> { get }
}

protocol ChapterListViewModelType {
    var input: ChapterListViewModelInput { get }
    var output: ChapterListViewModelOutput { get }
}

class ChapterListViewModel: ChapterListViewModelType, ChapterListViewModelOutput, ChapterListViewModelInput {
    var input: ChapterListViewModelInput { return self }
    var output: ChapterListViewModelOutput { return self }
    
    // MARK: - Input
    
    lazy var itemAction: Action<Chapter, Void> = {
        return Action() { [unowned self] chapter in
            let idx = chapters.firstIndex(where: { $0.id == chapter.id })
            guard let catalog = catalog else {
                return sceneCoordinator.transition(to: Scene.chapterDetail(ChapterDetailViewModel(chapterIndex: idx ?? 0, chapters: chapters)))
            }
            catalog.index = idx ?? NSNotFound
            return sceneCoordinator.pop(animated: true)
        }
    }()
    
    // MARK: - Output
    //https://www.jianshu.com/p/f527fbbd8a78  // UILabel 加载html
    lazy var sections: Observable<[SectionModel<String, Chapter>]> = {
        
        if chapters.count > 0 {
            let chapterPath = DefaultDownloadDir.path + "/\(chapters[0].bookId)" + "/chapter"
            if !FileUtils.fileExists(atPath: chapterPath) {
                let requests = chapters.prefix(3).map{ service.downloadChapter(bookId: $0.bookId, path: $0.contentUrl) }
                loadingProperty.accept(true)
                return Observable.zip(requests).map { [unowned self] paths in
                    loadingProperty.accept(false)
                    paths.filter{ $0 != nil }.forEach { path in
                        if path != nil {
                            let localLocation = URL(fileURLWithPath: path!)
                            let targetPath = chapterPath + "/\(localLocation.lastPathComponent)"
                            let assertName = localLocation.lastPathComponent.replacingOccurrences(of: localLocation.pathExtension, with: "").replacingOccurrences(of: ".", with: "")
                            if FileUtils.moveFile(source: path!, target: targetPath) {
                                let chapter = chapters.first(where: { "\($0.id)" == assertName })
                                chapter?.isDownload = true
                            }
                        }
                    }
                    return [SectionModel(model: "", items: chapters)]
                }
            } else {
                printLog("list file:\(String(describing: FileUtils.listFolder(chapterPath)))")
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
            }
            return .just([SectionModel(model: "", items: chapters)])

        }
        return .just([SectionModel(model: "", items: [])])
    }()
    
    let loading: Observable<Bool>
    let scrollIndex: Observable<Int>
    
    private let indexProperty = BehaviorRelay<Int?>(value: nil)
    private let loadingProperty = BehaviorRelay<Bool>(value: false)
    private let sceneCoordinator: SceneCoordinatorType
    private let service: BookServiceType
    private let chapters: [Chapter]
    private var catalog: CatalogModel?
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: BookService = BookService(), chapters: [Chapter], catalog: CatalogModel? = nil) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
        self.chapters = chapters
        self.catalog = catalog
        loading = loadingProperty.asObservable()
        scrollIndex = indexProperty.asObservable().unwrap()
        if let index = catalog?.index, index != NSNotFound {
            indexProperty.accept(index)
        }
    }
}

private extension ChapterListViewModel {
    
}
