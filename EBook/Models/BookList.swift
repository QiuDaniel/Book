//
//  CategoryList.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/9.
//

import Foundation

struct BookList: Codable {
    let list: [Book]
    let totalPage: Int
    
    enum CodingKeys: String, CodingKey {
        case list
        case totalPage = "total_page"
    }
}
