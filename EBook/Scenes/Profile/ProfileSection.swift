//
//  ProfileSection.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/29.
//

import Foundation
import Differentiator


enum ProfileSection {
    case normalFunctionSection(items: [ProfileSectionItem])
    case otherSection(items: [ProfileSectionItem])
}

enum ProfileSectionItem {
    case normalFunctionItem(index: Int)
    case otherItem(index: Int)
}

extension ProfileSection: SectionModelType {
    typealias Item = ProfileSectionItem
    
    var items: [ProfileSectionItem] {
        switch self {
        case .normalFunctionSection(items: let items),
             .otherSection(items: let items):
            return items.map { $0 }
        }
    }
    
    init(original: ProfileSection, items: [ProfileSectionItem]) {
        switch original {
        case .normalFunctionSection:
            self = .normalFunctionSection(items: items)
        case .otherSection:
            self = .otherSection(items: items)
        }
    }
}
