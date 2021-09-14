//
//  ChapterDetailViewModel.swift
//  EBook
//
//  Created by Daniel on 2021/9/14.
//

import Foundation

protocol ChapterDetailViewModelOutput {
    
}

protocol ChapterDetailViewModelType {
    var output: ChapterDetailViewModelOutput { get }
}

class ChapterDetailViewModel: ChapterDetailViewModelType, ChapterDetailViewModelOutput {
    
    var output: ChapterDetailViewModelOutput { return self }
    
    // MARK: - Output
    
    private let service: BookServiceType
    private let chapterIndex: Int
    private let chapters: [Chapter]
    
    init(service: BookService = BookService(), chapterIndex: Int, chapters:[Chapter]) {
        self.service = service
        self.chapterIndex = chapterIndex
        self.chapters = chapters
    }
    
}
