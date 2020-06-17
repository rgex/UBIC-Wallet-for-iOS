//
//  ServerSelector.swift
//  UBIC Wallet
//
//  Created by Jan Lindemann on 17/06/2020.
//  Copyright © 2020 Bondi. All rights reserved.
//

import Foundation

class ServerSelector {
    static func getBaseUrl() -> String {
        let secondsFromGMT = TimeZone.current.secondsFromGMT()
        NSLog("secondsFromGMT: " + String(secondsFromGMT))
        if secondsFromGMT >= 5 * 3600 && secondsFromGMT <= 12 * 3600 {
            NSLog("Selected the ubic.asia server")
            return "https://ubic.asia";
        }
        NSLog("Selected the ubic.network server")
        return "https://ubic.network";
    }
}
