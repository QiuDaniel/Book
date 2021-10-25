//
//  AboutViewController.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/7/13.
//

import UIKit
import RxDataSources
import RxSwift

class AboutViewController: BaseViewController, BindableType {

    var viewModel: AboutViewModelType!
    
    private let kAboutHeaderHeight: CGFloat = 250
    private let kAboutHeaderBottomViewHeight: CGFloat = 15
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(R.nib.aboutCell)
        view.rowHeight = 60
        view.sectionHeaderHeight = .leastNormalMagnitude
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.estimatedSectionHeaderHeight = 0
        view.estimatedSectionFooterHeight = 0
        view.backgroundColor = R.color.windowBgColor()
        view.tableHeaderView = setupHeader()
        adjustScrollView(view, with: self)
        return view
    }()
    
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, JSONObject>>!
    private var tableViewConfigure: TableViewSectionedDataSource<SectionModel<String, JSONObject>>.ConfigureCell {
        return { _, tableView, indexPath, item in
            guard var cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.aboutCell, for: indexPath) else {
                fatalError()
            }
            cell.bind(to: AboutCellViewModel(info: item))
            return cell
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        let input = viewModel.input
        rx.disposeBag ~ [
            tableView.rx.setDelegate(self),
            tableView.rx.modelSelected(JSONObject.self) ~> input.itemAction.inputs,
            output.sections ~> tableView.rx.items(dataSource: dataSource),
            output.backImage ~> rx.backImage,
            tableView.rx.didScroll.observe(on:MainScheduler.asyncInstance).subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                let offsetY = self.tableView.contentOffset.y
                if offsetY <= 0 {
                    self.tableView.setContentOffset(CGPoint(x: self.tableView.contentOffset.x, y: 0), animated: false)
                }
            })
        ]
    }

}

extension AboutViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 8
        }
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = R.color.f2f2f2()
        return view
    }
}

private extension AboutViewController {
    func setup() {
        navigationBar.backgroundView.backgroundColor = .clear
        navigationBar.bottomBorderColor = .clear
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        view.bringSubviewToFront(navigationBar)
        dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, JSONObject>>(configureCell: tableViewConfigure)
    }
    
    func setupHeader() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: App.screenWidth, height: App.isModelX ? (kAboutHeaderHeight + App.iPhoneTopSafeHeight) : kAboutHeaderHeight))
        let imageView = UIImageView(image: R.image.bg_about())
        imageView.contentMode = .scaleToFill
        view.addSubview(imageView)
        imageView.snp.makeConstraints{ $0.edges.equalToSuperview() }
        let iconLabel = UILabel()
        iconLabel.text = "读"
        iconLabel.textColor = .white
        iconLabel.font = .boldFont(ofSize: 80)
        view.addSubview(iconLabel)
        iconLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(App.naviBarHeight + 10)
        }
//        let iconView = UIImageView(image: R.image.icon_about_sp())
//        view.addSubview(iconView)
//        iconView.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalToSuperview().offset(App.naviBarHeight + 10)
//        }
//        let iconBgView = UIView()
//        iconBgView.backgroundColor = R.color.windowBgColor()
//        iconBgView.cornerRadius = 40
//        view.insertSubview(iconBgView, belowSubview: iconView)
//        iconBgView.snp.makeConstraints { make in
//            make.edges.equalTo(iconView)
//        }
        let solgenLabel = UILabel()
        solgenLabel.text = "德馨书室"
        solgenLabel.textColor = .white
        solgenLabel.font = .regularFont(ofSize: 20)
        view.addSubview(solgenLabel)
        solgenLabel.snp.makeConstraints { make in
            make.centerX.equalTo(iconLabel)
            make.top.equalTo(iconLabel.snp.bottom).offset(13)
        }
//        let wordImageView = UIImageView(image: R.image.icon_word_sp())
//        view.addSubview(wordImageView)
//        wordImageView.snp.makeConstraints { make in
//            make.centerX.equalTo(iconView)
//            make.top.equalTo(iconView.snp.bottom).offset(13)
//        }
        let versionLabel = UILabel()
        versionLabel.text = "v" + App.appVersion
        versionLabel.font = .regularFont(ofSize: 14)
        versionLabel.textColor = R.color.windowBgColor()
        view.addSubview(versionLabel)
        versionLabel.snp.makeConstraints { make in
            make.centerX.equalTo(solgenLabel)
            make.top.equalTo(solgenLabel.snp.bottom).offset(9)
        }
        
        let bottomView = UIView(frame: CGRect(x: 0, y: 0, width: App.screenWidth, height: kAboutHeaderBottomViewHeight))
        bottomView.backgroundColor = R.color.windowBgColor()
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(kAboutHeaderBottomViewHeight)
        }
        bottomView.addRounded([.topLeft, .topRight], withRadii: CGSize(width: 7.5, height: 7.5))
        
        return view
    }
}
