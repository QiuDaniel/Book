//
//  BookTagCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/8.
//

import UIKit
import RxKingfisher
import Kingfisher

class BookTagCell: UICollectionViewCell, BindableType {
    var viewModel: BookTagCellViewModelType!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bigImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.title ~> titleLabel.rx.text,
            output.bigImage ~> bigImageView.kf.rx.image(options: [.processor(RoundCornerImageProcessor(cornerRadius: 8))])
        ]
    }

}

