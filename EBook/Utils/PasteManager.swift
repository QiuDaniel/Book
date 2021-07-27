//
//  PasteManager.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/7/7.
//

import Foundation

struct PasteManager {
    
    static let shared: PasteManager = {
        return PasteManager()
    }()
    
    func copy(_ text: String, withToast toast: String? = nil, afterToast action:(() -> Void)? = nil) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = String(format: "%@", text)
        if let toast = toast {
            Toast.show(toast)
        }
        if let action = action {
            delay(1) {
                action()
            }
        }
    }
}
