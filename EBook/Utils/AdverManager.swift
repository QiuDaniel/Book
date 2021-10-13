//
//  AddManager.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/10/13.
//

import Foundation
import GoogleMobileAds


struct AdverManager {
    static let shared = AdverManager()
    
    func start() {
        GADMobileAds.sharedInstance().start()
    }
    
}
