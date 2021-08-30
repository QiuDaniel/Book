//
//  BookCityBannerCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/8/20.
//

import UIKit
import RxFSPagerView

class BookCityBannerCell: UICollectionViewCell, BindableType {

    var viewModel: BookCityBannerCellViewModelType!
    
    @IBOutlet weak var pagerView: FSPagerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindViewModel() {
        
    }

}
