//
//  BookIntroCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/3.
//

import UIKit
import RxKingfisher
import Kingfisher

class SearchBookCell: UICollectionViewCell, BindableType {

    var viewModel: SearchBookCellViewModelType!
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.postImage ~> postImageView.kf.rx.image(options: [.processor(RoundCornerImageProcessor(cornerRadius: 8))]),
            output.title ~> titleLabel.rx.attributedText,
            output.intro ~> introLabel.rx.attributedText,
            output.cate ~> categoryLabel.rx.attributedText,
        ]
    }

}
