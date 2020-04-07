//
//  KeyStoreWrapper.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 06.10.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import Foundation

class KeyStore {
    
    func getUBICkeyStoreSize() -> UInt16 {
        var i = 0
        var status: OSStatus
        var query: [String: Any]
        repeat {
            let tag = "UBICkey_" + String(i)
            query = [kSecClass as String: kSecClassGenericPassword,
                          kSecAttrService as String: "UBIC private keys",
                          kSecAttrAccount as String: tag,
                          kSecReturnData as String: true]
            i += 1
            
            var result: AnyObject? = nil
            status = SecItemCopyMatching(query as CFDictionary, &result)
        } while status == noErr
        
        return UInt16(i - 1)
    }
    
    func getNextUBICkeyStoreTag() -> String {
        let NextUBICkeyStoreTag: String
        NextUBICkeyStoreTag = ("UBICkey_" + String(getUBICkeyStoreSize()))
        return NextUBICkeyStoreTag
    }
    
    func addOtherKey(privateKey: String) -> Bool {
        let tag = getNextUBICkeyStoreTag()
        print("getNextUBICkeyStoreTag: \(tag)")
        
        let query : [String:Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService as String: "UBIC private keys",
            kSecAttrAccount as String: tag,
            kSecValueData as String : privateKey.data(using: .utf8)!,
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        print("add status: \(status)")
        return status == errSecSuccess
    }
    
    func setCurrent(privateKey: String) -> Bool {
        // if there is a current privateKey move it to the other orivate keys
        print("getCurrentKey(): \(getCurrentKey())")
        
        //delete the key we wanrt to add to current from others
        deleteKeyFromOther(privateKey: privateKey)

        let currentKey = getCurrentKey()
        if currentKey != "" {
            addOtherKey(privateKey: currentKey)
            
            // then delete the current item
            let query : [String:Any] = [
                kSecClass as String : kSecClassGenericPassword,
                kSecAttrService as String: "UBIC private keys",
                kSecAttrAccount as String: "UBICkey_current",
                kSecValueData as String : privateKey.data(using: .utf8)!,
            ]
            SecItemDelete(query as CFDictionary)
        }
        
        let query : [String:Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrService as String: "UBIC private keys",
            kSecAttrAccount as String: "UBICkey_current",
            kSecValueData as String : privateKey.data(using: .utf8)!,
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        print("add status: \(status)")
        return status == errSecSuccess
    }
    
    func deleteKeyFromOther(privateKey: String) -> Bool {
        
        var i = 0
        var status: OSStatus
        var query: [String: Any]
        repeat {
            let tag = "UBICkey_" + String(i)
            query = [kSecClass as String: kSecClassGenericPassword,
                          kSecAttrService as String: "UBIC private keys",
                          kSecAttrAccount as String: tag,
                          kSecReturnData as String: true]
            i += 1
            
            var result: AnyObject? = nil
            status = SecItemCopyMatching(query as CFDictionary, &result)
            if status == noErr && privateKey == String(data: result as! Data, encoding: .utf8) {
                let query : [String:Any] = [
                    kSecClass as String : kSecClassGenericPassword,
                    kSecAttrService as String: "UBIC private keys",
                    kSecAttrAccount as String: tag,
                    kSecValueData as String : privateKey.data(using: .utf8)!,
                ]
                SecItemDelete(query as CFDictionary)
                return true
            }
        } while status == noErr
        
        return false
    }
    
    func getCurrentKey() -> String {
        let tag = "UBICkey_current"
        let query : [String:Any] = [kSecClass as String: kSecClassGenericPassword,
                      kSecAttrService as String: "UBIC private keys",
                      kSecAttrAccount as String: tag,
                      kSecReturnData as String: true]
        
        var result: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == noErr {
            if let privateKey = String(data: result as! Data, encoding: .utf8) {
                return privateKey
            }
        }
        
        return String("")
    }
    
    func getCurrentAddress() -> String {
        let currentSeed = self.getCurrentKey()

        if let seedData = currentSeed.hexToData() {
            let address = SwiftWrapper.getAddress(seed: seedData)

            return address
        }
        
        return ""
    }
    
    func getOtherKeys() -> [String] {
        var i = 0
        var status: OSStatus
        var query: [String: Any]
        var privateKeys: [String] = []
        repeat {
            let tag = "UBICkey_" + String(i)
            query = [kSecClass as String: kSecClassGenericPassword,
                          kSecAttrService as String: "UBIC private keys",
                          kSecAttrAccount as String: tag,
                          kSecReturnData as String: true]
            i += 1
            
            var result: AnyObject? = nil
            status = SecItemCopyMatching(query as CFDictionary, &result)
            if(status == noErr) {
                print("Found tag: \(tag)")
                let privateKey = String(data: result as! Data, encoding: .utf8)
                privateKeys.append(privateKey!)
            }
        } while status == noErr
        
        return privateKeys
    }
}
