//
//  UIView+Transform.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/31.
//

import Foundation

private var gradientLayerKey: Void?

extension UIView {
    
    private var gradientLayer: CAGradientLayer? {
        get {
            return objc_getAssociatedObject(self, &gradientLayerKey) as? CAGradientLayer
        }
        
        set {
            objc_setAssociatedObject(self, &gradientLayerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addGradient(withStartPoint point: CGPoint, startColor: UIColor, endPoint: CGPoint, endColor: UIColor) {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
        gradientLayer = CAGradientLayer()
        gradientLayer!.frame = bounds
        gradientLayer!.cornerRadius = layer.cornerRadius
        gradientLayer!.startPoint = point
        gradientLayer!.endPoint = endPoint
        gradientLayer!.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer!.locations = [0, 1]
        layer.insertSublayer(gradientLayer!, at: 0)
    }
    
    func addShadow(_ color: UIColor?, offset: CGSize, radius: CGFloat, opacity: Float) {
        layer.shadowColor = color?.cgColor;
        layer.shadowOffset = offset;
        layer.shadowRadius = radius;
        layer.shadowOpacity = opacity;
    }
    
    func removeGradient() {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
    
    func removeShadow() {
        layer.shadowColor = UIColor.clear.cgColor;
        layer.shadowOffset = CGSize(width: 0, height: 0);
        layer.shadowRadius = 0;
        layer.shadowOpacity = 0;
    }
    
}
