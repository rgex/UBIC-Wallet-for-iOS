//
//  HomeViewController.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 30.08.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 0.0,
    left: 0.0,
    bottom: 0.0,
    right: 0.0)
    private var balance: Balance?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var myUBIViewButton: UIView!
    @IBOutlet weak var privatekeysViewButton: UIView!
    @IBOutlet weak var transactionsViewButton: UIView!
    @IBOutlet weak var sendViewButton: UIView!
    @IBOutlet weak var receiveViewButton: UIView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var BalanceCollectionView: UICollectionView!
    
    @IBOutlet weak var balancePageController: UIPageControl!
    
    @IBOutlet weak var emptyWalletMessageView: UIView!
    @IBOutlet weak var emptyWalletTextView: UITextView!
    @IBOutlet weak var registerPassportButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(loadBalance), userInfo: nil, repeats: true)
        
        let keyStore = KeyStore()

        let privateKeyGenerator = PrivateKeyGenerator()
        
        if keyStore.getCurrentKey() == "" { // if keystore is empty generate a private key
            print("keyStore.getCurrentKey() empty, generating new one")
            keyStore.setCurrent(privateKey: privateKeyGenerator.generate())
        }
        
        let getTransactionFees = GetTransactionFees(completionHandler: self.completeFees)
        getTransactionFees.getTransactionFees()
        print("GetTransactionFees fired")
        
        self.containerScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 1900)
        
        self.BalanceCollectionView.delegate = self
        self.BalanceCollectionView.dataSource = self
        self.BalanceCollectionView.isPagingEnabled = true
        self.BalanceCollectionView.showsHorizontalScrollIndicator = false
        
        self.myUBIViewButton.layer.cornerRadius = 10
        self.myUBIViewButton.layer.shadowColor = UIColor.black.cgColor
        self.myUBIViewButton.layer.shadowOpacity = 0.15
        self.myUBIViewButton.layer.shadowOffset = CGSize(width: 2,height: 2)
        self.myUBIViewButton.layer.shadowRadius = 5
        let myUBIGesture = UITapGestureRecognizer(target: self, action: Selector(("openMyUBI:")))
        self.myUBIViewButton.addGestureRecognizer(myUBIGesture)
        
        self.privatekeysViewButton.layer.cornerRadius = 10
        self.privatekeysViewButton.layer.shadowColor = UIColor.black.cgColor
        self.privatekeysViewButton.layer.shadowOpacity = 0.15
        self.privatekeysViewButton.layer.shadowOffset = CGSize(width: 2,height: 2)
        self.privatekeysViewButton.layer.shadowRadius = 5
        let privateKeysGesture = UITapGestureRecognizer(target: self, action: Selector(("openPrivateKeys:")))
        self.privatekeysViewButton.addGestureRecognizer(privateKeysGesture)
        
        self.transactionsViewButton.layer.cornerRadius = 10
        self.transactionsViewButton.layer.shadowColor = UIColor.black.cgColor
        self.transactionsViewButton.layer.shadowOpacity = 0.15
        self.transactionsViewButton.layer.shadowOffset = CGSize(width: 2,height: 2)
        self.transactionsViewButton.layer.shadowRadius = 5
        let transactionsGesture = UITapGestureRecognizer(target: self, action: Selector(("openTransactions:")))
        self.transactionsViewButton.addGestureRecognizer(transactionsGesture)
        
        self.sendViewButton.layer.cornerRadius = 10
        self.sendViewButton.layer.shadowColor = UIColor.black.cgColor
        self.sendViewButton.layer.shadowOpacity = 0.15
        self.sendViewButton.layer.shadowOffset = CGSize(width: 2,height: 2)
        self.sendViewButton.layer.shadowRadius = 5
        let sendGesture = UITapGestureRecognizer(target: self, action: Selector(("openSend:")))
        self.sendViewButton.addGestureRecognizer(sendGesture)
        
        self.receiveViewButton.layer.cornerRadius = 10
        self.receiveViewButton.layer.shadowColor = UIColor.black.cgColor
        self.receiveViewButton.layer.shadowOpacity = 0.15
        self.receiveViewButton.layer.shadowOffset = CGSize(width: 2,height: 2)
        self.receiveViewButton.layer.shadowRadius = 5
        let receiveGesture = UITapGestureRecognizer(target: self, action: Selector(("openReceive:")))
        self.receiveViewButton.addGestureRecognizer(receiveGesture)
    }
    
    @objc func loadBalance() {
        print("going to fired")
        let getBalance = GetBalance(completionHandler: self.completeBalance)
        let keyStore = KeyStore()
        getBalance.getBalance(address: keyStore.getCurrentAddress())
        print("GetBalance for \(keyStore.getCurrentAddress()) fired")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        loadBalance()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = self.BalanceCollectionView.contentOffset.x
        let width = self.BalanceCollectionView.frame.width
        let horizontalCenter = width / 2

        self.balancePageController.currentPage = Int(offSet + horizontalCenter) / Int(width)
    }
    
    func completeBalance(success: Bool, balance: Balance) {
        self.balance = balance
        UserDefaults.standard.set(try? PropertyListEncoder().encode(balance.amount.amount), forKey:"balance_amount")
        
        DispatchQueue.main.async {
            if let balance = self.balance {
                if balance.amount.amount.count > 3 {
                    self.balancePageController.isHidden = false
                } else {
                    self.balancePageController.isHidden = true
                }
                
                if balance.amount.amount.count == 0 {
                    self.emptyWalletMessageView.isHidden = false
                } else {
                    self.emptyWalletMessageView.isHidden = true
                }
            } else {
                self.emptyWalletMessageView.isHidden = false
            }
            
            //special case register passport transaction is pending
            if let pendingTransactions = balance.pendingTransactions {
                for pendingTransaction in pendingTransactions {
                    if pendingTransaction.type == "registerPassport" {
                        self.emptyWalletTextView.text = "Registration is in progress, you will start to receive coins soon, be patient"
                        self.registerPassportButton.isHidden = true
                    } else {
                        self.emptyWalletTextView.text = "Your wallet is empty. However you can easily collect UBIC coins by scanning the NFC chip of your passport to join it's UBI program"
                        self.registerPassportButton.isHidden = false
                    }
                }
            }
            
            if balance.dsc?.isEmpty == false { // special case: wallet empty but passport is registered
                self.emptyWalletTextView.text = "Registration is in progress, you will start to receive coins soon, be patient"
                self.registerPassportButton.isHidden = true
            } else {
                self.emptyWalletTextView.text = "Your wallet is empty. However you can easily collect UBIC coins by scanning the NFC chip of your passport to join it's UBI program"
                self.registerPassportButton.isHidden = false
            }
            
            self.activityIndicator.isHidden = true
            self.BalanceCollectionView.reloadData()
        }
    }
    
    func completeFees(success: Bool, fees: Fees) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let balance2 = self.balance {
            let pageCount = (Double(balance2.amount.amount.count) / 3.0).rounded(.up)
            self.balancePageController.numberOfPages = Int(pageCount)
            return balance2.amount.amount.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "balance_collection_cell", for: indexPath) as! BalanceCollectionViewCell
        
        if let balance2 = self.balance {
            var i = 0
            for amount in (balance2.amount.amount.sorted{ $0.key < $1.key }) {
                if indexPath.row == i {
                    if let intAmount = Int64(amount.value) {
                        cell.balanceAmount.text = CurrencyFormatter.formatAmount(intAmount)
                    } else {
                        cell.balanceAmount.text = "???"
                    }
                    cell.currencyCode.text = CurrencyFormatter.getcurrencyCodeFromId(amount.key)
                    if let currencyImage = UIImage(named:CurrencyFormatter.getcurrencyCodeFromId(amount.key).lowercased()) {
                        cell.currencyImage.image = currencyImage
                    }
                }
                i += 1
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
      //2
      let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
      let availableWidth = view.frame.width - paddingSpace
      let widthPerItem = availableWidth / itemsPerRow
      
      return CGSize(width: widthPerItem, height: widthPerItem)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "passportInformationFromHomeSegue" {
            if let passportInformationInputViewController = segue.destination as? PassportInformationInputViewController {
                passportInformationInputViewController.setReadingType(readingType: .registerPassport)
            }
        }
    }
    
    @objc func openMyUBI(_ sender:UITapGestureRecognizer){
       print("touched my UBI")
        self.performSegue(withIdentifier: "myUbiSegue", sender: self)
    }
    
    @objc func openPrivateKeys(_ sender:UITapGestureRecognizer){
        print("touched my PrivateKeys")
        self.performSegue(withIdentifier: "seguePrivateKeys", sender: self)
    }
    
    @objc func openKYC(_ sender:UITapGestureRecognizer){
        print("touched KYC")
        self.performSegue(withIdentifier: "segueKycQrCode", sender: self)
    }
    
    @objc func openTransactions(_ sender:UITapGestureRecognizer){
        self.performSegue(withIdentifier: "transactionsSegue", sender: self)
    }
    
    @objc func openSend(_ sender:UITapGestureRecognizer){
        self.performSegue(withIdentifier: "sendSegue", sender: self)
    }
    
    @objc func openReceive(_ sender:UITapGestureRecognizer){
        self.performSegue(withIdentifier: "receiveSegue", sender: self)
    }
    
    func completeReadKYCQrCode(qrCode: String) {
        //@TODO open PassportInformationController
    }
    
}
