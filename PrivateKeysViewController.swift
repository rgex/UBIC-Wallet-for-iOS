//
//  SecondViewController.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 28.08.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import UIKit

class PrivateKeysViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var privateKeys: [String] = []
    private var currentPrivateKey: String = ""
    private var lock: NSLock = NSLock()
    
    private var loadedPrivateKeys = false
    private let itemsPerRow: CGFloat = 1
    private let sectionInsets = UIEdgeInsets(top: 0.0,
    left: 0.0,
    bottom: 0.0,
    right: 0.0)
    
    @IBOutlet weak var currentPrivateKeyIdentIcon: UIImageView!
    @IBOutlet weak var containerScrollView: UIScrollView!
    @IBOutlet weak var otherPrivateKeysLabel: UILabel!
    @IBOutlet weak var currentAddressLabel: UILabel!
    @IBOutlet weak var currentPrivateKeyRow1Label: UILabel!
    @IBOutlet weak var currentPrivateKeyRow2Label: UILabel!
    @IBOutlet weak var otherPrivateKeysCollectionView: UICollectionView!
    @IBOutlet weak var addAnotherPrivateKeyBtn: UIButton!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return privateKeys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "privatekey_collection_cell", for: indexPath) as! PrivateKeyCollectionViewCell
        
        let currentSeed = self.privateKeys[indexPath.row]
        
        print("Seed:" + currentSeed)
        print("Seeddata: \(currentSeed.hexToData())")
        if let seedData = currentSeed.hexToData() {

            lock.lock()
            let address = SwiftWrapper.getAddress(seed: seedData)
            lock.unlock()
            
            cell.privateKey = currentSeed
            cell.parentViewController = self
            
            cell.privateKeyIdenticon.image = Identicon().icon(from: address, size: CGSize(width: 100, height: 100))
            print("address:" + address)
            cell.addressLabel.text = address
            let   end1 = currentSeed.index(currentSeed.startIndex, offsetBy:20)
            cell.privateKeyRow1Label.text = "\(currentSeed[..<end1])".uppercased()
            cell.privateKeyRow2Label.text = "\(currentSeed[end1...])".uppercased()
        }
        
        return cell
    }
    
    func loadPrivateKeys() {
        let keyStore = KeyStore()
        self.privateKeys.removeAll()
        
        // Load current private key
        let currentSeed = keyStore.getCurrentKey()
        self.currentPrivateKey = currentSeed
        if let seedData = currentSeed.hexToData() {
            lock.lock()
            let address = SwiftWrapper.getAddress(seed: seedData)
            lock.unlock()
            currentPrivateKeyIdentIcon.image = Identicon().icon(from: address, size: CGSize(width: 100, height: 100))
                               
            currentAddressLabel.text = address
            let   end1 = currentSeed.index(currentSeed.startIndex, offsetBy:20)
            currentPrivateKeyRow1Label.text = "\(currentSeed[..<end1])".uppercased()
            currentPrivateKeyRow2Label.text = "\(currentSeed[end1...])".uppercased()
        }
        
        // Load additional private keys
        if keyStore.getOtherKeys().count == 0 {
            otherPrivateKeysLabel.isHidden = true
            otherPrivateKeysCollectionView.isHidden = true
            addAnotherPrivateKeyBtn.isHidden = false
        } else {
            otherPrivateKeysLabel.isHidden = false
            otherPrivateKeysCollectionView.isHidden = false
            addAnotherPrivateKeyBtn.isHidden = true
            for seed in keyStore.getOtherKeys() {
                self.privateKeys.append(seed)
            }
        }
        
        self.otherPrivateKeysCollectionView.dataSource = self
        self.otherPrivateKeysCollectionView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPrivateKeys()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

    }
    
    func refreshLayout() {
        //self.containerScrollView.contentSize.height = CGFloat(self.privateKeys.count * 175 + 500)
        self.containerScrollView.contentSize.height = CGFloat(0)
        self.otherPrivateKeysCollectionView.frame = CGRect(x:0, y: 0, width:self.otherPrivateKeysCollectionView.frame.width, height:CGFloat(self.privateKeys.count * 175 + 5000))
        
        self.otherPrivateKeysCollectionView.layoutIfNeeded()
    }
    
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        
        if !self.loadedPrivateKeys {
            loadPrivateKeys()
            self.loadedPrivateKeys = true
        }
        
        self.refreshLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

      return CGSize(width: collectionView.frame.width, height: 250)
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
    
    @IBAction func clickedCopyCurrentKeyToClipboard(_ sender: Any) {
        UIPasteboard.general.string = self.currentPrivateKey
        self.showToast(message: "Private key copied to clipboard!")
    }
    
}

