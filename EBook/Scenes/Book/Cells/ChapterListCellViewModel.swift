//
//  ChapterListCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/13.
//

import Foundation
import RxSwift

protocol ChapterListCellViewModelOutput {
    var chapterName: Observable<String> { get }
    var chapterNameColor: Observable<UIColor?> { get }
}

protocol ChapterListCellViewModelType {
    var output: ChapterListCellViewModelOutput { get }
}

class ChapterListCellViewModel: ChapterListCellViewModelType, ChapterListCellViewModelOutput {
    var output: ChapterListCellViewModelOutput { return self }
    
    // MARK: - Output

    lazy var chapterName: Observable<String> = {
        return .just(chapter.name)
    }()
    
    lazy var chapterNameColor: Observable<UIColor?> = {
        guard let isDownload = chapter.isDownload else {
            return .just(R.color.b1e3c()?.withAlphaComponent(0.5))
        }
        return .just(isDownload ? R.color.b1e3c() : R.color.b1e3c()?.withAlphaComponent(0.5))
    }()

    private let chapter: Chapter
    
    init(chapter: Chapter) {
        self.chapter = chapter
    }
}
