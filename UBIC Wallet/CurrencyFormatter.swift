//
//  CurrencyFormatter.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 22.10.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import Foundation

class CurrencyFormatter {
    static let subUnits = 1000000.0
    
    static func formatAmount(_ amount: Int64) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if let formattedNumber = numberFormatter.string(from: NSNumber(value:(Double(amount) / CurrencyFormatter.subUnits))) {
            return formattedNumber
        }
        
        return "???"
    }
    
    static func getcurrencyCodeFromId(_ id: Int) -> String {
        switch id {
        case 1:
            return "UCH"
        case 2:
            return "UDE"
        case 3:
            return "UAT"
        case 4:
            return "UUK"
        case 5:
            return "UIE"
        case 6:
            return "UUS"
        case 7:
            return "UAU"
        case 8:
            return "UCN"
        case 9:
            return "USE"
        case 10:
            return "UFR"
        case 11:
            return "UCA"
        case 12:
            return "UJP"
        case 13:
            return "UTH"
        case 14:
            return "UNZ"
        case 15:
            return "UAE"
        case 16:
            return "UFI"
        case 17:
            return "ULU"
        case 18:
            return "USG"
        case 19:
            return "UHU"
        case 20:
            return "UCZ"
        case 21:
            return "UMY"
        case 22:
            return "UUA"
        case 23:
            return "UEE"
        case 24:
            return "UMC"
        case 25:
            return "ULI"
        case 26:
            return "UIS"
        case 27:
            return "UHK"
        case 28:
            return "UES"
        case 29:
            return "URU"
        case 30:
            return "UIL"
        case 31:
            return "UPT"
        case 32:
            return "UDK"
        case 33:
            return "UTR"
        case 34:
            return "URO"
        case 35:
            return "UPL"
        case 36:
            return "UNL"
        case 37:
            return "UPH"
        case 38:
            return "UIT"
        case 39:
            return "UBR"
        default:
            return ""
        }
    }
    
    static func getcurrencyIdFromCode(_ code: String) -> Int {
        switch code.uppercased() {
            case "UCH":
                return 1
            case "UDE":
                return 2
            case "UAT":
                return 3
            case "UUK":
                return 4
            case "UIE":
                return 5
            case "UUS":
                return 6
            case "UAU":
                return 7
            case "UCN":
                return 8
            case "USE":
                return 9
            case "UFR":
                return 10
            case "UCA":
                return 11
            case "UJP":
                return 12
            case "UTH":
                return 13
            case "UNZ":
                return 14
            case "UAE":
                return 15
            case "UFI":
                return 16
            case "ULU":
                return 17
            case "USG":
                return 18
            case "UHU":
                return 19
            case "UCZ":
                return 20
            case "UMY":
                return 21
            case "UUA":
                return 22
            case "UEE":
                return 23
            case "UMC":
                return 24
            case "ULI":
                return 25
            case "UIS":
                return 26
            case "UHK":
                return 27
            case "UES":
                return 28
            case "URU":
                return 29
            case "UIL":
                return 30
            case "UPT":
                return 31
            case "UDK":
                return 32
            case "UTR":
                return 33
            case "URO":
                return 34
            case "UPL":
                return 35
            case "UNL":
                return 36
            case "UPH":
                return 37
            case "UIT":
                return 38
            case "UBR":
                return 39
            default:
                return 0
        }
    }
}
