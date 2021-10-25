//
//  H5ViewController.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/2.
//

import UIKit
import WebKit

class H5ViewController: WebViewController, BindableType {

    var viewModel: H5ViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.h5Url ~> rx.url,
            output.h5Title ~> navigationBar.rx.title,
        ]
    }

}


