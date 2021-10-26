//
//  ReaderFlipCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/10/26.
//

import UIKit

class ReaderFlipCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        iconImageView.isHidden = !selected
    }
    
}
