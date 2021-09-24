//
//  BookIndexCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/10.
//

import UIKit

class BookIndexCell: UICollectionViewCell, BindableType {
    
    var viewModel: BookIndexCellViewModelType!
    
    @IBOutlet weak var collectIndexLabel: UILabel!
    @IBOutlet weak var heatIndexLabel: UILabel!
    @IBOutlet weak var wordNumLabel: UILabel!
    @IBOutlet weak var bookStatusLabel: UILabel!
    @IBOutlet weak var popularityLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = R.color.windowBgColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addRounded([.topLeft, .topRight], withRadii: CGSize(width: 16, height: 16))
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.bookStatus ~> bookStatusLabel.rx.text,
            output.collectNum ~> collectIndexLabel.rx.text,
            output.heatNum ~> heatIndexLabel.rx.text,
            output.popularityNum ~> popularityLabel.rx.text,
            output.wordNum ~> wordNumLabel.rx.text
        ]
    }

}
