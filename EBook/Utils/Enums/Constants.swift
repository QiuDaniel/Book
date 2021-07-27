//
//  Constants.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/19.
//

import Foundation

protocol ConstantsType {
    var value: String { get }
}

enum Constants {
    case host
    case accountHost
    case walletHost
    case chainHost
    case appHost
    case masterHost
}

extension Constants: ConstantsType {
    var value: String {
        switch self {
        case .host:
            return "https://oauth-app.sparkpool.com"
        case .accountHost:
            return "https://account.sparkpool.com"
        case .chainHost:
            return "https://www.sparkpool.com"
        case .walletHost:
            return "https://wallet.sparkpool.com"
        case .appHost:
            return "https://api-app.sparkpool.com"
        case .masterHost:
            return "https://apimaster.sparkpool.com"
        }
    }
    
}
