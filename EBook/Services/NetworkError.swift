//
//  NetworkError.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/28.
//

import Foundation

struct NetworkError: CustomNSError {
    static var errorDomain: String {
        return "com.daniel.error"
    }
    
    var errorCode: Int {
        return code
    }
    
    var errorUserInfo: [String : Any] {
        return ["msg": msg, "code": code]
    }
    
    var errorMsg: String {
        return msg
    }
    
    
    private let code: Int
    private let msg: String
    
    init(code: Int, msg: String) {
        self.code = code
        self.msg = msg
    }
}
