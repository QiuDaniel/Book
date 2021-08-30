//
//  SearchResult.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/8/20.
//

import Foundation

struct SearchResult: Codable {
    let list: [SearchBook]
    let extra: Extra
    let count: Int
    let pageIndex: Int
    let pageSize: Int
    
    enum CodingKeys: String, CodingKey {
        case list
        case extra
        case count
        case pageIndex
        case pageSize
    }
}

struct Extra: Codable {
    let weeknew: Int
    
    enum CodingKeys: String, CodingKey {
        case weeknew
    }
}

struct SearchBook: Codable {
    let bookId: Int
    let name: String
    let aliasName: String
    let protagonist: String
    let categoryId: Int
    let categoryName: String
    let author: String
    let aliasAuthor: String
    let bookType: Int
    let bookStatus: String
    let chapterNum: Int
    let intro: String
    let picture: String
    let status: Int
    let wordNum: Int
    let score: Float
    let chapterName: String
    let chapterUpdateTime: String
    
    enum CodingKeys: String, CodingKey {
        case bookId
        case name
        case aliasName
        case protagonist
        case categoryId
        case categoryName
        case author
        case aliasAuthor
        case bookType
        case bookStatus
        case chapterNum
        case intro
        case picture
        case status
        case wordNum
        case score
        case chapterName
        case chapterUpdateTime
    }
}
