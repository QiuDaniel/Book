//
//  BookCopyrightCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/20.
//

import UIKit

class BookCopyrightCell: UICollectionViewCell, BindableType {

    var viewModel: BookCopyrightCellViewModelType!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statementLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 5
        let attriStr = NSMutableAttributedString(string: "书籍内容均系他人制作或提供，本app对其合法性概不负责，亦不承担任何法律责任。", attributes: [.paragraphStyle : paragraph])
        statementLabel.attributedText = attriStr
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.createTime ~> timeLabel.rx.text
        ]
    }

}
