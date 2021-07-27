//
//  SymmetricKey.swift
//  SparkPool
//
//  Created by SPARK-Daniel on 2021/6/3.
//

import CryptoKit

extension SymmetricKey {
  init(string keyString: String, size: SymmetricKeySize = .bits256) throws {
    guard var keyData = keyString.data(using: .utf8) else {
      print("Could not create base64 encoded Data from String.")
      throw CryptoKitError.incorrectParameterSize
    }
    
    let keySizeBytes = size.bitCount / 8
    keyData = keyData.subdata(in: 0..<keySizeBytes)
    
    guard keyData.count >= keySizeBytes else { throw CryptoKitError.incorrectKeySize }
    self.init(data: keyData)
  }
}
