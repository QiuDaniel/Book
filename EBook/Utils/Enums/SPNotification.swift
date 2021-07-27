//
//  Notification.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/19.
//

import Foundation

protocol SPNotificationType {
    var name: Notification.Name { get }
}

enum SPNotification {
    case loginSuccess
    case dragDismiss
    case languageChanged
    case incomeVisible
    case accountPrivacy
    case memoChanged
    case checkMinerInfo
    case monetaryUnitChanged
    case interfaceChanged
}

extension SPNotification: SPNotificationType {
    var name: Notification.Name {
        switch self {
        case .loginSuccess:
            return Notification.Name(rawValue: "LoginSuccess")
        case .dragDismiss:
            return Notification.Name(rawValue: "DragDismiss")
        case .languageChanged:
            return Notification.Name(rawValue: "LanguageChanged")
        case .incomeVisible:
            return Notification.Name(rawValue: "IncomeVisible")
        case .accountPrivacy:
            return Notification.Name(rawValue: "AccountPrivacy")
        case .memoChanged:
            return Notification.Name(rawValue: "MemoChanged")
        case .checkMinerInfo:
            return Notification.Name(rawValue: "CheckMinerInfo")
        case .monetaryUnitChanged:
            return Notification.Name(rawValue: "MonetaryUnitChanged")
        case .interfaceChanged:
            return Notification.Name(rawValue: "InterfaceChanged")
        }
    }
}
