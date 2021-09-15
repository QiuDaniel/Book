//
//  DUAChapterModel.swift
//  DUAReader
//
//  Created by mengminduan on 2017/12/26.
//  Copyright © 2017年 nothot. All rights reserved.
//

import UIKit

class DUAChapterModel: NSObject {

    var title: String?
    var path: String?
    var chapterIndex: Int = 0
    
    convenience init(title:String, path: String?, chapterIndex: Int = 0) {
        self.init()
        self.title = title
        self.path = path
        self.chapterIndex = chapterIndex
    }
}
