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
    case staticDomain
    case bookCity
    case browseHistory
    case bookcase
    case gender
    case globalConfigCount
}

class AppStorage: NSObject {
    static let shared = AppStorage()
    private let configKey: [NSString] = ["default",
                             "kNetEvn",
                             "kSearchHistory",
                             "staticDomain",
                             "bookCity",
                             "browseHistory",
                             "bookcase",
                             "gender"
                            ]
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
            setDefault(1, forKey: .gender)
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
               let classSet = NSSet(objects: NSDictionary.self, NSString.self, NSArray.self, NSNumber.self)
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
