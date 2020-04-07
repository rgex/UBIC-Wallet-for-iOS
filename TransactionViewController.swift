//
//  TransactionViewController.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 02.11.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import UIKit

class TransactionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var noTransactionLabel: UILabel!
    
    private let itemsPerRow: CGFloat = 1
    private let sectionInsets = UIEdgeInsets(top: 0.0,
    left: 0.0,
    bottom: 0.0,
    right: 0.0)
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let balance2 = self.balance {
            if let lastTransactions = balance2.lastTransactions {
                if let pendingTransactions = balance2.pendingTransactions {
                    return lastTransactions.count + pendingTransactions.count
                }
                return lastTransactions.count
            }
            
            if let pendingTransactions = balance2.pendingTransactions {
                return pendingTransactions.count
            }
        }
        
        return 0
    }
    
    func populateCell(transaction: Transaction, cell: TransactionCollectionViewCell, isConfirmed: Bool) -> TransactionCollectionViewCell {
        if let dTimestamp = Double(transaction.timestamp) {
            cell.dateLabel.text = Date(timeIntervalSince1970: dTimestamp).timeAgoDisplay()
        } else {
            cell.dateLabel.text = "unknown time ago"
        }
        
        let highlightGreen: [NSAttributedString.Key: Any] = [.backgroundColor: UIColor(hue: 0.3389, saturation: 0.36, brightness: 0.99, alpha: 1.0), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22)]
        let highlightRed: [NSAttributedString.Key: Any] = [.backgroundColor: UIColor(hue: 0, saturation: 0.36, brightness: 0.99, alpha: 1.0), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22)]
        
        var mutableTransactionValues = NSMutableAttributedString(string:"")
        var transactionValues: String = ""
        var transactionSign: String = ""
        
        for amount in transaction.amount.amount {
            if let amountKey = Int(amount.key) {

                if amount.value > 0 {
                    mutableTransactionValues.append(NSMutableAttributedString(string: " " + CurrencyFormatter.formatAmount(amount.value) + " " +
                    CurrencyFormatter.getcurrencyCodeFromId(amountKey) + " ", attributes: highlightGreen))
                } else {
                    mutableTransactionValues.append(NSMutableAttributedString(string: " " + CurrencyFormatter.formatAmount(amount.value) + " " +
                    CurrencyFormatter.getcurrencyCodeFromId(amountKey) + " ", attributes: highlightRed))
                }
                mutableTransactionValues.append(NSMutableAttributedString(string: "    "))
                
            }
        }
        if transaction.type == "registerPassport" {
            cell.amountValue.attributedText = NSMutableAttributedString(string: "Register passport transaction", attributes: highlightGreen)
        } else {
            cell.amountValue.attributedText = mutableTransactionValues
        }
        
        if isConfirmed {
            cell.notValidatedSign.isHidden = true
        } else {
            cell.notValidatedSign.isHidden = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "transaction_collection_cell", for: indexPath) as! TransactionCollectionViewCell
        self.noTransactionLabel.isHidden = false
        
        if let balance2 = self.balance {
            if let lastTransactions = balance2.lastTransactions {

                var i = 0
                if let pendingTransactions = balance2.pendingTransactions {
                    for pendingTransaction in pendingTransactions {
                        if indexPath.row == i {
                            self.noTransactionLabel.isHidden = true
                            cell = populateCell(transaction: pendingTransaction, cell: cell, isConfirmed: false)
                        }
                        i += 1
                    }
                }
                for transaction in lastTransactions {
                    if indexPath.row == i {
                        self.noTransactionLabel.isHidden = true
                        cell = populateCell(transaction: transaction, cell: cell, isConfirmed: true)
                    }
                    i += 1
                }
            } else {
                var i = 0
                if let pendingTransactions = balance2.pendingTransactions {
                    for pendingTransaction in pendingTransactions {
                        if indexPath.row == i {
                            self.noTransactionLabel.isHidden = true
                            cell = populateCell(transaction: pendingTransaction, cell: cell, isConfirmed: false)
                        }
                        i += 1
                    }
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

      return CGSize(width: collectionView.frame.width, height: 100)
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

    @IBOutlet weak var transactionActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var transactionCollectionView: UICollectionView!
    
    
    private var balance: Balance?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.transactionCollectionView.delegate = self
        self.transactionCollectionView.dataSource = self
        self.transactionCollectionView.isPagingEnabled = false
        
        let getBalance = GetBalance(completionHandler: self.completeBalance)
        let keyStore = KeyStore()
        getBalance.getBalance(address: keyStore.getCurrentAddress())
    }
    
    func completeBalance(success: Bool, balance: Balance) {
        print("completeBalance: \(success)")
        self.balance = balance

        DispatchQueue.main.async {
            if !success {
                self.noTransactionLabel.isHidden = false
            }
            
            self.transactionActivityIndicator.isHidden = true
            self.noTransactionLabel.isHidden = false
            self.transactionCollectionView.reloadData()
        }
    }
}
