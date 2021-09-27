//
//  ChapterEndViewModel.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/27.
//

import Foundation

protocol ChapterEndViewModelOutput {
    
}

protocol ChapterEndViewModelType {
    var output: ChapterEndViewModelOutput { get }
}

class ChapterEndViewModel: ChapterEndViewModelType, ChapterEndViewModelOutput {
    var output: ChapterEndViewModelOutput { return self }
}
