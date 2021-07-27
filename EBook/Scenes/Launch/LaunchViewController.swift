//
//  LaunchViewController.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/24.
//

import UIKit

class LaunchViewController: UIViewController, BindableType {
    
    var viewModel: LaunchViewModel!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func bindViewModel() {}

}
