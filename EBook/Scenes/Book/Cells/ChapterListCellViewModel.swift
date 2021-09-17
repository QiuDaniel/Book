//
//  ChapterListCellViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/13.
//

import Foundation
import RxSwift
import RxCocoa

protocol ChapterListCellViewModelInput {
    func changeChapterNameColor(_ color: UIColor?)
}

protocol ChapterListCellViewModelOutput {
    var chapterName: Observable<String> { get }
    var chapterNameColor: Observable<UIColor?> { get }
}

protocol ChapterListCellViewModelType {
    var input: ChapterListCellViewModelInput { get }
    var output: ChapterListCellViewModelOutput { get }
}

class ChapterListCellViewModel: ChapterListCellViewModelType, ChapterListCellViewModelOutput, ChapterListCellViewModelInput {
    var input: ChapterListCellViewModelInput { return self }
    var output: ChapterListCellViewModelOutput { return self }
    
    // MARK: - Input
    
    func changeChapterNameColor(_ color: UIColor?) {
        colorProperty.accept(color)
    }
    
    // MARK: - Output

    lazy var chapterName: Observable<String> = {
        return .just(chapter.name)
    }()

    let chapterNameColor: Observable<UIColor?>
    
    private let colorProperty = BehaviorRelay<UIColor?>(value: R.color.b1e3c()?.withAlphaComponent(0.5))
    private let chapter: Chapter
    
    init(chapter: Chapter) {
        self.chapter = chapter
        chapterNameColor = colorProperty.asObservable()
        colorProperty.accept((chapter.isDownload ?? false ) ? R.color.b1e3c() : R.color.b1e3c()?.withAlphaComponent(0.5))
    }
}
