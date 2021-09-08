//
//  BookCategoryCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/8.
//

import UIKit
import RxKingfisher
import Kingfisher

class BookCategoryCell: UICollectionViewCell, BindableType {
    
    var viewModel: BookCategoryCellViewModelType!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.title ~> titleLabel.rx.text,
            output.cover ~> imageView.kf.rx.image(options: [.processor(RoundCornerImageProcessor(cornerRadius: 8))])
        ]
    }

}
