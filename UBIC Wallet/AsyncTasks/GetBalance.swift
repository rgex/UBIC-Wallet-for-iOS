//
//  GetBalance.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 30.08.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import Foundation

struct Amount: Codable {
    var amount: [Int: String]
    var isEmpty: Bool
    
    init(from decoder: Decoder) throws {
        let container =  try decoder.singleValueContainer()
        do {
            amount = try container.decode(Dictionary.self)
            isEmpty = false
        } catch {
            amount = [:]
            isEmpty = true
        }
    }
    
    init() {
        amount = [:]
        isEmpty = true
    }
}

struct AmountTransaction: Codable {
    let amount: [String: Int64]
    let isEmpty: Bool
    
    init(from decoder: Decoder) throws {
        let container =  try decoder.singleValueContainer()
        do {
            amount = try container.decode(Dictionary.self)
            isEmpty = false
        } catch {
            amount = [:]
            isEmpty = true
        }
    }
    
    init() {
        amount = [:]
        isEmpty = true
    }
}

struct DSC: Codable {
    var active: String
    var expirationDate: String
    var issuer: String
}

struct Transaction: Codable {
    var amount: AmountTransaction
    var timestamp: String
    var transactionId: String?
    var type: String
}

struct Balance: Codable {
    var amount: Amount
    var isReceivingUbi: Bool
    var lastTransactions: [Transaction]?
    var pendingTransactions: [Transaction]?
    var dsc: [DSC]?
    var nonce: String
    
    init() {
        amount = Amount()
        isReceivingUbi = false
        lastTransactions = []
        dsc = []
        nonce = ""
    }
}

class GetBalance {
    
    var completionHandler: (Bool, Balance) -> Void

    init(completionHandler: @escaping (Bool, Balance) -> Void) {
        self.completionHandler = completionHandler
    }
    
    func getBalance(address: String) {
        print("getBalance: \(address)")
        //let url = URL(string: baseUrl + "/api/addresses/qVzfuP4vT7cPbYW9rR4EWGMY6GYBVKKKJ")!
        let url = URL(string:  ServerSelector.getBaseUrl() + "/api/addresses/" + address)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)

        let task = session.dataTask(with: request, completionHandler: sessionResponseHandler)

        task.resume()
    }
    
    func sessionResponseHandler(data: Data?, response: URLResponse?, error: Error?) {
        print("sessionResponseHandler")
        if let data2 = data {
            do{
                let jsonResponse = try JSONSerialization.jsonObject(with:
                                       data2, options: [])
                print(jsonResponse)
                
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let balance = try decoder.decode(Balance.self, from:
                             data2) //Decode JSON Response Data

                print("balance:")
                print(balance)
                
                self.completionHandler(true, balance)
                
            } catch let parsingError {
                 print("Error", parsingError)
                 self.completionHandler(false, Balance())
            }
        }
    
    }
}
