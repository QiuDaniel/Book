//
//  Toast.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/22.
//

import Foundation

struct Toast {
    
    static func show(_ message: String, to view: UIView = UIApplication.shared.windows.first(where: { $0.isKeyWindow })!, after delay: TimeInterval = 1) {
        MBProgressHUD.hide(for: view, animated: true)
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.animationType = .zoomOut
        hud.detailsLabel.text = message
        hud.detailsLabel.textColor = .white
        hud.bezelView.style = .solidColor
        hud.bezelView.backgroundColor = .black
        hud.margin = 10
        hud.offset = CGPoint(x: hud.offset.x, y: 0)
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated: true, afterDelay: delay)
    }
    
}
