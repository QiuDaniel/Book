//
//  SearchWordCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/5.
//

import UIKit

class SearchWordCell: UICollectionViewCell, BindableType {

    var viewModel: SearchWordCellViewModelType!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = R.color.f8f8f8()
        contentView.cornerRadius = 17.5
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.title ~> titleLabel.rx.text
        ]
    }

}
