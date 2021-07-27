//
//  SPRefreshHeader.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/20.
//

import UIKit

class SPRefreshHeader: MJRefreshNormalHeader {
    override func prepare() {
        super.prepare()
        stateLabel?.font = .regularFont(ofSize: 12)
        stateLabel?.textColor = UIColor(red:170 / 255.0, green: 171 / 255.0, blue: 175 / 255.0, alpha: 1)
        lastUpdatedTimeLabel?.font = .regularFont(ofSize: 12)
        lastUpdatedTimeLabel?.textColor = UIColor(red:170 / 255.0, green: 171 / 255.0, blue: 175 / 255.0, alpha: 1)
    }

}
