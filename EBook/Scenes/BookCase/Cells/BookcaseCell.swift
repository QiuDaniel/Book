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
    @IBOutlet weak var moreBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindViewModel() {
        let output = viewModel.output
        let input = viewModel.input
        moreBtn.rx.action = input.moreAction
        rx.disposeBag ~ [
            output.cover ~> coverImageView.kf.rx.image(),
            output.bookName ~> nameLabel.rx.text,
            output.author ~> authorLabel.rx.text,
            output.newChapter ~> colorView.rx.isHidden,
            output.status ~> statusLabel.rx.text,
        ]
    }

    @IBAction func moreBtnAction(_ sender: UIButton) {
        eventNotificationName(UIResponderEvent.more.rawValue)
    }
}
