//
//  SearchResultCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/6.
//

import UIKit

class SearchResultCell: UICollectionViewCell, BindableType {

    var viewModel: SearchResultCellViewModelType!
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var authorTipLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.iconImage ~> iconImageView.rx.image,
            output.title ~> contentLabel.rx.attributedText,
            output.isAuthorTipHidden ~> authorTipLabel.rx.isHidden
        ]
    }

}
