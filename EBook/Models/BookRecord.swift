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
    let chapterName: String
    let totalChapter: Int
    let timestamp: String
}
