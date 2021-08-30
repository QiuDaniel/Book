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
}

enum BookCitySectionItem {
    case bannerSectionItem(banners: [Banner])
}

extension BookCitySection: SectionModelType {
    typealias Item = BookCitySectionItem
    
    var items: [BookCitySectionItem] {
        switch self {
        case .bannerSection(items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: BookCitySection, items: [BookCitySectionItem]) {
        switch original {
        case .bannerSection:
            self = .bannerSection(items: items)
        }
    }
}
