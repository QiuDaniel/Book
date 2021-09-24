//
//  bookIntroTagCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/10.
//

import UIKit

class BookIntroTagCell: UICollectionViewCell, BindableType {

    var viewModel: BookIntroTagCellViewModelType!
    private var startX: CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.tagNames.subscribe(onNext: { [weak self] names in
                guard let `self` = self else { return }
                self.contentView.removeAllSubviews()
                for (idx, name) in names.enumerated() {
                    let labelWidth = CGFloat(ceilf(Float(name.size(withAttributes: [.font: UIFont.regularFont(ofSize: 12)], forStringSize: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 18)).width))) + 20
                    if idx == 0 {
                        self.startX = 10
                    }
                    let label = UILabel()
                    label.text = name
                    label.font = .regularFont(ofSize: 12)
                    label.textColor = R.color.black_45()
                    label.textAlignment = .center
                    switch UserinterfaceManager.shared.interfaceStyle {
                    case .system:
                        switch self.traitCollection.userInterfaceStyle {
                        case .light, .unspecified:
                            label.layer.backgroundColor = R.color.ebebeb()?.cgColor
                        case .dark:
                            label.layer.backgroundColor = UIColor(hexString: "#6D6D6D")?.cgColor
                        default:
                            break
                        }
                    case .light:
                        label.layer.backgroundColor = R.color.ebebeb()?.cgColor
                    default:
                        label.layer.backgroundColor = UIColor(hexString: "#6D6D6D")?.cgColor
                    }
                    label.cornerRadius = 13
                    label.frame = CGRect(x: self.startX, y: 4, width: labelWidth, height: 26)
                    self.contentView.addSubview(label)
                    self.startX = label.right + 5
                }
            })
        ]
    }

}
