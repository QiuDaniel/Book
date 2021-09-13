//
//  ChapterListCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/13.
//

import UIKit

class ChapterListCell: UICollectionViewCell, BindableType {

    var viewModel: ChapterListCellViewModelType!
    @IBOutlet weak var chapterNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.chapterName ~> chapterNameLabel.rx.text,
        ]
    }
}
