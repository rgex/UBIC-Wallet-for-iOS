//
//  GetBalance.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 30.08.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import Foundation

struct Fee: Codable {
    var name: String
    var fee: String
}

struct Fees: Codable {
    var fees: [Int: Fee]
    
    init () {
        fees = [:]
    }
}

class GetTransactionFees {
    
    //let baseUrl = "http://192.168.178.35:8888/ubic.network"
    let baseUrl = "https://ubic.network"
    
    var completionHandler: (Bool, Fees) -> Void

    init(completionHandler: @escaping (Bool, Fees) -> Void) {
        self.completionHandler = completionHandler
    }
    
    func getTransactionFees() {
        let url = URL(string: baseUrl + "/api/fees")!
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
                let fees = try decoder.decode(Fees.self, from:
                             data2) //Decode JSON Response Data

                print("fees :")
                print(fees)
                
                self.completionHandler(true, fees)
                
            } catch let parsingError {
                 print("Error", parsingError)
                 self.completionHandler(false, Fees())
            }
        }
    
    }
}
