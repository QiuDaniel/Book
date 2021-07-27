//
//  Banner.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import Foundation

struct Banner: Codable {
    let id: Int
    let appId: Int
    let name: String
    let pictureUrl: String
    let jumpUrl: String
    let gender: Int
    let state: Int
    let createBy: String
    let updateBy: String
    let dataScope: String
    let params: String
    let createdAt: String
    let updatedAt: String
    let createdTime: String
    let updatedTime: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case appId
        case name
        case pictureUrl
        case jumpUrl
        case gender
        case state
        case createBy
        case updateBy
        case dataScope
        case params
        case createdAt
        case updatedAt
        case createdTime
        case updatedTime
    }
}
