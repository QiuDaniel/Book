//
//  HistoryCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/29.
//

import UIKit

class HistoryCell: UICollectionViewCell, BindableType {

    var viewModel: HistoryCellViewModelType!
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.cover ~> coverImageView.kf.rx.image(),
            output.title ~> titleLabel.rx.text,
            output.time ~> timeLabel.rx.text,
        ]
    }

}
