//
//  BookCategorySectionView.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/8.
//

import UIKit

class BookCategorySectionView: UICollectionReusableView {

    
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func moreBtnAction(_ sender: UIButton) {
        eventNotificationName(UIResponderEvent.more.rawValue)
    }
}
