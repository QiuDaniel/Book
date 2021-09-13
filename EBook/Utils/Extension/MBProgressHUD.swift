//
//  MBProgressHUD.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/2.
//

import Foundation

extension MBProgressHUD {
    
    static func hudWhiteLoading(_ message: String? = nil, at view: UIView? = nil) -> MBProgressHUD {
        let hud = MBProgressHUD()
        if let message = message {
            hud.detailsLabel.text = message
        }
        hud.mode = .customView
        hud.removeFromSuperViewOnHide = true
        let imageView = UIImageView(image: R.image.loading_white())
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.toValue = .pi * 2.0
        animation.duration = 1
        animation.isCumulative = true
        animation.isRemovedOnCompletion = false //保证切换到其他页面或进入后台再回来动画继续执行
        animation.repeatCount = .greatestFiniteMagnitude
        imageView.layer.add(animation, forKey: "rotationAnimation")
        hud.customView = imageView
        customAppearance(hud)
        if let view = view {
            view.addSubview(hud)
        }
        return hud
    }
    
    static func hudProgress() -> MBProgressHUD {
        let hud = MBProgressHUD()
        hud.mode = .annularDeterminate
        hud.removeFromSuperViewOnHide = true
        customAppearance(hud)
        return hud
    }
    
    @discardableResult
    static func showHud(_ image: UIImage? = nil, message: String, at view: UIView? = nil) -> MBProgressHUD {
        var hud: MBProgressHUD? = nil
        if view != nil {
            hud = MBProgressHUD.forView(view!)
            if hud == nil {
                hud = MBProgressHUD.showAdded(to: view!, animated: true)
            }
        } else {
            hud = MBProgressHUD()
        }
        
        hud!.detailsLabel.text = message
        hud!.removeFromSuperViewOnHide = true
        hud!.mode = image != nil ? .customView : .text
        if image != nil {
            hud!.customView = UIImageView(image: image)
        }
        customAppearance(hud!)
        if let view = view {
            view.addSubview(hud!)
        }
        return hud!
    }
    
    @discardableResult
    static func showLoadingHud(_ message: String? = nil, at view: UIView? = nil) -> MBProgressHUD {
        let hud = MBProgressHUD()
        if let message = message {
            hud.label.text = message
        }
        hud.mode = .indeterminate
        hud.removeFromSuperViewOnHide = true
        customAppearance(hud)
        if let view = view {
            view.addSubview(hud)
        }
        return hud
    }
    
    //MARK: - Private
        
    private static func customAppearance(_ hud: MBProgressHUD) {
        hud.contentColor = .white
        hud.bezelView.color = UIColor.black.withAlphaComponent(0.8)
        hud.detailsLabel.font = .systemFont(ofSize: 14)
        hud.bezelView.style = .solidColor
        hud.bezelView.layer.cornerRadius = 10
    }
}
