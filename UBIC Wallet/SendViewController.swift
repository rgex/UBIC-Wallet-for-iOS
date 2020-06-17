//
//  SecondViewController.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 28.08.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import UIKit

class SendViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var recipientAddressTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var selectCurrencyTextField: SelectCurrencyTextField!
    @IBOutlet weak var errorEmptyWalletView: UIView!
    
    var pickerData:[String] = []
    
    var currencyPickerView = UIPickerView()
    
    var fees: Fees = Fees()
    var loadedFees = false
    private var nonce: Int = 0
    private var balanceAmount: [Int: String] = [:]
    private var currencyPickerCurrentCurrency = ""
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadBalance()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
            view.addGestureRecognizer(tap)
        
        
        let currencyPickerView = UIView(frame: CGRect(x: 0, y: view.frame.height - 260, width: view.frame.width, height: 260))

        // Toolbar
        let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.selectCurrencyDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.selectCurrencyCancel))

        let barAccessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: currencyPickerView.frame.width, height: 44))
        barAccessory.barStyle = .default
        barAccessory.isTranslucent = false
        barAccessory.items = [cancelButton, spaceButton, btnDone]
        
        if self.traitCollection.userInterfaceStyle == .dark {
            barAccessory.barTintColor = UIColor(named: "backgroundButton")
        }
        
        currencyPickerView.addSubview(barAccessory)

        // Month UIPIckerView
        let subCurrencyPicker = UIPickerView(frame: CGRect(x: 0, y: barAccessory.frame.height, width: view.frame.width, height: currencyPickerView.frame.height-barAccessory.frame.height))
        subCurrencyPicker.delegate = self
        subCurrencyPicker.dataSource = self
        

        subCurrencyPicker.backgroundColor = UIColor(named: "backgroundColor")

        
        currencyPickerView.addSubview(subCurrencyPicker)
        
        selectCurrencyTextField.inputView = currencyPickerView
        
        let getTransactionFees = GetTransactionFees(completionHandler: self.completeFees)
        getTransactionFees.getTransactionFees()
        print("GetTransactionFees fired")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reloadBalanceAmounts()
    }
    
    func reloadBalanceAmounts() {
        if let amountData = UserDefaults.standard.value(forKey:"balance_amount") as? Data {
            if amountData.count > 0 {
                self.errorEmptyWalletView.isHidden = true
            } else {
                self.errorEmptyWalletView.isHidden = false
            }
            
            self.balanceAmount = try! PropertyListDecoder().decode([Int: String].self, from: amountData)
            self.pickerData.removeAll()
            for (amountKey, _) in (self.balanceAmount.sorted{ $0.key < $1.key }) {
                print("amount:" + String(amountKey))
                
                self.pickerData.append(CurrencyFormatter.getcurrencyCodeFromId(amountKey))
                
                if amountData.count == 1 {
                    let currencyCode = CurrencyFormatter.getcurrencyCodeFromId(Int(amountKey))
                    self.currencyPickerCurrentCurrency = currencyCode
                    self.selectCurrencyTextField.text = currencyCode
                    self.selectCurrencyTextField.flagImage = UIImage(named: currencyCode.lowercased())
                }
            }
        }
    }
    
    func completeFees(success: Bool, fees: Fees) {
        self.fees = fees
        self.loadedFees = true
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    @IBAction func clickedSend(_ sender: Any) {
        //verify we have enough balance
        if loadedFees {
            let readableAddress = self.recipientAddressTextField.text
            let currency = CurrencyFormatter.getcurrencyIdFromCode(currencyPickerCurrentCurrency)
            let amountString = self.amountTextField.text ?? "0"
            var amount:Double = Double(amountString) ?? 0
            var fee:UInt64 = 0
            
            if let readableAddress = self.recipientAddressTextField.text {
                if readableAddress.count < 10 {
                    // Error: invalid address
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Invalid recipient address", comment:""), preferredStyle: UIAlertController.Style.alert)
                    self.present(alert, animated: true, completion: nil)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    return
                }
            } else {
                // Error: invalid address
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Invalid recipient address", comment:""), preferredStyle: UIAlertController.Style.alert)
                self.present(alert, animated: true, completion: nil)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                return
            }
            
            if currency == 0 {
                // Error: no currency selected
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Please select a currency", comment:""), preferredStyle: UIAlertController.Style.alert)
                self.present(alert, animated: true, completion: nil)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                return
            }
            
            if amount == 0 {
                // Error: invalid amount
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Invalid amount", comment:""), preferredStyle: UIAlertController.Style.alert)
                self.present(alert, animated: true, completion: nil)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                return
            }
            
            let amount64:UInt64 = UInt64(amount * 1000000)
            
            let keyStore = KeyStore()
        
            let transaction = OCWrapper.getTransaction(keyStore.getCurrentKey().hexToData(), readableAddress: readableAddress, currency: Int32(currency), amount: amount64, fee: UInt64(fee), nonce: Int32(self.nonce))
            
            if transaction != nil {
                // transaction is base64 encoded so it's length is greater than the length of the actual transaction
                // this will serve as a buffer
                for (feesKey, feesValue) in self.fees.fees {
                    if feesKey == currency {
                        fee = UInt64(feesValue.fee) ?? 0
                    }
                }
                

                let transaction2 = OCWrapper.getTransaction(keyStore.getCurrentKey().hexToData(), readableAddress: readableAddress, currency: Int32(currency), amount: amount64, fee: fee, nonce: Int32(self.nonce)) ?? ""
                
                print("transaction2: " + transaction2)
                
                let sendTransaction = SendTransaction(completionHandler: self.completeSendTransaction)
                sendTransaction.sendTransaction(transaction: transaction2)
                
            } else {
                // show error message
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Can not create the transaction", comment:""), preferredStyle: UIAlertController.Style.alert)
                self.present(alert, animated: true, completion: nil)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scanQrCodeSegue" {
            if let qrScannerController = segue.destination as? QRScannerController {
                qrScannerController.setCompletionHandler(completionHandler: self.completeReadQrCode)
            }
        }
    }
    
    @IBAction func cickedScanQrCode(_ sender: Any) {
        self.performSegue(withIdentifier: "scanQrCodeSegue", sender: self)
    }
    
    @objc func selectCurrencyDone() {
        
        if self.currencyPickerCurrentCurrency == "" {
            self.selectCurrencyTextField.text = self.pickerData[0]
            self.selectCurrencyTextField.flagImage = UIImage(named: self.pickerData[0].lowercased())
            self.currencyPickerCurrentCurrency = self.pickerData[0]
        } else {
            self.selectCurrencyTextField.text = self.currencyPickerCurrentCurrency
            self.selectCurrencyTextField.flagImage = UIImage(named: self.currencyPickerCurrentCurrency.lowercased())
        }
        self.view.endEditing(true)
        self.currencyPickerView.resignFirstResponder()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.currencyPickerCurrentCurrency = self.pickerData[row]
    }
    
    @objc func selectCurrencyCancel() {
        self.view.endEditing(true)
        self.currencyPickerView.resignFirstResponder()
    }
    
    @objc func loadBalance() {
        print("going to fired")
        let getBalance = GetBalance(completionHandler: self.completeBalance)
        let keyStore = KeyStore()
        getBalance.getBalance(address: keyStore.getCurrentAddress())
        print("GetBalance fired")
    }
    
    func completeSendTransaction(success: Bool, message: String) {
        DispatchQueue.main.async {
            if success {
                let alert = UIAlertController(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("Transaction was sent", comment:""), preferredStyle: UIAlertController.Style.alert)
                               self.present(alert, animated: true, completion: nil)
                               alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            } else {
                if !message.isEmpty {
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                message: NSLocalizedString(message, comment:""), preferredStyle: UIAlertController.Style.alert)
                                self.present(alert, animated: true, completion: nil)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                               message: NSLocalizedString("Could not validate the transaction. Do you have enough founds? Is another transaction pending?", comment:""), preferredStyle: UIAlertController.Style.alert)
                               self.present(alert, animated: true, completion: nil)
                               alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                }
            }
        }
    }
    
    func completeBalance(success: Bool, balance: Balance) {

        UserDefaults.standard.set(try? PropertyListEncoder().encode(balance.amount.amount), forKey:"balance_amount")
        
        self.nonce = Int(balance.nonce) ?? 0
        
        DispatchQueue.main.async {
            self.reloadBalanceAmounts()
        }
    }
    
    func completeReadQrCode(qrCode: String) {
        let endIndex = qrCode.index(qrCode.startIndex, offsetBy: 1)
        
        if Tools.substr(string: qrCode, from: 0, size: 1) == "1" {
            
            self.recipientAddressTextField.text = Tools.substr(string: qrCode, from: 1, size: qrCode.count - 1)
        } else {
            self.recipientAddressTextField.text = qrCode
        }
    }
    
    
}

