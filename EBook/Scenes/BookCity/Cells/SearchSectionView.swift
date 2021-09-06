//
//  SearchSectionView.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/9/5.
//

import UIKit

class SearchSectionView: UICollectionReusableView, BindableType {
    
    var viewModel: SearchSectionViewModelType!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var clearBtn: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindViewModel() {
        let output = viewModel.output
        rx.disposeBag ~ [
            output.content ~> titleLabel.rx.text,
            output.isClearHidden ~> clearBtn.rx.isHidden,
        ]
    }
    
    @IBAction func clearBtnAction(_ sender: Any) {
        eventNotificationName(UIResponderEvent.clearSearchHistory.rawValue)
    }
    
}
