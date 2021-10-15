//
//  BookRecord.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/18.
//

import Foundation

struct BookRecord: Codable {
    let bookId: Int
    let bookName: String
    let pageIndex: Int
    let chapterIndex: Int
    let lastChapterName: String
    let totalChapter: Int
    let picture: String
    let categoryId: Int
    let author: String
    var timestamp: TimeInterval
    
    mutating func changeTimestamp(_ timestamp: TimeInterval) {
        self.timestamp = timestamp
    }
}


