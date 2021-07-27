//
//  LocalizableHelper.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/20.
//

import Foundation

struct LocalizebleHelper {
    
    static var appLanguage: String {
        return AppStorage.shared.object(forKey: .localizable) as? String ?? "en"
    }
    
    static func initAppLanguage() {
        guard let languageCode = AppStorage.shared.object(forKey: .localizable) as? String, !languageCode.isEmpty else {
            if let regionCode = Locale.current.regionCode {
                let countryCode = String(format: "%@", regionCode)
                let code = Locale.preferredLanguages[0].replacingOccurrences(of: countryCode, with: "")
                AppStorage.shared.setObject(code, forKey: .localizable)
            } else {
                AppStorage.shared.setObject("en", forKey: .localizable)
            }
            AppStorage.shared.synchronous()
            return
        }
    }
    
    static func setupAppLanguage(_ language: String) {
        if language.isEmpty || self.appLanguage == language {
            return
        }
        AppStorage.shared.setObject(language, forKey: .localizable)
        AppStorage.shared.synchronous()
        NotificationCenter.default.post(name: SPNotification.languageChanged.name, object: nil)
    }
    
}
