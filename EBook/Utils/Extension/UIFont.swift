//
//  UIFont.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/22.
//

import Foundation

extension UIFont {
    
    open class func thinFont(ofSize: CGFloat) -> UIFont {
        var font: UIFont
        if #available(iOS 8.2, *) {
            font = systemFont(ofSize: ofSize, weight: .thin)
        } else {
            font = systemFont(ofSize: ofSize)
        }
        return font;
    }
    
    open class func ligthFont(ofSize: CGFloat) -> UIFont {
        guard #available(iOS 8.2, *) else {
            return systemFont(ofSize: ofSize);
        }
        
        return systemFont(ofSize: ofSize, weight: .light)
    }
    
     open class func regularFont(ofSize: CGFloat) -> UIFont {
        guard #available(iOS 8.2, *) else {
            return systemFont(ofSize:ofSize);
        }
        return systemFont(ofSize: ofSize, weight: .regular)
    }
    
    open class func mediumFont(ofSize: CGFloat) -> UIFont {
        guard #available(iOS 8.2, *) else {
            return systemFont(ofSize: ofSize)
        }
        return systemFont(ofSize: ofSize, weight: .medium)
    }
    
    open class func semiboldFont(ofSize: CGFloat) -> UIFont {
        guard #available(iOS 8.2, *) else {
            return systemFont(ofSize: ofSize)
        }
        return systemFont(ofSize: ofSize, weight: .semibold)
    }
    
    open class func boldFont(ofSize: CGFloat) -> UIFont {
        guard #available(iOS 8.2, *) else {
            return boldSystemFont(ofSize: ofSize)
        }
        return systemFont(ofSize: ofSize, weight: .bold)
    }
    
    open class func heavyFont(ofSize: CGFloat) -> UIFont {
        guard #available(iOS 8.2, *) else {
            return boldSystemFont(ofSize: ofSize)
        }
        
        return systemFont(ofSize: ofSize, weight: .heavy)
    }
    
}
