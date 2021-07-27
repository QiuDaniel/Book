//
//  UserinterfaceManager.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/16.
//

import Foundation

enum UserInterfaceStyle: Int {
    case system
    case light
    case dark
}

class UserinterfaceManager {
    
    var interfaceStyle: UserInterfaceStyle {
        get {
            return _interfaceStyle
        }
        
        set {
            _interfaceStyle = newValue
            AppManager.shared.userDefautls.set(newValue.rawValue, forKey: AppStoreKey.interfaceStyle)
            AppManager.shared.userDefautls.synchronize()
        }
    }
    
    private var _interfaceStyle: UserInterfaceStyle
    
    static let shared = UserinterfaceManager()
    
    private init() {
        if let styleValue = AppManager.shared.userDefautls.object(forKey: AppStoreKey.interfaceStyle) as? NSNumber, let style = UserInterfaceStyle(rawValue: styleValue.intValue)  {
            _interfaceStyle = style
        } else {
            _interfaceStyle = .system
            interfaceStyle = .system
        }
        
    }
}
