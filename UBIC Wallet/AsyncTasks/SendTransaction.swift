//
//  SendTransaction.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 17.10.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import Foundation

struct TransactionResponse: Codable {
    var success: Bool
    var error: String?
}

class SendTransaction {
    
    var completionHandler: (Bool, String) -> Void
    var customUrl:String = ""

    init(completionHandler: @escaping (Bool, String) -> Void) {
        self.completionHandler = completionHandler
    }
    
    func setCustomUrl(url: String) {
        self.customUrl =  url
    }
    
    func sendTransaction(transaction: String) {
        var url:URL?
        if self.customUrl.count > 0 {
            url = URL(string: self.customUrl)
        } else {
            url = URL(string: ServerSelector.getBaseUrl() + "/api/send")
        }
        if let requestUrl = url {
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "POST"
            request.httpBody = ("{\"base64\":\"" + transaction + "\"}").data(using: .utf8)

            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)

            let task = session.dataTask(with: request, completionHandler: sessionResponseHandler)

            task.resume()
        }
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
                let transactionResponse = try decoder.decode(TransactionResponse.self, from:
                             data2) //Decode JSON Response Data

                print("transactionResponse :")
                print(transactionResponse)
                
                if let message: String = transactionResponse.error {
                    self.completionHandler(transactionResponse.success, message)
                } else {
                    self.completionHandler(transactionResponse.success, "")
                }
            } catch let parsingError {
                 print("Error", parsingError)
                 self.completionHandler(false, "")
            }
        }
    
    }
}
