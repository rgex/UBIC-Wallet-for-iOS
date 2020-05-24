//
//  ChallengeParser.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 29.12.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import Foundation

class ChallengeParser {
    
    private var challenge: String = "" // example: 3-utopia.org/kyc/challenge=123456789

    init(newChallenge: String) {
        self.challenge = newChallenge
    }

    func validateChallenge() -> Bool {

        if self.challenge.count < 5 { // too short
            return false
        }

        let firstChar = Tools.substr(string: challenge, from: 0, size: 1)
        let secondChar = Tools.substr(string: challenge, from: 1, size: 1)

        if firstChar != "0" || firstChar != "1" || firstChar != "2" || firstChar != "3" {
            return false
        }
        if secondChar != "-" {
            return false
        }

        return true
    }

    func getAuthenticationMode() -> Int {
        if self.validateChallenge() {
            return Int(Tools.substr(string: challenge, from: 0, size: 1)) ?? 0
        }

        return 0
    }

    func getUrl() -> String {
        return "http://" + Tools.substr(string: challenge, from: 2, size: self.challenge.count)
    }
    
    func getDomain() -> String {
        return ""
    }
}
