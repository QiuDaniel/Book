//
//  FindBookViewController.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/10/8.
//

import UIKit

class FindBookViewController: BaseViewController, BindableType {

    var viewModel: FindBookViewModelType!
    
    private weak var totalLabel: UILabel!
    private weak var errorLabel: UILabel!
    private weak var submitBtn: UIButton!
    private lazy var nameField: UITextField = {
        let tf = UITextField(frame: .zero)
        tf.font = .regularFont(ofSize: 14)
        tf.textColor = R.color.b1e3c()
        let attributed = [NSAttributedString.Key.font : UIFont.regularFont(ofSize: 14), NSAttributedString.Key.foregroundColor: R.color.b1e3c()!.withAlphaComponent(0.3)]
        tf.attributedPlaceholder = NSAttributedString(string: "请输入书名", attributes: attributed)
        tf.keyboardType = .default
        tf.returnKeyType = .done
        tf.spellCheckingType = .no
        tf.autocorrectionType = .no
        tf.tintColor = R.color.ff7828()
        return tf
    }()
    
    private lazy var remarkField: UITextField = {
        let tf = UITextField(frame: .zero)
        tf.font = .regularFont(ofSize: 14)
        tf.textColor = R.color.b1e3c()
        let attributed = [NSAttributedString.Key.font : UIFont.regularFont(ofSize: 14), NSAttributedString.Key.foregroundColor: R.color.b1e3c()!.withAlphaComponent(0.3)]
        tf.attributedPlaceholder = NSAttributedString(string: "请输入作者/主角名(选填)", attributes: attributed)
        tf.keyboardType = .default
        tf.returnKeyType = .done
        tf.spellCheckingType = .no
        tf.autocorrectionType = .no
        tf.tintColor = R.color.ff7828()
        return tf
    }()
    
    private lazy var loadingHud: MBProgressHUD = {
        let hud = MBProgressHUD.showLoadingHud(at: view)
        return hud
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func bindViewModel() {
        let output = viewModel.output
        let input = viewModel.input
        submitBtn.rx.action = input.submitAction
        rx.disposeBag ~ [
            nameField.rx.textInput <-> input.nameValue,
            remarkField.rx.textInput <-> input.keywordValue,
            output.submitBtnEnabled ~> submitBtn.rx.isEnabled,
            output.nameError ~> errorLabel.rx.text,
            output.count ~> totalLabel.rx.attributedText,
            output.hudLoading ~> loadingHud.rx.animation,
            output.hideKeyboard.subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.view.endEditing(true)
            })
        ]
    }

}

private extension FindBookViewController {
    func setup() {
        navigationBar.title = "我想找书"
        let label = UILabel()
        label.font = .regularFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = R.color.black_65()
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        totalLabel = label
        let titleLabel = UILabel()
        titleLabel.text = "请输入您想看的书籍"
        titleLabel.textColor = R.color.b1e3c()
        titleLabel.font = .boldFont(ofSize: 20)
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        let nameLeftlabel = UILabel()
        nameLeftlabel.text = "书名"
        nameLeftlabel.textColor = R.color.b1e3c()
        nameLeftlabel.font = .regularFont(ofSize: 14)
        view.addSubview(nameLeftlabel)
        nameLeftlabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
        }
        nameLeftlabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        nameLeftlabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        view.addSubview(nameField)
        nameField.snp.makeConstraints { make in
            make.leading.equalTo(nameLeftlabel.snp.trailing).offset(30)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(44)
            make.centerY.equalTo(nameLeftlabel)
        }
        let lineView = UIView()
        lineView.backgroundColor = R.color.ebebeb()
        view.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.top.equalTo(nameLeftlabel.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(App.lineHeight)
        }
        
        let errLabel = UILabel()
        errLabel.font = .regularFont(ofSize: 12)
        errLabel.textColor = R.color.ff4c42()
        
        view.addSubview(errLabel)
        errLabel.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(5)
            make.leading.equalToSuperview().offset(10)
        }
        errorLabel = errLabel
        let remarkLeftlabel = UILabel()
        remarkLeftlabel.text = "关键字"
        remarkLeftlabel.textColor = R.color.b1e3c()
        remarkLeftlabel.font = .regularFont(ofSize: 14)
        view.addSubview(remarkLeftlabel)
        remarkLeftlabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalTo(lineView.snp.bottom).offset(30)
        }
        view.addSubview(remarkField)
        remarkField.snp.makeConstraints { make in
            make.leading.equalTo(nameField)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(44)
            make.centerY.equalTo(remarkLeftlabel)
        }
        
        let lineView1 = UIView()
        lineView1.backgroundColor = R.color.ebebeb()
        view.addSubview(lineView1)
        lineView1.snp.makeConstraints { make in
            make.top.equalTo(remarkLeftlabel.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(App.lineHeight)
        }
        
        let tipLabel = UILabel()
        tipLabel.text = "温馨提示：信息填写越多，找的越准确"
        tipLabel.font = .regularFont(ofSize: 12)
        tipLabel.textColor = R.color.ff7828()
        view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints { make in
            make.top.equalTo(lineView1.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
        }
        
        let btn = UIButton(type: .custom)
        btn.setTitle("提交", for: .normal)
        btn.setTitle("提交", for: .disabled)
        btn.titleLabel?.font = .regularFont(ofSize: 14)
        btn.setTitleColor(R.color.title_ffffff(), for: .normal)
        btn.setTitleColor(R.color.ffd3b8(), for: .disabled)
        btn.setBackgroundImage(R.color.ff7828()?.toImage(), for: .normal)
        btn.setBackgroundImage(R.color.ff9a5e()?.toImage(), for: .disabled)
        btn.cornerRadius = 20
        btn.masksToBounds = true
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalTo(tipLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 120, height: 40))
        }
        submitBtn = btn
    }
}
