//
//  AppConfig.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/28.
//

import Foundation

struct AppConfig: Codable {
    let staticDomain: String
    let appId: String
    let pkgName: String
    let openGg: Int
    let settingGg: Int
    let bookGg: Int
    let bookshelfGg: Int
}
