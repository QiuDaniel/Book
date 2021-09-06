//
//  SearchHeat.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/5.
//

import Foundation

struct SearchHeat: Codable {
    let id: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
