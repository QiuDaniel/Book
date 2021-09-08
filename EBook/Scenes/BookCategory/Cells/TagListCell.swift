//
//  TagListCell.swift
//  EBook
//
//  Created by Daniel on 2021/9/8.
//

import UIKit
import Kingfisher
import RxKingfisher

class TagListCell: UICollectionViewCell, BindableType {

    var viewModel: TagListCellViewModelType!
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.cover ~> coverImageView.kf.rx.image(options: [.processor(RoundCornerImageProcessor(cornerRadius: 4))]),
            output.title ~> titleLabel.rx.text
        ]
    }

}
