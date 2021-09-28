//
//  ChapterEndSetion.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/28.
//

import Foundation
import Differentiator

enum ChapterEndSection {
    case bookEndSection(items: [ChapterEndSectionItem])
    case bookReleationSection(items: [ChapterEndSectionItem])
}

enum ChapterEndSectionItem {
    case bookEndItem(book: BookDetail)
    case bookReleationItem(book: Book)
}

extension ChapterEndSection: SectionModelType {
    typealias Item = ChapterEndSectionItem
    
    var items: [ChapterEndSectionItem] {
        switch self {
        case .bookEndSection(items: let items),
             .bookReleationSection(items: let items):
            return items.map{ $0 }
        }
    }
    
    init(original: ChapterEndSection, items: [ChapterEndSectionItem]) {
        switch original {
        case .bookEndSection:
            self = .bookEndSection(items: items)
        case .bookReleationSection:
            self = .bookReleationSection(items: items)
        }
    }
}
