//
//  PreferencesViewController.swift
//  EBook
//
//  Created by Daniel on 2021/10/18.
//

import UIKit

class PreferencesViewController: BaseViewController, BindableType {

    var viewModel: PreferencesViewModelType!
    
    @IBOutlet weak var bg1: UIView!
    @IBOutlet weak var bg2: UIView!
    @IBOutlet weak var imageLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var boySelectedLabel: UILabel!
    @IBOutlet weak var girlSelectedLabel: UILabel!
    @IBOutlet weak var boyBtn: UIButton!
    @IBOutlet weak var girlBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }


    func bindViewModel() {
        let output = viewModel.output
        let input = viewModel.input
        boyBtn.rx.action = input.boyAction
        girlBtn.rx.action = input.girlAction
        rx.disposeBag ~ [
            output.boySelected.map { !$0 } ~> boySelectedLabel.rx.isHidden,
            output.boySelected ~> girlSelectedLabel.rx.isHidden,
            output.boySelected.map { $0 ? R.color.ff4c42() : R.color.white_2c2c2c() } ~> bg1.rx.borderColor,
            output.boySelected.map { $0 ? R.color.white_2c2c2c() : R.color.ff4c42() } ~> bg2.rx.borderColor,
        ]
    }
}

private extension PreferencesViewController {
    
    func setup() {
        navigationBar.backgroundView.backgroundColor = .clear
        navigationBar.title = "阅读喜好"
        view.backgroundColor = R.color.e8e8e8()
        bg1.cornerRadius = 8
        bg2.cornerRadius = 8
        bg1.borderWidth = 1
        bg2.borderWidth = 1
        imageLeftMargin.constant = scaleF(imageLeftMargin.constant)
        boySelectedLabel.cornerRadius = 4
        boySelectedLabel.layer.backgroundColor = R.color.ff4c42()?.cgColor
        girlSelectedLabel.cornerRadius = 4
        girlSelectedLabel.layer.backgroundColor = R.color.ff4c42()?.cgColor
    }
}
