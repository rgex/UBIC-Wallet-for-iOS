//
//  PrivateKeyCollectionViewCell.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 01.11.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import UIKit

class PrivateKeyCollectionViewCell: UICollectionViewCell {
    
    var privateKey: String = ""
    weak var parentViewController:PrivateKeysViewController?
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var privateKeyRow1Label: UILabel!
    @IBOutlet weak var privateKeyRow2Label: UILabel!
    @IBOutlet weak var privateKeyIdenticon: UIImageView!
    
    @IBAction func clickedExportToClipboard(_ sender: Any) {
        UIPasteboard.general.string = privateKey
        if let parentViewController = self.parentViewController {
            parentViewController.showToast(message: "Private key copied to clipboard!")
        }
    }
    @IBAction func clickedUseAsPrimaryKey(_ sender: Any) {
        let keyStore = KeyStore()
        keyStore.setCurrent(privateKey: privateKey)
        if let parentViewController = self.parentViewController {
            parentViewController.loadPrivateKeys()
            parentViewController.refreshLayout()
        }
    }
    
}
