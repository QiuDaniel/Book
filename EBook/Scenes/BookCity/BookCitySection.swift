//
//  BookCitySection.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/8/20.
//

import Foundation
import Differentiator

enum BookCitySection {
    case bannerSection(items: [BookCitySectionItem])
    case categorySection(items: [BookCitySectionItem])
}

enum BookCitySectionItem {
    case bannerSectionItem(banners: [Banner])
    case categorySectionItem(cate: BookCityCate, books:[Book])
}

extension BookCitySection: SectionModelType {
    typealias Item = BookCitySectionItem
    
    var items: [BookCitySectionItem] {
        switch self {
        case .bannerSection(items: let items), .categorySection(items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: BookCitySection, items: [BookCitySectionItem]) {
        switch original {
        case .bannerSection:
            self = .bannerSection(items: items)
        case .categorySection:
            self = .categorySection(items: items)
        }
    }
}
