//
//  DUAPageViewController.swift
//  DUAReader
//
//  Created by mengminduan on 2017/12/26.
//  Copyright © 2017年 nothot. All rights reserved.
//

import UIKit

class DUAContainerPageViewController: UIPageViewController {
    var willStepIntoNextChapter = false
    var willStepIntoLastChapter = false
    
}

class DUAtranslationControllerExt: DUATranslationController {
    var willStepIntoNextChapter = false
    var willStepIntoLastChapter = false
}

class DUAPageViewController: UIViewController {
    
    var index: Int = 1
    var chapterBelong: Int = 1
    var backgroundImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        if backgroundImage != nil {
            let imageView = UIImageView(frame: self.view.frame)
            imageView.image = backgroundImage
            self.view.insertSubview(imageView, at: 0)
        }
    }
    

}
