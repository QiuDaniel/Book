//
//  DUAConfig.swift
//  DUAReader
//
//  Created by mengminduan on 2017/12/26.
//  Copyright © 2017年 nothot. All rights reserved.
//

import UIKit

enum DUAReaderScrollType: Int {
    case curl
    case horizontal
    case vertical
    case none
}

enum DUAReaderBookType {
    case txt
    case epub
}

class DUAConfiguration: NSObject {

    var contentFrame = CGRect()
    var lineHeightMutiplier: CGFloat = 2 {
        didSet {
            self.didLineHeightChanged(lineHeightMutiplier)
        }
    }
    var fontSize: CGFloat = 16 {
        didSet {
            self.didFontSizeChanged(fontSize)
        }
    }
    var fontName:String! {
        didSet {
            self.didFontNameChanged(fontName)
        }
    }
    var backgroundImage:UIImage! {
        didSet {
            self.didBackgroundImageChanged(backgroundImage)
        }
    }
    
    var textColor: UIColor = UIColor.systemGray6 {
        didSet {
            didTextColorChanged(textColor, titleColor)
        }
    }
    
    var titleColor: UIColor = .black {
        didSet {
            didTextColorChanged(textColor, titleColor)
        }
    }
    
    var scrollType = DUAReaderScrollType.curl {
        didSet {
            self.didScrollTypeChanged(scrollType)
        }
    }
    
    var bookType = DUAReaderBookType.txt
    
    
    var didFontSizeChanged: (CGFloat) -> Void = {_ in }
    var didFontNameChanged: (String) -> Void = {_ in }
    var didTextColorChanged: (UIColor?, UIColor?) -> Void = { _,_  in }
    var didBackgroundImageChanged: (UIImage) -> Void = {_ in }
    var didLineHeightChanged: (CGFloat) -> Void = {_ in }
    var didScrollTypeChanged: (DUAReaderScrollType) -> Void = {_ in }

    
    override init() {
        super.init()
        let font = UIFont.systemFont(ofSize: fontSize)
        fontName = font.fontName
        contentFrame = CGRect(x: 30, y: DUAUtils.screenStatusBarHeight, width: UIScreen.main.bounds.size.width - 60, height: UIScreen.main.bounds.size.height - DUAUtils.screenStatusBarHeight - DUAUtils.safeAreaBottomHeight)
    }
    
}
