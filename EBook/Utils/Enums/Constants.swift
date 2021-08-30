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
    case staticDomain
    case pkgName
}

extension Constants: ConstantsType {
    var value: String {
        switch self {
        case .host:
            return "https://api.quduapp.com"
        case .staticDomain:
            if let domain = AppStorage.shared.object(forKey: .staticDomain) as? String {
                return domain
            }
            return "http://statics.rungean.com"
        case .pkgName:
            return "com.quduqb.yueduqi"
        }
    }
    
}
