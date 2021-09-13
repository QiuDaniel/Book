//
//  BookInfoSectionView.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/12.
//

import UIKit

class BookInfoSectionView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var moreLabel: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    @IBAction func moreBtnAction(_ sender: UIButton) {
        eventNotificationName(UIResponderEvent.more.rawValue, userInfo: ["section": titleLabel.text!])
    }
    
}
