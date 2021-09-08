//
//  App.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/19.
//

import UIKit
import AdSupport

public enum iPhoneModel {
    case small
    case normal
    case plus
    case x
}

public struct App {
    public static var appName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String
    }
    
    public static var appVersion: String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    }
    
    public static var appBuild: String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }
    
    public static var bundleIdentifier: String {
        return Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
    }
    
    public static var bundleName: String {
        return Bundle.main.infoDictionary!["CFBundleName"] as! String
    }
    
    public static var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    public static var appStoreURL: URL {
        return URL(string: "your URL")!
    }
    
    
    public static var IDFA: String {
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    public static var IDFV: String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    public static var screenOrientation: UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            return window?.windowScene?.interfaceOrientation ?? .portrait
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
    
    public static var screenStatusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
    
    public static var naviBarHeight: CGFloat {
        return screenStatusBarHeight + 44.0
    }
    
    public static var tabBarHeight: CGFloat {
        return 49.0 + iPhoneBottomSafeHeight
    }
    
    public static var screenHeightWithoutStatusBar: CGFloat {
        if UIInterfaceOrientation.portrait.isPortrait {
            return UIScreen.main.bounds.size.height - screenStatusBarHeight
        } else {
            return UIScreen.main.bounds.size.width - screenStatusBarHeight
        }
    }
    
    public static var screenWidth: CGFloat {
        if UIInterfaceOrientation.portrait.isPortrait {
            return UIScreen.main.bounds.size.width
        } else {
            return UIScreen.main.bounds.size.height
        }
    }
    
    public static var screenHeight: CGFloat {
        if UIInterfaceOrientation.portrait.isPortrait {
            return UIScreen.main.bounds.size.height
        } else {
            return UIScreen.main.bounds.size.width
        }
    }
    
    public static var screenScale:CGFloat {
        return UIScreen.main.scale
    }
    
    public static var lineHeight:CGFloat {
        return 1.0 / screenScale
    }
    
    public static var screenBounds:CGRect {
        return UIScreen.main.bounds
    }
    
    public static var model: iPhoneModel {
        let height = UIScreen.main.nativeBounds.size.height
        if height == 2778 || height == 2532 || height == 1792 || height == 2688 || height == 2436 || height == 2340 {
            return .x
        } else if height == 2208 {
            return .plus
        } else if height == 1136 {
            return .small
        } else {
            return .normal
        }
    }
    
    public static var isModelSmall: Bool {
        return self.model == .small
    }
    
    public static var isModelX: Bool {
        return self.model == .x
    }
    
    public static var iPhoneBottomSafeHeight : CGFloat {
        
        return self.model == .x ? 34 : 0
    }
    
    public static var iPhoneTopSafeHeight : CGFloat {
        return self.model == .x ? screenStatusBarHeight : 0
    }
    
    static var channel: String {
        #if DEBUG
        return "DEBUG"
        #else
        return "App Store"
        #endif
    }
    
    static var type: String {
        return "iPhone"
    }
    
    static var appId: String {
        return "58"
    }
    
}
