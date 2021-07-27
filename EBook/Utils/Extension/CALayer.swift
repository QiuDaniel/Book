//
//  CALayer.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/1.
//

import Foundation

extension CALayer {
    func removeAllSubviews() {
        guard let sublayers = sublayers else {
            return
        }
        while sublayers.count > 0 {
            let child = sublayers.last
            child?.removeFromSuperlayer()
        }
    }
    
    func removeCAGradientLayer() {
        guard let sublayers = sublayers else {
            return
        }
        while sublayers.count > 0 {
            if let child = sublayers.last as? CAGradientLayer {
                child.removeFromSuperlayer()
            }
        }
    }
}
