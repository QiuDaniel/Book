//
//  TagDetailViewController.swift
//  EBook
//
//  Created by Daniel on 2021/9/8.
//

import UIKit

class TagDetailViewController: BaseViewController, BindableType {

    var viewModel: TagDetailViewModelType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.title ~> navigationBar.rx.title
        ]
    }

}

private extension TagDetailViewController {
    func setup() {
        
    }
}
