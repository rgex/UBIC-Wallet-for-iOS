//
//  MyUBIViewController.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 01.11.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import UIKit
import Foundation

class MyUBIViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var ubiStatusLabel: UILabel!
    @IBOutlet weak var passportsLabel: UILabel!
    @IBOutlet weak var registeredPassportsCollectionView: UICollectionView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let itemsPerRow: CGFloat = 1
    private let sectionInsets = UIEdgeInsets(
        top: 0.0,
        left: 0.0,
        bottom: 0.0,
        right: 0.0
    )
    
    private var balance: Balance?
    private var dscCounts = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passportInformationFromMyUBISegue" {
            if let passportInformationInputViewController = segue.destination as? PassportInformationInputViewController {
                passportInformationInputViewController.setReadingType(readingType: .registerPassport)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.activityIndicator.isHidden = false
        self.loadingView.isHidden = false
        loadBalance()
    }
    
    @objc func loadBalance() {
        print("going to fired")
        let getBalance = GetBalance(completionHandler: self.completeBalance)
        let keyStore = KeyStore()
        getBalance.getBalance(address: keyStore.getCurrentAddress())
        print("GetBalance fired")
    }
    
    func isReceivingUBI(balance: Balance) -> Bool {
        if let DSCs = self.balance?.dsc {
            self.dscCounts = DSCs.count
            if DSCs.count > 0 {
                for dsc in DSCs {
                    if dsc.active == "true" {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func completeBalance(success: Bool, balance: Balance) {
        self.balance = balance
        print("Completed balance")
        
        DispatchQueue.main.async {
            if(!success) { // if the block explorer is down
                self.ubiStatusLabel.text = "Server error, please try again later :-/"
                self.passportsLabel.isHidden = true
                self.registeredPassportsCollectionView.dataSource = self
                self.registeredPassportsCollectionView.reloadData()
                UIView.setAnimationsEnabled(false)
                UIView.setAnimationsEnabled(true)
            } else {
                if self.isReceivingUBI(balance: balance) {
                    self.passportsLabel.isHidden = false
                    self.registeredPassportsCollectionView.dataSource = self
                    self.registeredPassportsCollectionView.reloadData()
                    self.ubiStatusLabel.text = "Currently you are receiving a UBI"
                    UIView.setAnimationsEnabled(false)
                    UIView.setAnimationsEnabled(true)
                } else {
                    self.passportsLabel.isHidden = true
                    self.ubiStatusLabel.text = "Currently you are not receiving a UBI"
                    UIView.setAnimationsEnabled(false)
                    UIView.setAnimationsEnabled(true)
                }
            }
            self.activityIndicator.isHidden = true
            self.loadingView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

      return CGSize(width: collectionView.frame.width, height: 151)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
      return sectionInsets
    }
    
    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dscCounts
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "registered_passport_cell", for: indexPath) as! RegisteredPassportCollectionViewCell
       

        cell.countryNameLabel.text = "???"
        cell.expirationDateLabel.text = "???"
    
        if let DSCs = self.balance?.dsc {
            let date = Date(timeIntervalSince1970: Double(DSCs[indexPath.row].expirationDate) ?? 0 )
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateStyle = .long
            let strDate = dateFormatter.string(from: date)
            cell.expirationDateLabel.text = "~ " + strDate
            
            let issuer = DSCs[indexPath.row].issuer
            
            let regex = try? NSRegularExpression(pattern: "C=([a-zA-Z]{2})")
            if let result = regex?.firstMatch(in: issuer, options: [], range: NSRange(location: 0, length: issuer.utf16.count)) {
                
                if let countryRange = Range(result.range(at: 1), in: issuer) {
                    cell.countryNameLabel.text = String(issuer[countryRange])
                }
                
            }
        }
    
       return cell
   }
}
