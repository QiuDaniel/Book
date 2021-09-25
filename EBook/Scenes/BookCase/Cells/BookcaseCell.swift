//
//  BookcaseCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/25.
//

import UIKit

class BookcaseCell: UICollectionViewCell, BindableType {
    
    var viewModel: BookcaseCellViewModelType!
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.cover ~> coverImageView.kf.rx.image(),
            output.bookName ~> nameLabel.rx.text,
            output.author ~> authorLabel.rx.text,
            output.newChapter ~> colorView.rx.isHidden,
            output.status ~> statusLabel.rx.text,
        ]
    }

}
