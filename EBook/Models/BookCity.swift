//
//  BookCityCate.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import Foundation

struct BookCityCate: Codable {
    let id: Int
    let types: Int
    let name: String
    let staticPath: String
    let listStaticPath: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case types
        case name
        case staticPath
        case listStaticPath
    }
}

struct BookCity: Codable {
    let female: [BookCityCate]
    let male: [BookCityCate]
    
    enum CodingKeys: String, CodingKey {
        case female
        case male
    }
}
