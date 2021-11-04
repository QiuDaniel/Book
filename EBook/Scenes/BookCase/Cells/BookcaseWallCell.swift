//
//  BookcaseWallCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/11/4.
//

import UIKit

class BookcaseWallCell: UICollectionViewCell, BindableType {
    
    var viewModel: BookcaseCellViewModelType!
    
    @IBOutlet weak var coverImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var updateView: UIView!
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
            output.newChapter ~> updateView.rx.isHidden,
            output.author ~> statusLabel.rx.text,
        ]
    }

    @IBAction func moreBtnAction(_ sender: Any) {
        eventNotificationName(UIResponderEvent.more.rawValue)
    }
}
