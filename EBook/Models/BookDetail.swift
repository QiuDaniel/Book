//
//  BookDetail.swift
//  EBook
//
//  Created by Daniel on 2021/9/9.
//

import Foundation

struct BookDetail: Codable {
    let id: Int
    let name: String
    let pinyin: String
    let aliasName: String
    let protagonist: String
    let category: String
    let categoryId: Int
    let categoryName: String
    let author: String
    let aliasAuthor: String
    let bookType: Int
    let bookStatus: String
    let chapterNum: Int
    let createBy: String
    let intro: String
    let picture: String
    let status: Int
    let updateBy: String
    let wordNum: Int
    let createdTime: String
    let updatedTime: String
    let chapterId: Int
    let chapterName: String
    let chapterUpdateTime: String
    let chapterCountErr: Int
    let sourceBookId: Int
    let ruleId: Int
    let ruleName: String
    let heat: Int
    let pv: Int
    let score: Float
    let view: Int
    let bookshelf: Int
    let yesterday: Int
    let lastWeek: Int
    let lastMonth: Int
    let commentNum: Int
    let picturImages: String
    let tags: [Tag]
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case pinyin
        case aliasName
        case protagonist
        case category
        case categoryId
        case categoryName
        case author
        case aliasAuthor
        case bookType
        case bookStatus
        case chapterNum
        case createBy
        case intro
        case picture
        case status
        case updateBy
        case wordNum
        case createdTime
        case updatedTime
        case chapterId
        case chapterName
        case chapterUpdateTime
        case chapterCountErr
        case sourceBookId
        case ruleId
        case ruleName
        case heat
        case pv
        case score
        case view
        case bookshelf
        case yesterday
        case lastWeek
        case lastMonth
        case commentNum
        case picturImages = "pictur_images"
        case tags
    }

}

struct Tag: Codable {
    let tagId: Int
    let tagName: String
    
    enum CodingKeys: String, CodingKey {
        case tagId
        case tagName
    }
}

struct BookInfo {
    let detail: BookDetail
    let chapters: [Chapter]
}
