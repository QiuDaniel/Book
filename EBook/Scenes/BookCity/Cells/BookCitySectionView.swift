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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        moreBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(moreBtn.imageView?.size.width ?? 0), bottom: 0, right: moreBtn.imageView?.size.width ?? 0)
        moreBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: moreBtn.titleLabel?.size.width ?? 0, bottom: 0, right: -(moreBtn.titleLabel?.size.height ?? 0) - 8)

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
