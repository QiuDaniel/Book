//
//  BookTag.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/8.
//

import Foundation

struct BookTag: Codable {
    let id: Int
    let name: String
    let titlePicture: String
    let coverPicture: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case titlePicture
        case coverPicture
    }
}
