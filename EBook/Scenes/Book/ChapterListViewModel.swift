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

protocol ChapterListViewModelOutput {
    var sections: Observable<[SectionModel<String, Chapter>]> { get }
    var loading: Observable<Bool> { get }
}

protocol ChapterListViewModelType {
    var output: ChapterListViewModelOutput { get }
}

class ChapterListViewModel: ChapterListViewModelType, ChapterListViewModelOutput {
    
    var output: ChapterListViewModelOutput { return self }
    
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
                        if chapterNames.contains("\(chapter.id)") {
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
    
    lazy var loading: Observable<Bool> = {
        if chapters.count <= 0 {
            return .just(false)
        }
        let chapterPath = DefaultDownloadDir.path + "/\(chapters[0].bookId)" + "/chapter"
        if FileUtils.fileExists(atPath: chapterPath) {
            return .just(false)
        }
        let requests = chapters.prefix(3).map{ service.downloadChapter(bookId: $0.bookId, path: $0.contentUrl) }
        
        return Observable.zip(requests).map { paths in
            printLog("paths:\(paths)")
            return false
        }
    }()
    
    
    private let loadingProperty = BehaviorRelay<Bool>(value: false)
    private let sceneCoordinator: SceneCoordinatorType
    private let service: BookServiceType
    private let chapters: [Chapter]
    
    init(sceneCoordinator: SceneCoordinator = SceneCoordinator.shared, service: BookService = BookService(), chapters: [Chapter]) {
        self.sceneCoordinator = sceneCoordinator
        self.service = service
        self.chapters = chapters
    }
}

private extension ChapterListViewModel {
    
}
