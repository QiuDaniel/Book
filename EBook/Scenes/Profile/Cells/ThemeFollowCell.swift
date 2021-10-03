//
//  ThemeFollowCell.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/12.
//

import UIKit

class ThemeFollowCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var switchBtn: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        switchBtn.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        titleLabel.text = "跟随系统"
        descLabel.text = "开启后，将跟随系统打开或关闭深色模式"
        switchBtn.isOn = UserinterfaceManager.shared.interfaceStyle == .system
    }
    
    @IBAction func switchBtnAction(_ sender: UISwitch) {
        if sender.isOn {
            UserinterfaceManager.shared.interfaceStyle = .system
        } else {
            let style = UITraitCollection.current.userInterfaceStyle
            switch style {
            case .light, .unspecified:
                UserinterfaceManager.shared.interfaceStyle = .light
            case .dark:
                UserinterfaceManager.shared.interfaceStyle = .dark
            default:
                break
            }
        }
        NotificationCenter.default.post(name: SPNotification.interfaceChanged.name, object: nil)
        eventNotificationName(UIResponderEvent.switchUserInterface.rawValue)
    }
    
}
