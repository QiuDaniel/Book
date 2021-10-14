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
    case openAd
}

extension VendorKey: KeyType {
    var name: String {
        switch self {
        case .um:
            return "61505df67fc3a3059b218057"
        case .wechat:
            return "wxcea92d908e063bbd"
        case .openAd:
            #if DEBUG
            return "ca-app-pub-3940256099942544/5662855259"
            #else
            return "ca-app-pub-9695293248494413/5284552122"
            #endif
        }
    }
}
