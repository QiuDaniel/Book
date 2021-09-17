//
//  CatalogModel.swift
//  EBook
//
//  Created by Daniel on 2021/9/17.
//

import UIKit

class CatalogModel: NSObject {
    var index: Int = NSNotFound
    
    init(_ index: Int) {
        super.init()
        self.index = index
    }
}
