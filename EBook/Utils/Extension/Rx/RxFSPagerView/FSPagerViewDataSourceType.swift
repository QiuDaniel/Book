//
//  FSPagerViewDataSourceType.swift
//  RabbitOptimization
//
//  Created by Daniel on 2019/8/27.
//  Copyright © 2019 Daniel. All rights reserved.
//

import Foundation

protocol FSPagerViewSectionedDataSourceType {
    
    func model(at index: Int) throws -> Any 
}
