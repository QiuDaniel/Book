//
//  BookInfoCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/10.
//

import UIKit
import RxKingfisher
import Kingfisher

class BookInfoCell: UICollectionViewCell, BindableType {
    
    var viewModel: BookInfoCellViewModelType!
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var protagonistLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.author ~> authorLabel.rx.text,
            output.name ~> bookNameLabel.rx.text,
            output.type ~> typeLabel.rx.text,
            output.cover ~> coverImageView.kf.rx.image(),
            output.protagonist ~> protagonistLabel.rx.text,
        ]
    }

}
