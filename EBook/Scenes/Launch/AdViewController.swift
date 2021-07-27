//
//  AdViewController.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/26.
//

import UIKit

class AdViewController: BaseViewController, BindableType {
    
    var viewModel: AdViewModelType!
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var countdownBtn: UIButton!
    
    lazy var tap: UITapGestureRecognizer = {
        let gesutre = UITapGestureRecognizer()
        return gesutre
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
    }

    func bindViewModel() {
        let output = viewModel.output
        let input = viewModel.input
        countdownBtn.rx.action = input.skipAction
        
        rx.disposeBag ~ [
            output.adImage ~> imageView.rx.image,
            output.countdown.map { "\($0)" } ~> countdownBtn.rx.title(for: .normal),
            tap.rx.event.map{ _ in () } ~> input.tapAction.inputs
        ]
        
    }
}

