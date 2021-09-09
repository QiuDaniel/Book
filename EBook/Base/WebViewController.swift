//
//  WebViewController.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/1.
//

import UIKit
import RxWebKit
import WebKit
import RxCocoa
import RxSwift

private let kJSScript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
private let kH5CallApp = "appJS"

class WebViewController: BaseViewController {
    
    var urlString: String!
    var redirect = true //是否允许重定向
    var noCache = false //是否使用缓存
    var onLine = true // 忽略本地缓存
    var showLoadingProgress = true //显示加载进度条
    
    private (set) var webView: WKWebView!
    private var request: URLRequest!
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView(frame: CGRect(x: 0, y: App.naviBarHeight, width: App.screenWidth, height: 2))
        view.trackTintColor = .clear
        view.progressTintColor = UIColor(hexString: "#ff7828")
        view.alpha = 0.0
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: - Override

extension WebViewController {
    @objc
    func shouldStartDecidePolicy(_ request: URLRequest) -> Bool {
        guard let string = request.url?.absoluteString as NSString? else {
            return redirect
        }
        if string.range(of: urlString).location != NSNotFound {
            return true
        } else {
            return redirect
        }
    }
    
    @objc
    func didStartNavigation() {}
    @objc
    func finishLoadNavigation(_ request: URLRequest) {}
    @objc
    func failLoadNavigation(_ request: URLRequest, error: Error) {}
    @objc
    func jsCallBack(_ message:WKScriptMessage) {}

}

// MARK: - WKUIDelegate

extension WebViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        } else {
            if !navigationAction.targetFrame!.isMainFrame {
                webView.load(navigationAction.request)
            }
        }
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: prompt, message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "complete", style: .default, handler: { _ in
            completionHandler(alert.textFields?[0].text)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "Tip", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "confirm", style: .default, handler: { _ in
           completionHandler()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Tip", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { _ in
            completionHandler(false)
        }))
        alert.addAction(UIAlertAction(title: "confirm", style: .default, handler: { _ in
            completionHandler(true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Public

extension WebViewController {
    
    func loadData() {
        guard let encodeUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }
        guard let url = URL(string: encodeUrl) else {
            printLog("url生成失败, urlString = \(String(describing: urlString))")
            return
        }
        request = URLRequest(url: url, cachePolicy: onLine ? .reloadIgnoringCacheData : (noCache ? .returnCacheDataElseLoad : .useProtocolCachePolicy), timeoutInterval: 40.0)
        webView.load(request)
    }
    
    func callbackToken(_ token: String) {
        let js = String(format: "window.sparkpool.fetchToken('%@')", token)
        webView.evaluateJavaScript(js) { _, error in
            if error != nil {
                printLog("webview error:\(error!)")
            } else {
                printLog("webview 注入 token 成功")
            }
        }
    }
}

// MARK: - Private

private extension WebViewController {
    func setup() {
        navigationBar.backgroundView.backgroundColor = UIColor(hexString: "#FFFFFF")
        navigationBar.titleLabel?.textColor = UIColor(hexString: "#0B1E3C")
        navigationBar.bottomBorderColor = UIColor(hexString: "#E8E8E8")
        let wkUserScript = WKUserScript(source: kJSScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        let wkUserContentController = WKUserContentController()
        wkUserContentController.addUserScript(wkUserScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUserContentController
        webView = WKWebView(frame: .zero, configuration: wkWebConfig)
        webView.uiDelegate = self
        webView.backgroundColor = .clear
        webView.subviews.forEach { aView in
            if aView.isKind(of: UIScrollView.self) {
                let scroll = aView as! UIScrollView
                scroll.showsHorizontalScrollIndicator = false
                aView.subviews.forEach{ shadowView in
                    if shadowView.isKind(of: UIImageView.self) {
                        shadowView.isHidden = true
                    }
                }
            }
        }
        adjustScrollView(webView.scrollView, with: self)
        view.addSubview(webView)
        webView.snp.makeConstraints { $0.edges.equalTo(UIEdgeInsets(top: App.naviBarHeight, left: 0, bottom: 0, right: 0)) }
        webView.evaluateJavaScript("navigator.userAgent") { [weak self] result, error in
            guard let `self` = self else { return }
            guard let userAgent = result as? String else {
                return
            }
            let newUserAgent = userAgent.appending("/sparkpool/\(App.appVersion)")
            let dic: [String :Any] = ["UserAgent": newUserAgent]
            UserDefaults.standard.register(defaults: dic)
            UserDefaults.standard.synchronize()
            self.webView.customUserAgent = newUserAgent
        }
        view.addSubview(progressView)
        bindRxActions()
        bindEstimatedProgress()
    }
    
    func bindRxActions() {
        webView.rx
            .decidePolicyNavigationAction
            .debug("decidePolicyNavigationAction")
            .subscribe(onNext: { [weak self] webView, action, handler in
            guard let `self` = self else { return }
            if action.targetFrame == nil {
                webView.load(action.request)
            }
            handler(self.shouldStartDecidePolicy(action.request) ? .allow : .cancel)
            
        }).disposed(by: rx.disposeBag)
        webView.rx
            .didStartProvisionalNavigation
            .debug("didStartProvisionalNavigation")
            .subscribe(onNext: {[weak self] _ in
                guard let `self` = self else { return }
                self.didStartNavigation()
            })
            .disposed(by: rx.disposeBag)
        webView.rx
            .didFinishNavigation
            .observe(on: MainScheduler.instance)
            .debug("didFinishNavigation")
            .subscribe(onNext: { [weak self] _, _ in
                guard let `self` = self else { return }
                self.finishLoadNavigation(self.request)
            })
            .disposed(by: rx.disposeBag)
        webView.rx
            .didFailNavigation
            .observe(on: MainScheduler.instance)
            .debug("didFailNavigation")
            .subscribe(onNext: { [weak self] _, _, error in
                guard let `self` = self else { return }
                self.failLoadNavigation(self.request, error: error)
            })
            .disposed(by: rx.disposeBag)
        
        webView.rx
            .didReceiveChallenge
            .debug("didReceiveChallenge")
            .subscribe(onNext: {(webView, challenge, handler) in
                guard let serverTrust = challenge.protectionSpace.serverTrust else {
                    handler(.performDefaultHandling, nil)
                    return
                }
                let credential = URLCredential(trust: serverTrust)
                handler(.useCredential, credential)
            })
            .disposed(by: rx.disposeBag)
        webView.configuration.userContentController.rx.scriptMessage(forName: kH5CallApp).subscribe(onNext: { [weak self] message in
            guard let `self` = self else { return }
            self.jsCallBack(message)
        }).disposed(by: rx.disposeBag)
    }
    
    func bindEstimatedProgress() {
        if !showLoadingProgress {
            return
        }
        webView.rx.estimatedProgress.subscribe(onNext: { [weak self] progress in
            guard let `self` = self else { return }
            if self.progressView.alpha == 0 && progress > 0 {
                self.progressView.progress = 0
                UIView.animate(withDuration: 0.2, animations: {
                    self.progressView.alpha = 1.0
                }, completion: { finished in
                    if progress == 1 {
                        UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveEaseIn, animations: {
                            self.progressView.alpha = 0
                        }, completion: nil)
                    }
                })
            } else if self.progressView.alpha == 1 && progress == 1 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.progressView.alpha = 0
                }, completion: { finished in
                    self.progressView.progress = 0
                })
            }
            self.progressView.setProgress(Float(progress), animated: true)
        }).disposed(by: rx.disposeBag)
    }
    
    func bindTitle() {
        webView.rx.title.bind(to: navigationBar.rx.title).disposed(by: rx.disposeBag)
    }
    
    func value(_ value: String, inDictionary dictionary:JSONObject) -> Bool {
        if dictionary.keys.contains("type") {
            if let dicValue = dictionary["type"] as? String {
                return dicValue == value
            }
        }
        return false
    }
}

extension Reactive where Base: WebViewController {
    var url: Binder<String> {
        return Binder(base) { [weak base] _, value in
            base?.urlString = value
            base?.loadData()
        }
    }
}
