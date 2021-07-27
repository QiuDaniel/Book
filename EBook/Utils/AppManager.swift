//
//  AppManager.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/19.
//

import UIKit
import IQKeyboardManagerSwift
import KingfisherWebP
import Kingfisher

typealias WalletBizType = [String: [String: String]]

class AppManager: NSObject {
    
    var userDefautls: UserDefaults {
        return UserDefaults(suiteName: AppStoreKey.appGroups) ?? UserDefaults.standard
    }
    
    var isChinese: Bool {
        return LocalizebleHelper.appLanguage.contains("zh")
    }
    
   
    private var window: UIWindow!
    private var previousInterfaceStyle: UIUserInterfaceStyle!
    
    static let shared = AppManager()
    
    override init() {
        super.init()
        addObserver()
        LocalizebleHelper.initAppLanguage()
        previousInterfaceStyle = .unspecified
    }
    
}


extension AppManager {
    
    func applicationEnterance(withWindow window: UIWindow, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        self.window = window;
//        self.window.backgroundColor = R.color.windowBgColor()
        userInterfaceChanged()
        supportWebP()
        initLoadAppFile()
        initUMPush(launchOptions)
        initKeyboardManager()
        initAppStartController(withWindow: window)
//        umAddAlias()
    }
    
    func applicationDidBecomeActive() {
        let style = UITraitCollection.current.userInterfaceStyle
        if style == previousInterfaceStyle {
            return
        }
        userInterfaceChanged()
        previousInterfaceStyle = style
    }
    
}


// MARK: - Init

private extension AppManager {
    
    func initUMPush(_ launchOptions:[UIApplication.LaunchOptionsKey: Any]?) {
        UMConfigure.initWithAppkey(VendorKey.um.name, channel: App.channel)
        #if DEBUG
        let logEnable = true
        UMCommonLogManager.setUp()
        #else
        let logEnable = false
        #endif
        UMConfigure.setLogEnabled(logEnable)
        UNUserNotificationCenter.current().delegate = self
        let entity = UMessageRegisterEntity()
        entity.types = Int(UMessageAuthorizationOptions.badge.rawValue | UMessageAuthorizationOptions.alert.rawValue)
        UMessage.registerForRemoteNotifications(launchOptions: launchOptions, entity: entity) { (granted, error) in
            if granted {
                printLog("--qd-用户选择了接收Push消息")
            } else {
                printLog("--qd-用户拒绝接收Push消息")
            }
        }
    }
    
    func initKeyboardManager() {
        let keyboardManager = IQKeyboardManager.shared;
        keyboardManager.enable = true;
        keyboardManager.shouldShowToolbarPlaceholder = false;
        keyboardManager.enableAutoToolbar = true;
        keyboardManager.toolbarDoneBarButtonItemText = SPLocalizedString("str_complete")
        keyboardManager.toolbarManageBehaviour = .byPosition
        keyboardManager.shouldResignOnTouchOutside = true
        keyboardManager.shouldToolbarUsesTextFieldTintColor = true
    }
    
    func initAppStartController(withWindow window: UIWindow) {
        let sceneCoordinator = SceneCoordinator(window: window)
        SceneCoordinator.shared = sceneCoordinator
//        sceneCoordinator.transition(to: Scene.launch(.default))
    }
    
    func initUserAppLanguage() {
        
    }
    
    func initLoadAppFile() {
        MJRefreshConfig.default.languageCode = isChinese ? "zh-Hans" : "en"
//        localizableDic = getLocalFileDictionary(withStorageKey: isChinese ? .localizableFilePath : .localizableFilePathEN, orLocalFileName: isChinese ? "local_zh": "local_en")
//        errorDic = getLocalFileDictionary(withStorageKey: isChinese ? .codeFilePath : .codeFilePathEN, orLocalFileName: isChinese ? "error_zh": "error_en")
//        let filePath = Bundle.main.path(forResource: "ApiRouter", ofType: "plist")
//        apiRouter = (NSDictionary(contentsOfFile: filePath!) as! [String: Int])
    }
    
    func supportWebP() {
        KingfisherManager.shared.defaultOptions += [.processor(WebPProcessor.default), .cacheSerializer(WebPSerializer.default)]
    }
    
    func getLocalFileDictionary(withStorageKey key: AppStorageKey, orLocalFileName name: String) -> [String: String] {
        var output: [String: String] = [:]
        if let codeFilePath = AppStorage.shared.object(forKey: key) as? String, let cachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first, let codeData = try? Data(contentsOf: URL(fileURLWithPath: cachesPath.appending("/\(codeFilePath)"))) {
            output = try! JSONSerialization.jsonObject(with: codeData, options: .allowFragments) as! [String: String]
        } else {
            let filePath = Bundle.main.path(forResource: name, ofType: "json")
            let data = try! Data(contentsOf: URL(fileURLWithPath: filePath!))
            output = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : String]
        }
        return output
    }
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(userInterfaceChanged), name: SPNotification.interfaceChanged.name, object: nil)
    }
    
    @objc
    func userInterfaceChanged() {
        let style = UserinterfaceManager.shared.interfaceStyle
        switch style {
        case .system:
            let interfaceStyle = UITraitCollection.current.userInterfaceStyle
            window.overrideUserInterfaceStyle = interfaceStyle
            previousInterfaceStyle = interfaceStyle
        case .light:
            window.overrideUserInterfaceStyle = .light
        case .dark:
            window.overrideUserInterfaceStyle = .dark
        }
    }
}

// MARK: - Push

extension AppManager {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        #if DEBUG
        var deviceTokenStr = deviceToken.description.replacingOccurrences(of: "<", with: "").replacingOccurrences(of: ">", with: "").replacingOccurrences(of: " ", with: "")
        if #available(iOS 13.0, *) {
            deviceTokenStr = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        }
        printLog("--qd---deviceToken is \(deviceTokenStr)")
        #endif
        UMessage.registerDeviceToken(deviceToken)
    }
    
}

// MARK: - UNUserNotificationCenterDelegate

extension AppManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        if let trigger = notification.request.trigger, trigger.isKind(of: UNPushNotificationTrigger.self) {
            UMessage.setAutoAlert(false)
            //应用处于前台时的远程推送接受
            //必须加这句代码
            UMessage.didReceiveRemoteNotification(userInfo)
        } else {
            //应用处于前台时的本地推送接受
        }
        completionHandler([.sound, .badge, .alert])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let trigger = response.notification.request.trigger, trigger.isKind(of: UNPushNotificationTrigger.self) {
//            handleNotification(userInfo: userInfo)
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {

    }
}

