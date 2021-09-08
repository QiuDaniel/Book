//
//  BookCategory.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/8.
//

import Foundation

struct BookCategory: Codable {
    let id: Int
    let name: String
    let picture: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case picture
    }
}
