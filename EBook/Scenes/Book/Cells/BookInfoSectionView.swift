//
//  BookInfoSectionView.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/12.
//

import UIKit

class BookInfoSectionView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    @IBAction func moreBtnAction(_ sender: UIButton) {
        eventNotificationName(UIResponderEvent.more.rawValue)
    }
    
}
