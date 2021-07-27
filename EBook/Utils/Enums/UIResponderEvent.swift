//
//  UIResponderEvent.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/30.
//

import Foundation

enum UIResponderEvent: String {
    case none = "none"
    case observerSectionAdd = "observerSectionAdd"
    case observerSectionDelete = "observerSectionDelete"
    case subAccountDelete = "subAccountDelete"
    case announcementClose = "announcementClose"
    case bindPhone = "bindPhone"
    case bindWechat = "bindWechat"
    case followWechat = "followWechat"
    case download = "download"
    case copy = "copy"
    case switchUserInterface = "switchUserInterface"
    case back = "back"
}
