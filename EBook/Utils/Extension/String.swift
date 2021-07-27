//
//  String.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/5/24.
//

import Foundation
import CryptoKit

extension String {
    
    private static let keyString = "Gglz6D5RinFXvPy1WJVLbKZTB7ema9fMtHrxu0Ch48dOc3jYkQS2pIUNsowAEqwrdWFkPAcUlBKMx7S2pFjnxfF0XUlJWR9GjzmLYk8rwhqcYJjqltb4v6hJaHuNa9TSE5U7Jk4evh8iiUp2TDeRrQN5hRUlzQGgX9Md3bHzDMsG3R7zmk3mqPqSXv2g0G0skbYr9XxrNBH8MmvgvdsGZA5881NHpyAcBIX3Ztf94IAO0DZIxvyrtRKOlWZdr32S"
    
    var md5String: String {
        let digest = Insecure.MD5.hash(data: data(using: .utf8)!)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    var SHA256String: String {
        let digest = SHA256.hash(data: data(using: .utf8)!)
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
    
    var urlEncode: String {
        let charaters = "~?!@#$^&%*+,:;='\"`<>()[]{}/\\| "
        let set = CharacterSet(charactersIn: charaters).inverted
        return addingPercentEncoding(withAllowedCharacters: set)!
    }
    
    var isEmailAddress: Bool {
        return check(withRegex: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,10}")
    }
    
    var isAccount: Bool {
        return hasPrefix("sp_")
    }
    
    var isETHAddress: Bool {
        return check(withRegex: "(0x)?[a-fA-F0-9]{40}$")
    }
    
    var isCKBAddress: Bool {
        return check(withRegex: "^(ckb)?[a-z0-9]{43}$")
    }
    
    var isBeamAddress: Bool {
        return check(withRegex: "[a-zA-Z0-9]*")
    }
    
    var isDigital: Bool {
        return check(withRegex: "[0-9]*")
    }
    
    var isMeetSparkName: Bool {
        return check(withRegex: "^[0-9a-z]{3,10}$")
    }
    
    var hasHexPrefix: Bool {
        return hasPrefix("0x")
    }
    
    var add0xIfNeeded: String {
        if hasHexPrefix {
            return self
        }
        return String(format: "0x%@", self)
    }
    
    /// 去掉首尾空格
    var removeHeadAndTailSpace: String {
       return self.trimmingCharacters(in: .whitespaces)
    }
    /// 去掉首尾空格，包括后面的换行 \n
    var removeHeadAndTailSpacePro: String {
       return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
       
    /// 去掉所有空格
    var removeAllSpace: String {
       return self.replacingOccurrences(of: " ", with: "", options: .literal)
    }
    
    func substring(to: Int) -> String {
        return String(dropLast(count - to))
    }
    
    func substring(from: Int) -> String {
        return String(dropFirst(from))
    }
    
    
    static func encryptChachaPoly(_ message: String) -> Data? {
        let key256 = try! SymmetricKey(string: keyString)
        let data = message.data(using: .utf8)!
        return try? ChaChaPoly.seal(data, using: key256).combined 
    }
    
    static func decryptChachaPoly(_ encryptedData: Data) -> String? {
        let key256 = try! SymmetricKey(string: keyString)
        if let sealedBox = try? ChaChaPoly.SealedBox(combined: encryptedData) {
            if let data = try? ChaChaPoly.open(sealedBox, using: key256) {
                return String(data: data, encoding: .utf8)
            }
        }
        return nil
    }
    
    static func connectURL(_ string: String, withParams params:[String: String]) -> String {
        var str = "?"
        if string.contains("?") {
            str = "&"
        }
        params.forEach { (key, value) in
            str = str.appending(key)
            str = str.appending("=")
            str = str.appending(value)
            str = str.appending("&")
        }
        if str.count > 1 {
            str = str.substring(to: str.count - 1)
            return string.appending(str)
        }
        return string
    }
    
    func toJSON() -> JSONObject? {
        var jsonObject: JSONObject? = nil
        if let data = data(using: .utf8) {
            jsonObject = try? JSONSerialization.jsonObject(with: data) as? JSONObject
        }
        return jsonObject
    }
    
    func replaceWordSymbols(withText text: String) -> String {
        return replaceWordSymbols(withTexts: [text])
    }
    
    func replaceWordSymbols(withTexts texts: [String]) -> String {
        let strArr = self.components(separatedBy: "{0}")
        if strArr.count <= 1 {
            return self
        }
        var str = ""
        if strArr.count < texts.count {
            return self
        }
        for (idx, text) in texts.enumerated() {
            str = str.appending(strArr[idx].appending(text))
        }
        if strArr.count > texts.count {
            str = str.appending(strArr[strArr.count - 1])
        }
        return str
    }
    
    func size(withFont font: UIFont, forWidth width: CGFloat) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        return size(withAttributes: attributes, forWidth: width)
    }
    
    func size(withAttributes attributes: [NSAttributedString.Key: Any], forWidth width: CGFloat) -> CGSize {
        return size(withAttributes: attributes, forStringSize: CGSize(width: width, height: .greatestFiniteMagnitude))
    }
    
    func size(withAttributes attributes: [NSAttributedString.Key: Any], forStringSize stringSize: CGSize) -> CGSize {
        let nsstring = NSString(string: self)
        let options: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading, .truncatesLastVisibleLine]
        let size = nsstring.boundingRect(with: stringSize, options: options, attributes: attributes, context: nil).size
        return size
    }
    
    subscript (i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
    
    subscript (r: Range<Int>) -> String {
      let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
                                          upper: min(count, max(0, r.upperBound))))
      let start = index(startIndex, offsetBy: range.lowerBound)
      let end = index(start, offsetBy: range.upperBound - range.lowerBound)
      return String(self[start ..< end])
    }
    
}

private extension String {
    func check(withRegex: String) -> Bool {
        let pred = NSPredicate(format: "SELF MATCHES %@", withRegex)
        return pred.evaluate(with: self)
    }
}
