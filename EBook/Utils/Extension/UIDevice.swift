//
//  UIDevice.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/24.
//

import Foundation
import AdSupport
import Alamofire
import CoreTelephony

extension UIDevice {
    
    open var uniqueID: String {
        let kSWUniqueIDKey: String = "SW_unique_key"
        var uniqueId = UserDefaults.standard.object(forKey:kSWUniqueIDKey) as? String
        if uniqueId == nil {
            uniqueId = MVUOpenUDID.value()
            UserDefaults.standard.setValue(uniqueId, forKey: kSWUniqueIDKey)
            UserDefaults.standard.synchronize()
        }
        if let storedUniquedId = uniqueId, storedUniquedId.isEmpty {
            let timeStr = String(format: "%.5f", NSDate().timeIntervalSince1970)
            let randomStr = String(format: "%d", arc4random() % 10000)
            uniqueId = timeStr.appending(randomStr).md5String
            UserDefaults.standard.setValue(uniqueId, forKey: kSWUniqueIDKey)
            UserDefaults.standard.synchronize()
        }
        return uniqueId!
    }
    
    var isJailbroken: Bool {
        var jailbroken = false
        let cydiaPath = "/Application/Cydia.app"
        let aptPath = "/private/var/lib/apt/"
        if FileManager.default.fileExists(atPath: cydiaPath) || FileManager.default.fileExists(atPath: aptPath) {
            jailbroken = true
        }
        
        return jailbroken
    }
    
    var networkStatus: String {
        var statusStr = "-1"
        NetworkReachabilityManager(host: "www.baidu.com")?.startListening(onUpdatePerforming: { status in
            switch status {
            case .notReachable:
                statusStr = "0"
            case .reachable(.cellular):
                statusStr = "1"
            case .reachable(.ethernetOrWiFi):
                statusStr = "2"
            default:
                statusStr = "-1"
            }
        })
        return statusStr
    }
    
    var networkRadioType : String {
        var radioTypeStr = "0"
        let networkInfo = CTTelephonyNetworkInfo()
        let radioType = networkInfo.currentRadioAccessTechnology
        if radioType == "CTRadioAccessTechnologyGPRS" {
            radioTypeStr = "1"
        } else if radioType == "CTRadioAccessTechnologyEdge" {
            radioTypeStr = "2"
        } else if radioType == "CTRadioAccessTechnologyWCDMA" {
            radioTypeStr = "3"
        } else if radioType == "CTRadioAccessTechnologyHSDPA" {
            radioTypeStr = "4"
        } else if radioType == "CTRadioAccessTechnologyHSUPA" {
            radioTypeStr = "5"
        } else if radioType == "CTRadioAccessTechnologyCDMA1x" {
            radioTypeStr = "6"
        } else if radioType == "CTRadioAccessTechnologyCDMAEVDORev0" {
            radioTypeStr = "7"
        } else if radioType == "CTRadioAccessTechnologyCDMAEVDORevA" {
            radioTypeStr = "8"
        } else if radioType == "CTRadioAccessTechnologyCDMAEVDORevB" {
            radioTypeStr = "9"
        } else if radioType == "CTRadioAccessTechnologyeHRPD" {
            radioTypeStr = "10"
        } else if radioType == "CTRadioAccessTechnologyLTE" {
            radioTypeStr = "1"
        }
        
        return radioTypeStr
    }
    
    var deviceName: String {
        var dName = UIDevice.current.name.urlEncode
        if "i386" == dName || "x86_64" == dName {
            dName = "iOS_Simulator"
        }
        return dName
    }
}

