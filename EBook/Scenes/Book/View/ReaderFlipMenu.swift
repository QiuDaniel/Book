//
//  ReaderFlipMenu.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/10/26.
//

import UIKit

protocol ReaderFlipMenuDelegate: AnyObject {
    func clickBack(_ sender: UIButton)
    func menu(_ menu: ReaderFlipMenu, selectedAt index: Int)
}

class ReaderFlipMenu: UIView {
    
    weak var delegate: ReaderFlipMenuDelegate?
    
    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.separatorStyle = .none
        view.register(R.nib.readerFlipCell)
        view.rowHeight = 45
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var backBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(R.image.nav_back(), for: .normal)
        btn.addTarget(self, action: #selector(backBtnAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "翻页动画"
        label.font = .regularFont(ofSize: 16)
        label.textColor = R.color.b1e3c()
        return label
    }()
    
    let dataSources = ["无", "仿真翻页", "左右平移"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addShadow(.black.withAlphaComponent(0.5), offset: CGSize(width: 0, height: 4), radius: 16, opacity: 1)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }

}

extension ReaderFlipMenu: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.readerFlipCell, for: indexPath) else { fatalError() }
        cell.nameLabel?.text = dataSources[indexPath.row]
        return cell
    }
    
    
}

extension ReaderFlipMenu: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let delegate = delegate {
            delegate.menu(self, selectedAt: indexPath.row)
        }
    }
}

extension ReaderFlipMenu {
    
    func setup() {
        backgroundColor = R.color.white_2c2c2c()
        addSubview(backBtn)
        backBtn.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(backBtn)
        }
        addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalTo(UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)) }
        let row = AppManager.shared.scrollType.rawValue
        if row < dataSources.count {
            tableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .top)
        }
    }
    
    @objc func backBtnAction(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.clickBack(sender)
        }
    }
}
