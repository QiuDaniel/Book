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

    private let chapter: Chapter
    
    init(chapter: Chapter) {
        self.chapter = chapter
    }
}
