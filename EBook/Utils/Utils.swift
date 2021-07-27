//
//  Utils.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/19.
//

import UIKit

typealias JSONObject = [String: Any]

func dispatch_async_safely_to_main_queue(_ block: @escaping ()->()) {
    dispatch_async_safely_to_queue(DispatchQueue.main, block)
}

// This methd will dispatch the `block` to a specified `queue`.
// If the `queue` is the main queue, and current thread is main thread, the block
// will be invoked immediately instead of being dispatched.
func dispatch_async_safely_to_queue(_ queue: DispatchQueue, _ block: @escaping ()->()) {
    if queue === DispatchQueue.main && Thread.isMainThread {
        block()
    } else {
        queue.async {
            block()
        }
    }
}

func modelToJson<T: Encodable>(_ model: T) -> String {
    let jsonEncoder = JSONEncoder()
    let jsonData = try? jsonEncoder.encode(model)
    if let jsonData = jsonData {
        let str = String(data: jsonData, encoding: .utf8)
        return str ?? ""
    }
    return ""
}

func jsonToModel<T: Decodable>(_ string: String, _ type: T.Type) -> Optional<T> {
    let jsonDecoder = JSONDecoder()
    let jsonData = string.data(using: .utf8)
    if let jsonData = jsonData {
        let model: Optional<T> = try? jsonDecoder.decode(type, from: jsonData)
        return model
    }
    return nil
}

func jsonToModel<T: Decodable>(_ jsonObject: JSONObject, _ type: T.Type) -> Optional<T> {
    let jsonDecoder = JSONDecoder()
    let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [])
    if let jsonData = jsonData {
        let model: Optional<T> = try? jsonDecoder.decode(type, from: jsonData)
        return model
    }
    return nil
}

func jsonToModels<T: Decodable>(_ jsonObjects: [JSONObject], _ type: T.Type) -> [T] {
    var models = [T]()
    for object in jsonObjects {
        if let model = jsonToModel(object, T.self) {
            models.append(model)
        }
    }
    return models
}

func printLog<T>(_ message: T,
                 file: String = #file,
                 method: String = #function,
                 line: Int = #line) {
    #if DEBUG
    print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}

func synchronized(_ lock: Any, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

/// 延时
typealias SWTask = (_ cancel : Bool) -> Void


@discardableResult
func delay(_ time: TimeInterval, task: @escaping ()->()) ->  SWTask? {
    
    func dispatch_later(block: @escaping ()->()) {
        let t = DispatchTime.now() + time
        DispatchQueue.main.asyncAfter(deadline: t, execute: block)
    }
    var closure: (() -> Void)? = task
    var result: SWTask?
    
    let delayedClosure: SWTask = {
        cancel in
        if let internalClosure = closure {
            if (cancel == false) {
                DispatchQueue.main.async(execute: internalClosure)
            }
        }
        closure = nil
        result = nil
    }
    
    result = delayedClosure
    
    dispatch_later {
        if let delayedClosure = result {
            delayedClosure(false)
        }
    }
    return result
}

func cancel(_ task: SWTask?) {
    task?(true)
}

func adjustScrollView(_ scrollView: UIScrollView, with controller: UIViewController) {
    if #available(iOS 11, *) {
        scrollView.contentInsetAdjustmentBehavior = .never
    } else {
        controller.automaticallyAdjustsScrollViewInsets = false
    }
}

func scaleX(_ x: CGFloat) -> CGFloat {
    return x * App.screenWidth / 375.0
}

func scaleF(_ x: CGFloat) -> CGFloat {
    return floor(scaleX(x))
}

func scaleC(_ x: CGFloat) -> CGFloat {
    return ceil(scaleX(x))
}

func SPLocalizedString(_ string: String) -> String {
    return NSLocalizedString(string, comment: "")
//#if DEBUG
//    return AppManager.shared.localizableDic[string]!.replacingOccurrences(of: "\\n", with: "\n")
//#else
//    return AppManager.shared.localizableDic[string]?.replacingOccurrences(of: "\\n", with: "\n") ?? ""
//#endif
}

func isEmpty(_ string: String?) -> Bool {
    guard let string = string else { return true }
    if string.isEmpty || string.removeAllSpace.isEmpty {
        return true
    }
    return false
}

func isSameMonth(date1: Date, inSameMonthAs date2: Date) -> Bool {
    let calendar = Calendar.current
    let comp1 = calendar.dateComponents([.year, .month], from: date1)
    let comp2 = calendar.dateComponents([.year, .month], from: date2)
    
    return comp1.year == comp2.year && comp1.month == comp2.month
}


func dismissViewController(_ viewController: UIViewController, animated: Bool) {
    if viewController.isBeingDismissed || viewController.isBeingPresented {
        dispatch_async_safely_to_main_queue {
            dismissViewController(viewController, animated: animated)
        }
        return
    }

    if viewController.presentingViewController != nil {
        viewController.dismiss(animated: animated, completion: nil)
    }
}


/// Compare version
/// - Parameters:
///   - version1: version need to be compared
///   - version2: version need to be compared
/// - Returns: -1 means version1 < version2, 0 means version1 = verison2, 1 means version1 > version2
func compareVersion(version1: String, version2: String) -> Int {
    var pA = 0
    var pB = 0
    
    func findDigit(str: String, start: Int) -> Int {
        var i = start
        while i < str.count && str[i] != "." {
            i += 1
        }
        return i
    }
    
    while pA < version1.count && pB < version2.count {
        let nextA = findDigit(str: version1, start: pA)
        let nextB = findDigit(str: version2, start: pB)
        let numA = Int(version1[pA..<nextA])!
        let numB = Int(version2[pB..<nextB])!
        if numA != numB {
            return numA > numB ? 1 : -1
        }
        pA = nextA + 1
        pB = nextB + 1
    }
    while pA < version1.count {
        let nextA = findDigit(str: version1, start: pA)
        let numA = Int(version1[pA..<nextA])!
        if numA > 0 {
            return 1
        }
        pA = nextA + 1
    }
    
    while pB < version2.count {
        let nextB = findDigit(str: version2, start: pB)
        let numB = Int(version2[pB..<nextB])!
        if numB > 0 {
            return -1
        }
        pB = nextB + 1
    }
    
    return 0
}

/// Compare app version
/// - Parameters:
///   - v1: app version 1
///   - v2: app version 2
/// - Returns: if v1 > v2 true, else false
func versionCompare(v1: String, v2: String) -> Bool {
    let tmp1 = "0.".appending(v1.replacingOccurrences(of: ".", with: ""))
    let tmp2 = "0.".appending(v2.replacingOccurrences(of: ".", with: ""))
    return Float(tmp1)! > Float(tmp2)!
}
