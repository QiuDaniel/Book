//
//  BookDescCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/10.
//

import UIKit

class BookDescCell: UICollectionViewCell, BindableType {

    var viewModel: BookDescCellViewModelType!
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var arrowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.intro ~> introLabel.rx.text,
            output.isArrowHidden ~> arrowView.rx.isHidden
        ]
    }

}
