//
//  GradientView.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/26.
//

import UIKit

class GradientView: UIView {

    @IBInspectable var startColor: UIColor = .blue {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var endColor: UIColor = .green {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var startPointX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var startPointY: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var endPointX: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    @IBInspectable var endPointY: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    
    override func layoutSubviews() {
        addGradient(with: CGPoint(x: startPointX, y: startPointY), startColor: startColor, endPoint: CGPoint(x: endPointX, y: endPointY), endColor: endColor)
    }
    
    private func addGradient(with startPoint: CGPoint, startColor: UIColor, endPoint: CGPoint, endColor: UIColor) {
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.locations = [0, 1]
    }


}
