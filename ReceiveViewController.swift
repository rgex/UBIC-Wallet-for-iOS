//
//  ReceiveViewController.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 28.10.19.
//  Copyright © 2019 Bondi. All rights reserved.
//


import UIKit

class ReceiveViewController: UIViewController {
    
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var receiveAddressLabel: UILabel!
    
    var receiveAddress: String = "Loading..."
    
    @IBAction func clickedCopyToClipboard(_ sender: Any) {
        UIPasteboard.general.string = receiveAddress
        self.showToast(message: "Address copied to clipboard!")
    }

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyStore = KeyStore()
        let currentSeed = keyStore.getCurrentKey()
        print("currentSeed.hexToData() \(currentSeed.hexToData())")
        if let seedData = currentSeed.hexToData() {
            self.receiveAddress = SwiftWrapper.getAddress(seed: seedData)
        }
        
        print(self.receiveAddress)
        qrCodeImageView.image = self.generateQRCode(from: self.receiveAddress)
        self.receiveAddressLabel.text =  self.receiveAddress
    }
}
