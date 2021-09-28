//
//  BookCitySectionView.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/2.
//

import UIKit

class BookCitySectionView: UICollectionReusableView, BindableType {

    var viewModel: BookCitySectionViewModelType!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        moreBtn.setImageLayout(.imageRight, space: 0)

    }
    
    func bindViewModel() {
        let output = viewModel.output
        let input = viewModel.input
        moreBtn.rx.action = input.moreAction
        rx.disposeBag ~ [
            output.title ~> titleLabel.rx.text
        ]
    }
    
}
