//
//  BookSearchSection.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/6.
//

import Foundation
import Differentiator

enum BookSearchSection {
    case hotSearchSection(title: String, items: [BookSearchSectionItem])
    case historySearchSection(title: String, items: [BookSearchSectionItem])
    case resultSearchSection(items: [BookSearchSectionItem])
}

enum BookSearchSectionItem {
    case hotSearchItem(name: String)
    case historySearchItem(name: String)
    case resultSearchItem(model: SearchModel)
}

extension BookSearchSection: SectionModelType {
    typealias Item = BookSearchSectionItem
    
    var items: [BookSearchSectionItem] {
        switch self {
        case .hotSearchSection(title: _, items: let items),
             .historySearchSection(title: _, items: let items),
             .resultSearchSection(items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: BookSearchSection, items: [BookSearchSectionItem]) {
        switch original {
        case let .historySearchSection(title: title, items: _):
            self = .historySearchSection(title: title, items: items)
        case let .hotSearchSection(title: title, items: _):
            self = .hotSearchSection(title: title, items: items)
        case let .resultSearchSection:
            self = .resultSearchSection(items: items)
        }
    }
}
