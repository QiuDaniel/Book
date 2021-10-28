//
//  AboutCell.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/7/13.
//

import UIKit

class AboutCell: UITableViewCell, BindableType {

    var viewModel: AboutCellViewModelType!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subNameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var badgeView: UIView!
    @IBOutlet weak var lineViewHeight: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lineViewHeight.constant = App.lineHeight
    }

    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.name ~> nameLabel.rx.text,
            output.content ~> subNameLabel.rx.text,
            output.isLineHidden ~> lineView.rx.isHidden,
            output.isBadgeHidden ~> badgeView.rx.isHidden,
            output.isArrowHidden ~> iconImageView.rx.isHidden,
        ]
    }

}
