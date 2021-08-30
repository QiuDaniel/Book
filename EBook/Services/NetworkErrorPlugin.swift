//
//  NetworkErrorPlugin.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import Foundation
import Moya

final class NetworkErrorPlugin: PluginType {

    func process(_ result: Result<Response, MoyaError>, target: TargetType) -> Result<Response, MoyaError> {
        if case .success(let response) = result {
            if let model = try? response.map(ResponseModel.self) {
                #warning("App首次启动需要存储时间， 好好整理时间比较方式")
                printLog("qd===服务器时间:\(model.time)")
                if model.code == 200 {
                    return result
                } else {
                    let msg = isEmpty(model.msg) ? "服务器请求失败" : model.msg
                    delay(0.5) {
                        Toast.show(msg)
                    }
                    return Result.failure(MoyaError.underlying(NetworkError(code: model.code, msg: msg), response))
                }
            }
            return result
        }
        return result
    }
    
}

struct ResponseModel: Codable {
    let code: Int
    let msg: String
    let time: String
   
    enum CodingKyes: String, CodingKey {
        case code
        case msg
        case time
    }
}
