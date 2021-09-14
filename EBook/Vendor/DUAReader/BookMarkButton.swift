//
//  BookMarkButton.swift
//  DUAReader
//
//  Created by mengminduan on 2018/1/12.
//  Copyright © 2018年 nothot. All rights reserved.
//

import UIKit

class BookMarkButton: UIButton {

    var isClicked = false {
        didSet {
            if isClicked {
                self.setImage(UIImage(named: "bookMarked"), for: .normal)
            } else {
                setImage(UIImage(named: "bookMark"), for: .normal)
            }
        }
    }

}
