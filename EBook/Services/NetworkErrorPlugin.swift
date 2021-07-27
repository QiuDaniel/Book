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
//            if let model = try? response.map(ResponseModel.self) {
//                if model.code == 200 {
//                    return result
//                } else {
//                    var errorKey = "\(model.code)"
//                    if let subCodes = model.subCodes, subCodes.count > 0 {
//                        errorKey = "\(subCodes[0])"
//                    }
//                    let msg = AppManager.shared.errorDic[errorKey] ?? SPLocalizedString("toast_request_service_error")
//                    if target.showErrorToast {
//                        delay(0.5) {
//                            Toast.show(msg)
//                        }
//                    }
//                    return Result.failure(MoyaError.underlying(SparkServiceError(code: model.code, msg: msg), response))
//                }
//            }
            return result
        }
        return result
    }
    
}
