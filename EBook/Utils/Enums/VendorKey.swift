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
    case settingBannerAd
    case searchBannerAd
    case bookIntroAd
}

extension VendorKey: KeyType {
    var name: String {
        switch self {
        case .um:
            return "61505df67fc3a3059b218057"
        case .wechat:
            return "wxcea92d908e063bbd"
       
#if DEBUG
        case .openAd:
            return "ca-app-pub-3940256099942544/5662855259"
        case .settingBannerAd:
            return "ca-app-pub-3940256099942544/2934735716"
        case .searchBannerAd:
            return "ca-app-pub-3940256099942544/2934735716"
        case .bookIntroAd:
            return "ca-app-pub-3940256099942544/2934735716"
#else
        case .openAd:
            return "ca-app-pub-9695293248494413/5284552122"
        case .settingBannerAd:
            return "ca-app-pub-9695293248494413/5806053038"
        case .searchBannerAd:
            return "ca-app-pub-9695293248494413/2862510718"
        case .bookIntroAd:
            return "ca-app-pub-9695293248494413/9906926055"
#endif
        
        }
    }
}
