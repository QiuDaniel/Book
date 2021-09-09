//
//  Chapter.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/9.
//

import Foundation

struct Chapter: Codable {
    let id: Int
    let bookId: Int
    let name: String
    let status: Int
    let sort: Int
    let contentUrl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case bookId
        case name
        case status
        case sort
        case contentUrl = "content_url"
    }
}
