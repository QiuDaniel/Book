//
//  BookCoverCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/12.
//

import UIKit
import RxKingfisher
import Kingfisher

class BookCoverCell: UICollectionViewCell, BindableType {

    @IBOutlet weak var coverImagView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var otherInfoLabel: UILabel!
    
    
    var viewModel: BookCoverCellViewModelType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.cover ~> coverImagView.kf.rx.image(options:[.processor(RoundCornerImageProcessor(cornerRadius: 8))]),
            output.name ~> titleLabel.rx.text,
            output.otherInfo ~> otherInfoLabel.rx.text
        ]
    }

}
