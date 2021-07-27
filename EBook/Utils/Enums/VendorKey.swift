//
//  VendorKey.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/19.
//

import Foundation

protocol KeyType {
    var name: String { get}
}

enum VendorKey {
    case um
    case wechat
}

extension VendorKey: KeyType {
    var name: String {
        switch self {
        case .um:
            return "608f601053b6726499e936f9"
        case .wechat:
            return "wxcea92d908e063bbd"
        }
    }
}
