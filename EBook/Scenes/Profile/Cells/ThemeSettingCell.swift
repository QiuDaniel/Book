//
//  ThemeSettingCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/12.
//

import UIKit

class ThemeSettingCell: UICollectionViewCell, BindableType {
    
    var viewModel: ThemeSettingCellViewModelType!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override var isSelected: Bool {
        willSet {
            super.isSelected = newValue
            iconImageView.isHidden = !newValue
            if viewModel.output.cellIndex == 0 && newValue && UserinterfaceManager.shared.interfaceStyle != .light {
                UserinterfaceManager.shared.interfaceStyle = .light
                NotificationCenter.default.post(name: SPNotification.interfaceChanged.name, object: nil)
            } else if viewModel.output.cellIndex == 1 && newValue && UserinterfaceManager.shared.interfaceStyle != .dark {
                UserinterfaceManager.shared.interfaceStyle = .dark
                NotificationCenter.default.post(name: SPNotification.interfaceChanged.name, object: nil)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.title ~> titleLabel.rx.text,
        ]
    }
    
}
