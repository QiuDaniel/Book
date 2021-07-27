//
//  Network.swift
//  EBook
//
//  Created by SPARK-Daniel on 2021/7/27.
//

import Foundation
import Moya
import Alamofire

enum Network {
    case bookCity(String, String)
    case bookCityPath(String)
}

extension Network: TargetType {
    
    var baseURL: URL {
        var urlString = "https://api.bxxsapp.com"
        switch self {
        case .bookCityPath(let path):
            urlString = path
        default:
            break
        }
        guard let url = URL(string: urlString) else {
            fatalError("URL Failed:\(urlString)")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .bookCity:
            return "/api/v1/getbookcolumn"
        default:
            return ""
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .bookCity, .bookCityPath:
            return .get
        }
    }
    
    var task: Task {
        let encoding = URLEncoding.default
        switch self {
        case .bookCityPath:
            return .requestPlain
        case let .bookCity(device, pkgName):
            var params: [String: Any] = [:]
            params["device"] = device
            params["pkgName"] = pkgName
            return .requestParameters(parameters: params, encoding: encoding)
        }
        
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var validationType: ValidationType {
        return .successAndRedirectCodes
    }
    
    var headers: [String : String]? {
        var localParams:[String: String] = [:]
//        localParams["versionNumber"] = "3"
        localParams["appId"] = "46"
//        localParams["channelId"] = "41"
//        localParams["device"] = ""
        return localParams
    }
}
