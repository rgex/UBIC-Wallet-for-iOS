//
//  PrivateKeyGenerator.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 06.10.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import Foundation

class PrivateKeyGenerator {
    func generate() -> String {
        var bytes = [UInt8](repeating: 0, count: 20)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        
        if status == errSecSuccess {
            var privateKey = ""
            for byte in bytes {
                privateKey.append(String(format:"%02X", Int(byte)))
            }
            
            return privateKey
        }
        
        return ""
    }
}
