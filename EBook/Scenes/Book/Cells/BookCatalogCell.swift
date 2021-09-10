//
//  BookCatalogCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/10.
//

import UIKit

class BookCatalogCell: UICollectionViewCell, BindableType {

    var viewModel: BookCatalogCellViewModelType!
    
    @IBOutlet weak var chapterNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.chapterName ~> chapterNameLabel.rx.text
        ]
    }

}
