//
//  ProfileCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/29.
//

import UIKit

class ProfileCell: UICollectionViewCell, BindableType {

    var viewModel: ProfileCellViewModelType!
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindViewModel() {
        
        let output = viewModel.output
        rx.disposeBag ~ [
            output.title ~> titleLabel.rx.text,
            output.image ~> iconImageView.rx.image,
        ]
    }

}
