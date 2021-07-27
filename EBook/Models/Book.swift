//
//  Book.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import Foundation

struct Book: Codable {
    let id: Int
    let name: String
    let picture: String
    let score: Decimal
    let intro: String
    let bookType: Int
    let wordNum: Int
    let author: String
    let aliasAuthor: String
    let protagonist: String
    let categoryId: Int
    let categoryName: String
    let zipurl: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case picture
        case score
        case intro
        case bookType
        case wordNum
        case author
        case aliasAuthor
        case protagonist
        case categoryId
        case categoryName
        case zipurl
    }
}
