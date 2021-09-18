//
//  NetworkSession.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import Foundation
import Alamofire

class NetworkSession: Alamofire.Session  {
    static let shared: NetworkSession = {
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default
        configuration.timeoutIntervalForRequest = 4 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 4 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return NetworkSession(configuration: configuration)
    }()
}
