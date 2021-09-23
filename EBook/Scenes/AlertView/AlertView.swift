//
//  AlertView.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/6/22.
//

import UIKit

enum AlertViewStyle: Int {
    case `default`
    case input
    case noclose
    case success
}

class AlertView: UIView, BindableType {
    
    var viewModel: AlertViewModelType!

    private var actionCount: Int = 1
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.white_2c2c2c()
        view.cornerRadius = 12
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = R.color.b1e3c()
        label.font = .mediumFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = R.color.c_848fad()
        label.font = .regularFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = R.color.b5bcce()
        label.font = .regularFont(ofSize: 12)
        return label
    }()
    
    private lazy var leftBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.borderColor = R.color.c_848fad()
        btn.borderWidth = 1
        btn.cornerRadius = 20
        btn.titleLabel?.font = .regularFont(ofSize: 16)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        btn.titleLabel?.minimumScaleFactor = 14 / 16.0
        btn.setTitleColor(R.color.c_848fad(), for: .normal)
        btn.backgroundColor = .clear
        return btn
    }()

    private lazy var rightBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.cornerRadius = 20
        btn.titleLabel?.font = .regularFont(ofSize: 16)
        btn.setTitleColor(R.color.title_ffffff(), for: .normal)
        btn.backgroundColor = R.color.ff7828()
        return btn
    }()
    
    private lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(R.image.icon_common_close(), for: .normal)
        return btn
    }()
    
    private lazy var inputBgView: UIView = {
        let view = UIView()
        view.backgroundColor = R.color.e6e6e6()
        view.borderWidth = 0.5
        view.borderColor = R.color.f8f8f8()
        view.cornerRadius = 4
        return view
    }()
    
    lazy var inputTF: UITextField = {
        let tf = UITextField(frame: .zero)
        tf.font = .regularFont(ofSize: 14)
        tf.textColor = R.color.b1e3c()
        tf.keyboardType = .default
        tf.returnKeyType = .done
        tf.spellCheckingType = .no
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.tintColor = R.color.ff7828()
        let attributed = [NSAttributedString.Key.font: UIFont.regularFont(ofSize: 14), NSAttributedString.Key.foregroundColor: R.color.b5bcce()!]
        tf.attributedPlaceholder = NSAttributedString(string: SPLocalizedString("alert_remark_pl"), attributes: attributed)
        return tf
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = .regularFont(ofSize: 12)
        label.textColor = R.color.ff4c42()
        return label
    }()
    
    private lazy var topImageView: UIImageView = {
        let view = UIImageView(image: R.image.icon_success())
        view.isHidden = true
        return view
    }()
    
    private var style: AlertViewStyle = .default

    init(withStyle style: AlertViewStyle, actionCount: Int) {
        super.init(frame: CGRect(x: 0, y: 0, width: App.screenWidth, height: App.screenHeight))
        self.style = style
        self.actionCount = actionCount
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func bindViewModel() {
        let input = viewModel.input
        let output = viewModel.output
        leftBtn.rx.action = input.leftAction
        rightBtn.rx.action = input.rightAction
        closeBtn.rx.action = input.closeAction
        
        rx.disposeBag ~ [
            inputTF.rx.textInput <-> input.inputValue,
            output.alertTitle ~> titleLabel.rx.text,
            output.leftActionTitle ~> leftBtn.rx.title(for: .normal),
            output.rightActionTitle ~> rightBtn.rx.title(for: .normal),
            output.alertMessage ~> messageLabel.rx.text,
            output.alertMessage ~> tipsLabel.rx.text,
            output.alertMessage.subscribe(onNext: { [weak self] msg in
                guard let `self` = self else { return }
                guard self.style == .input else { return }
                if isEmpty(msg) {
                    self.updateInputStyleConstraints()
                }
            }),
//            output.error ~> errorLabel.rx.text,
//            output.inputBgBorderColor ~> inputBgView.rx.borderColor,
        ]
    }
}

private extension AlertView {
    func setup() {
        addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
            make.leading.equalToSuperview().offset(32)
            make.trailing.equalToSuperview().offset(-32)
        }
        addSubview(topImageView)
        topImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(bgView.snp.top)
        }
        bgView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(bgView).offset(style == .success ? 47.5 : 30)
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        if style != .input {
            bgView.addSubview(messageLabel)
            messageLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(16)
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
            }
        } else {
            bgView.addSubview(tipsLabel)
            tipsLabel.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(20)
                make.leading.equalToSuperview().offset(20)
                make.height.equalTo(15)
            }
            bgView.addSubview(inputBgView)
            inputBgView.snp.makeConstraints { make in
                make.top.equalTo(tipsLabel.snp.bottom).offset(14)
                make.leading.equalToSuperview().offset(20)
                make.trailing.equalToSuperview().offset(-20)
                make.height.equalTo(40)
            }
            inputBgView.addSubview(inputTF)
            inputTF.snp.makeConstraints{ $0.edges.equalTo(UIEdgeInsets(top: 11.5, left: 12, bottom: 11.5, right: 12)) }
            bgView.addSubview(errorLabel)
            errorLabel.snp.makeConstraints { make in
                make.leading.equalTo(inputBgView)
                make.top.equalTo(inputBgView.snp.bottom).offset(8)
            }
        }
        
        if actionCount == 1 {
            bgView.addSubview(rightBtn)
            rightBtn.snp.makeConstraints { make in
                make.top.equalTo(style != .input ? messageLabel.snp.bottom : inputBgView.snp.bottom).offset(28)
                make.centerX.equalToSuperview()
                make.height.equalTo(40)
                make.bottom.equalToSuperview().offset(-20)
                make.width.equalTo((App.screenWidth - 32 * 2 - 20 * 2 - 19) / 2.0)
            }
        } else {
            bgView.addSubview(leftBtn)
            leftBtn.snp.makeConstraints { make in
                make.top.equalTo(style != .input ? messageLabel.snp.bottom : inputBgView.snp.bottom).offset(28)
                make.leading.equalToSuperview().offset(20)
                make.height.equalTo(40)
                make.bottom.equalToSuperview().offset(-20)
            }
            bgView.addSubview(rightBtn)
            rightBtn.snp.makeConstraints { make in
                make.top.bottom.equalTo(leftBtn)
                make.trailing.equalToSuperview().offset(-20)
                make.leading.equalTo(leftBtn.snp.trailing).offset(19)
                make.width.equalTo((App.screenWidth - 32 * 2 - 20 * 2 - 19) / 2.0)
            }
        }
        bgView.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44, height: 44))
            make.top.trailing.equalToSuperview()
        }
        closeBtn.isHidden = style == .noclose
        topImageView.isHidden = style != .success
    }
    
    func updateInputStyleConstraints() {
        if style != .input {
            return
        }
        inputBgView.snp.remakeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        inputTF.snp.remakeConstraints { $0.edges.equalTo(UIEdgeInsets(top: 13, left: 12, bottom: 13, right: 12)) }
    }
}
