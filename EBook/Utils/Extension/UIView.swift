//
//  UIView.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/28.
//

import Foundation

extension UIView {
    
    var currentViewController: UIViewController? {
        var nextResponder = next
        while nextResponder != nil {
            if nextResponder!.isKind(of: UIViewController.self) {
                return nextResponder! as? UIViewController
            }
            nextResponder = nextResponder!.next
        }
        return nil
    }
    
    var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    var right: CGFloat {
        get {
            return self.left + self.width
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue - frame.size.width
            self.frame = frame
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.top + self.height
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue - frame.size.height
            self.frame = frame
        }
    }
    
    var centerX: CGFloat {
        get {
            return self.center.x
        }
        set {
            self.center = CGPoint(x: newValue, y: self.center.y)
        }
    }
    
    var centerY: CGFloat {
        get {
            return self.center.y
        }
        set {
            self.center = CGPoint(x: self.center.x, y: newValue)
        }
    }
    
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    var origin: CGPoint {
        get {
            return self.frame.origin
        }
        set {
            var frame = self.frame
            frame.origin = newValue
            self.frame = frame
        }
    }
    
    var size: CGSize {
        get {
            return self.frame.size
        }
        set {
            var frame = self.frame
            frame.size = newValue
            self.frame = frame
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        
        set {
            self.layer.cornerRadius = newValue
            setNeedsLayout()
        }

    }
    
    @IBInspectable
    var masksToBounds: Bool {
        get {
            return self.layer.masksToBounds
        }
        set {
            self.layer.masksToBounds = newValue
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = self.layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            guard let color = newValue else {
                return
            }
            self.layer.borderColor = color.cgColor
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return self.layer.borderWidth
        }
        set {
            self.layer.borderWidth = newValue
            setNeedsLayout()
        }
    }
    
    func removeAllSubviews() {
        while self.subviews.count > 0 {
            let child = self.subviews.last
            child?.removeFromSuperview()
        }
    }
    
    func addRounded(_ corners: UIRectCorner, withRadii radii: CGSize) {
        let rounded = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: radii)
        let shape = CAShapeLayer()
        shape.path = rounded.cgPath
        layer.mask = shape
    }
    
    
}
