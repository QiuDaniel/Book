//
//  HistoryCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/29.
//

import UIKit

class HistoryCell: UICollectionViewCell, BindableType {

    var viewModel: HistoryCellViewModelType!
    
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindViewModel() {
        let output = viewModel.output
        let input = viewModel.input
        addBtn.rx.action = input.addAction
        deleteBtn.rx.action = input.deleteAction
        rx.disposeBag ~ [
            output.cover ~> coverImageView.kf.rx.image(),
            output.title ~> titleLabel.rx.text,
            output.time ~> timeLabel.rx.text,
            output.bookInBookcase.map{ $0 ? R.color.f8f8f8() : R.color.ff4c42() } ~> addBtn.rx.borderColor,
            output.bookInBookcase.map { $0 ? R.color.f8f8f8() : .clear } ~> addBtn.rx.backgroundColor,
            output.bookInBookcase.subscribe(onNext: { [weak self] include in
                guard let `self` = self else { return }
                self.addBtn.setTitleColor(include ? R.color.black_25() : R.color.ff4c42(), for: include ? .disabled: .normal)
                self.addBtn.setImage(include ? R.image.gou_gary() : R.image.tianjia_red(), for: include ? .disabled: .normal)
            }),
        ]
    }
    
}
