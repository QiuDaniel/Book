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
    
    private var _needChangeColor = false
    
    var needChangeColor: Bool {
        get {
            _needChangeColor
        }
        set {
            _needChangeColor = newValue
            viewModel.input.changeChapterNameColor(newValue ? R.color.ff4c42() : R.color.b1e3c())
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.chapterName ~> chapterNameLabel.rx.text,
            output.chapterNameColor ~> chapterNameLabel.rx.textColor,
        ]
    }
}
