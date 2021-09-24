//
//  BookIntroSection.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/10.
//

import Foundation
import Differentiator

enum BookIntroSection {
    case bookBlankSection(items: [BookIntroSectionItem])
    case bookInfoSection(items:[BookIntroSectionItem])
    case bookIndexSection(items:[BookIntroSectionItem])
    case bookTagSection(items:[BookIntroSectionItem])
    case bookDescSection(items:[BookIntroSectionItem])
    case bookCatalogSection(items: [BookIntroSectionItem])
    case bookReleationSection(items:[BookIntroSectionItem])
    case bookAuthorSection(items: [BookIntroSectionItem])
    case bookCopyrightSection(items: [BookIntroSectionItem])
}

enum BookIntroSectionItem {
    case bookBlankItem
    case bookInfoItem(detail: BookDetail)
    case bookIndexItem(detail: BookDetail)
    case bookTagItem(tags: [Tag])
    case bookDescItem(detail: BookDetail)
    case bookCatalogItem(info: BookInfo)
    case bookReleationItem(book: Book)
    case bookAuthorItem(book: Book)
    case bookCopyrightItem(detail: BookDetail)
}

extension BookIntroSection: SectionModelType {
    typealias Item = BookIntroSectionItem
    
    var items: [BookIntroSectionItem] {
        switch self {
        case .bookBlankSection(items: let items),
             .bookInfoSection(items: let items),
             .bookIndexSection(items: let items),
             .bookTagSection(items: let items),
             .bookDescSection(items: let items),
             .bookCatalogSection(items: let items),
             .bookReleationSection(items: let items),
             .bookAuthorSection(items: let items),
             .bookCopyrightSection(items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: BookIntroSection, items: [BookIntroSectionItem]) {
        switch original {
        case .bookBlankSection:
            self = .bookBlankSection(items: items)
        case .bookInfoSection:
            self = .bookInfoSection(items: items)
        case .bookIndexSection:
            self = .bookIndexSection(items: items)
        case .bookTagSection:
            self = .bookTagSection(items: items)
        case .bookDescSection:
            self = .bookDescSection(items: items)
        case .bookCatalogSection:
            self = .bookCatalogSection(items: items)
        case .bookReleationSection:
            self = .bookReleationSection(items: items)
        case .bookAuthorSection:
            self = .bookAuthorSection(items: items)
        case .bookCopyrightSection:
            self = .bookCopyrightSection(items: items)
        }
    }
}
