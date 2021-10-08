//
//  FindBook.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/10/8.
//

import Foundation

struct FindBook: Codable {
    let bookName: String
    let appId: Int
    let platformId: Int
    let device: String
    let createBy: String
    let id: Int
    let keyword: String
    let memberId: Int
    let status: Int
    let updateBy: String
    let dataScope: String
    let params: String
    let createdAt: String
    let updatedAt: String
    let createdTime: String
    let updatedTime: String
}
