//
//  MBProgressHUD+Rx.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/2.
//

import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: MBProgressHUD {
    public var animation: Binder<Bool> {
        return Binder(base) { hud, show in
            guard let view = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
            Base.hide(for: view, animated: false)
            if show {
                if hud.superview == nil {
                    view.addSubview(hud)
                }
                hud.show(animated: true)
            } else {
                hud.hide(animated: true)
            }
        }
    }
    
//    public var loadingMessage: Binder<String> {
//        return Binder(base) { hud, message in
//            guard let view = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
//            hud.removeFromSuperViewOnHide = true
//            hud.detailsLabel.text = ""
//            if !message.isEmpty {
//                if hud.superview == nil {
//                    view.addSubview(hud)
//                }
//                hud.label.text = message
//                hud.isSquare = true
//                if message == SPLocalizedString("success") {
//                    hud.mode = .customView
//                    hud.customView = UIImageView(image: R.image.hud_success())
//                    hud.hide(animated: true, afterDelay: 0.5)
//                } else if message == SPLocalizedString("fail") {
//                    hud.mode = .customView
//                    hud.customView = UIImageView(image: R.image.hud_fail())
//                    hud.hide(animated: true, afterDelay: 0.5)
//                } else {
//                    hud.mode = .indeterminate
//                    hud.show(animated: true)
//                }
//
//            } else {
//                hud.label.text = ""
//                hud.mode = .indeterminate
//                hud.hide(animated: true)
//            }
//        }
//
//    }
    
    var progress: Binder<Double> {
        return Binder(base) { hud, num in
            guard let view = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
            Base.hide(for: view, animated: false)
            if num != 1 {
                if hud.superview == nil {
                    view.addSubview(hud)
                }
                hud.show(animated: true)
                hud.progress = Float(num)
            } else {
                hud.hide(animated: true)
            }
        }
    }
    
    var message: Binder<String?> {
        return Binder(base) { hud, msg in
            guard let view = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }
            Base.hide(for: view, animated: false)
            hud.removeFromSuperViewOnHide = true
            if msg != nil && !msg!.isEmpty {
                if hud.superview == nil {
                    view.addSubview(hud)
                }
                hud.show(animated: true)
                hud.detailsLabel.text = msg
                hud.hide(animated: true, afterDelay: 2)
            }
        }
    }
}
