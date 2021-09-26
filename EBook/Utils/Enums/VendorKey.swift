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
            return "61505df67fc3a3059b218057"
        case .wechat:
            return "wxcea92d908e063bbd"
        }
    }
}
