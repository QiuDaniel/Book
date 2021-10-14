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
    
    private var window: UIWindow!
    private var previousInterfaceStyle: UIUserInterfaceStyle!
    
    private var _bookCity: BookCity?
    var appConfig: AppConfig?
    
    var bookCity: BookCity? {
        if _bookCity == nil {
            guard let storeString = AppStorage.shared.object(forKey: .bookCity) as? String else {
                return nil
            }
            let model = jsonToModel(storeString, BookCity.self)
            _bookCity = model
        }
        return _bookCity
    }
    
    var browseHistory: [BookRecord] {
        guard let historyStr = AppStorage.shared.object(forKey: .browseHistory) as? String else {
            return []
        }
        let history = jsonToModel(historyStr, [BookRecord].self)
        return history ?? []
    }
    
    var bookcase: [BookRecord] {
        guard let bookRecordStr = AppStorage.shared.object(forKey: .bookcase) as? String else {
            return []
        }
        let books = jsonToModel(bookRecordStr, [BookRecord].self)
        return books ?? []
    }
    
    static let shared = AppManager()
    
    override init() {
        super.init()
        addObserver()
        previousInterfaceStyle = .unspecified
    }
    
}

// MARK: - Public

extension AppManager {
    
    func applicationEnterance(withWindow window: UIWindow, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        self.window = window;
        self.window.backgroundColor = R.color.windowBgColor()
        initAdvertisement()
        userInterfaceChanged()
        supportWebP()
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
    
    func saveBookCity(_ bookCity: BookCity) {
        _bookCity = bookCity
        let string = modelToJson(bookCity)
        if !isEmpty(string) {
            guard let storeString = AppStorage.shared.object(forKey: .bookCity) as? String else {
                AppStorage.shared.setObject(string, forKey: .bookCity)
                AppStorage.shared.synchronous()
                return
            }
            if string != storeString {
                AppStorage.shared.setObject(string, forKey: .bookCity)
                AppStorage.shared.synchronous()
            }
        }
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
        keyboardManager.toolbarDoneBarButtonItemText = "完成"
        keyboardManager.toolbarManageBehaviour = .byPosition
        keyboardManager.shouldResignOnTouchOutside = true
        keyboardManager.shouldToolbarUsesTextFieldTintColor = true
    }
    
    func initAppStartController(withWindow window: UIWindow) {
        let sceneCoordinator = SceneCoordinator(window: window)
        SceneCoordinator.shared = sceneCoordinator
        sceneCoordinator.transition(to: Scene.launch(.default))
    }
    

    
    func initAdvertisement() {
        AdverManager.shared.start()
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
            switch interfaceStyle {
            case .light, .unspecified:
                window.overrideUserInterfaceStyle = .light
                previousInterfaceStyle = .light
            default:
                window.overrideUserInterfaceStyle = .dark
                previousInterfaceStyle = .dark
            }
//            window.overrideUserInterfaceStyle = interfaceStyle
//            previousInterfaceStyle = interfaceStyle
        case .light:
            window.overrideUserInterfaceStyle = .light
            previousInterfaceStyle = .light
        case .dark:
            window.overrideUserInterfaceStyle = .dark
            previousInterfaceStyle = .dark
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

