//
//  BookEndStatusCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/28.
//

import UIKit

class BookEndStatusCell: UICollectionViewCell, BindableType {

    var viewModel: BookEndStatusCellViewModelType!
    
    @IBOutlet weak var bookStatusLabel: UILabel!
    @IBOutlet weak var bookCityBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bookCityBtn.setImageLayout(.imageRight, space: 4)
    }
    
    func bindViewModel() {
        let output = viewModel.output
        let input = viewModel.input
        bookCityBtn.rx.action = input.bookCityAction
        rx.disposeBag ~ [
            output.bookStatus ~> bookStatusLabel.rx.text,
        ]
    }

}
