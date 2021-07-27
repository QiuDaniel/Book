//
//  AppStorage.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/20.
//

import Foundation


enum AppStorageKey: Int {
    case `default` = 0
    case netEvn
    case searchHistory
    case searchCurrency
    case tabSelected
    case wallet
    case minerPopup
    case notices
    case rigSortStatus
    case tokenPageInfo
    case updateClickDate
    case workerGuideFirstShow
    case minerGuideFirstShow
    case addressGuideFirstShow
    case launchImage
    case launchImageEN
    case subAccount
    case walletBizType
    case walletBizTypeEN
    case poolIncomeMean
    case localizable
    case localizableFilePath
    case localizableFilePathEN
    case codeFilePath
    case codeFilePathEN
    case monetaryUnit
    case localizableVersion
    case currentFiat
    case minerSegmentSelected
    case tabBarBadgeFirstShow
    case submitReqeustBadgeFirstShow // 提交工单，提交工单红点第一次显示 , 1.17.0后不再显示
    case sparkPoolBubbleFirstShow
    case cryptoCurrencyInfo
    case appUser//存储用户信息
    case appToken //存储token
    case appTokenSaveTime//token存储时间
    case appMinerConditionKey //矿机搜索条件
    case currencySelectd //币种详情选择
    case hotRigSortStatus // 热门矿机排序配置
    case hotRigElectricityPrice //电价配置
    case hotRigCurrency //热门矿机币种
    case workerNewGuideFirstShow // 矿机新引导第一次出现
    case widgetBadgeFirstShow // 小组件设置第一次显示
    case followAnnouncementShow // 匿名挖矿提
    case globalConfigCount
}

class AppStorage: NSObject {
    static let shared = AppStorage()
    private let configKey: [NSString] = ["default",
                             "kNetEvn",
                             "kSearchHistory",
                             "kSearchCurrency",
                             "kTabSelected",
                             "kWallet",
                             "kMinerPopup",
                             "kNotices",
                             "kRigSortStatus",
                             "kTokenPageInfo",
                             "kUpdateClickDate",
                             "kWorkerGuideFirstShow",
                             "kMinerGuideFirstShow",
                             "kAddressGuideFirstShow",
                             "kLaunchImage",
                             "kLaunchImageEN",
                             "kSubAccount",
                             "kWalletBizType",
                             "kWalletBizTypeEN",
                             "kPoolIncomeMean",
                             "kLocalizable",
                             "kLocalizableFilePath",
                             "kLocalizableFilePathEN",
                             "kCodeFilePath",
                             "kCodeFilePathEN",
                             "kMonetaryUnit",
                             "kLocalizableVersion",
                             "kCurrentFiat",
                             "kMinerSegmentSelected",
                             "kTabBarBadgeFirstShow",
                             "kSubmitReqeustBadgeFirstShow",
                             "kSparkPoolBubbleFirstShow",
                             "kCryptoCurrencyInfo",
                             "kAppUser",
                             "kAppToken",
                             "kAppTokenSaveTime",
                             "kAppMinerConditionKey",
                             "kCurrencySelectd",
                             "kHotRigSortStatus",
                             "kHotRigElectricityPrice",
                             "kHotRigCurrency",
                             "kWorkerNewGuideFirstShow",
                             "kWidgetBadgeFirstShow",
                             "kFollowAnnouncementShow",]
    private var configDict: NSMutableDictionary?
    private var filePath = ""
    private var needSave = false
    private var autoSave = false
       
    deinit {
        if needSave {
            needSave = false
            let data = try! NSKeyedArchiver.archivedData(withRootObject: configDict!, requiringSecureCoding: false);
            try! data.write(to: URL(fileURLWithPath: filePath))
        }
    }
       
    override init() {
        super.init()
        autoreleasepool {
            if let documentFile = documentFilePath() {
                filePath = documentFile.appending("/GlobalConfig.data")
            }
            open()
            needSave = false
            autoSave = bool(forKey: .default)
            setDefault("ETH", forKey: .searchCurrency)
            setDefault("ETH", forKey: .currencySelectd)
            setDefault("ETH", forKey: .hotRigCurrency)
            setDefault(0, forKey: .rigSortStatus)
            setDefault(3, forKey: .tabSelected)
            setDefault(1, forKey: .workerGuideFirstShow)
            setDefault(1, forKey: .minerGuideFirstShow)
            setDefault(1, forKey: .addressGuideFirstShow)
            setDefault(0, forKey: .poolIncomeMean)
            setDefault("1.0", forKey: .localizableVersion)
            setDefault(2, forKey: .netEvn)
            setDefault(0, forKey: .minerSegmentSelected)
            setDefault(1, forKey: .tabBarBadgeFirstShow)
            setDefault(0, forKey: .submitReqeustBadgeFirstShow)
            setDefault(1, forKey: .sparkPoolBubbleFirstShow)
            setDefault(0, forKey: .hotRigSortStatus)
            setDefault(1, forKey: .workerNewGuideFirstShow)
            setDefault(1, forKey: .widgetBadgeFirstShow)
            setDefault(0, forKey: .followAnnouncementShow)
            let electricityFilePath = Bundle.main.path(forResource: "Electricity", ofType: "plist")!
            let electricity = NSDictionary(contentsOfFile: electricityFilePath)
            setDefault(electricity, forKey: .hotRigElectricityPrice)
        }
    }
       
    // MARK: - Public
       
    func setObject(_ object: Any?, forKey key: AppStorageKey) {
        if key.rawValue >= AppStorageKey.globalConfigCount.rawValue  {
            return
        }
           
        let keyValue = configKey[key.rawValue]
        if object != nil {
            synchronized(configDict!) {
                configDict!.setObject(object!, forKey: keyValue)
            }
        } else {
            synchronized(configDict!) {
                configDict!.removeObject(forKey: keyValue)
            }
        }
        needSave = true
        if autoSave {
            synchronous()
        }
    }
       
    func object(forKey key:AppStorageKey) -> Any? {
        if key.rawValue >= AppStorageKey.globalConfigCount.rawValue  {
            return nil
        }
        let keyValue = configKey[key.rawValue]
        return configDict!.object(forKey: keyValue)
    }
       
    func bool(forKey key: AppStorageKey) -> Bool {
        if key.rawValue >= AppStorageKey.globalConfigCount.rawValue  {
            return false
        }
        guard let value = object(forKey: key) else { return false }
        if let value = value as? NSNumber {
            return value.boolValue
        }
        if let value = value as? Bool {
            return value
        }
        return false
    }
       
    func synchronous() {
        guard needSave else {
            return
        }
           
        DispatchQueue.main.async {
            self.needSave = false
            if let configDict = self.configDict {
                let data = try! NSKeyedArchiver.archivedData(withRootObject: configDict, requiringSecureCoding: false);
                try! data.write(to: URL(fileURLWithPath: self.filePath))
            }
        }
    }
       
    func autoSynchronous(_ isAuto: Bool) {
        if autoSave == isAuto {
            return
        }
        autoSave = isAuto
        setObject(NSNumber(value: isAuto), forKey: .default)
    }
       
       //MARK: - Private
       
       private func documentFilePath() -> String? {
           return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
       }
       
       private func open() {
           let fileMgr = FileManager.default
           if fileMgr.fileExists(atPath: filePath) {
                let url = URL(fileURLWithPath: filePath)
                let data = try! Data(contentsOf: url)
                let classSet = NSSet(objects: NSDictionary.self, NSString.self, NSArray.self)
                configDict = try! NSKeyedUnarchiver.unarchivedObject(ofClasses: classSet as! Set<AnyHashable>, from: data) as? NSMutableDictionary
           }
           
           if configDict == nil {
               configDict = NSMutableDictionary()
               setObject(NSNumber(value: false), forKey: .default)
           }
       }
       
       private func setDefault(_ object: Any?, forKey key: AppStorageKey) {
           if self.object(forKey: key) == nil {
               setObject(object, forKey: key)
           }
       }
       
       private func synchronized(_ lock: Any, closure: () -> ()) {
           objc_sync_enter(lock)
           closure()
           objc_sync_exit(lock)
       }
}
