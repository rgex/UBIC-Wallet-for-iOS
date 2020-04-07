//
//  ImportPrivateKeyController.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 30.10.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import UIKit

class ImportPrivateKeyViewController: UIViewController {

    @IBOutlet weak var privateKeyTextField: UITextField!
    
    @IBAction func clickedImportPrivateKey(_ sender: Any) {
        let characterset = NSCharacterSet(charactersIn: "abcdefABCDEF0123456789")
        
        if let newPrivateKey = privateKeyTextField.text {
            if newPrivateKey.count != 40 || newPrivateKey.rangeOfCharacter(from: characterset.inverted) != nil {
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Private key is invalid", comment:""), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                self.present(alert, animated: true, completion: nil)
                
                return
            }
            
            
            let keyStore = KeyStore()
            if keyStore.addOtherKey(privateKey: newPrivateKey) {
                let alert = UIAlertController(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("Private key was imported", comment:""), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
                    self.navigationController?.popViewController(animated: true)
                }))

                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}

