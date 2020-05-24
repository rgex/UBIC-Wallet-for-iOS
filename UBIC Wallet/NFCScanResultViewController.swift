//
//  NFCScanResultViewController.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 30.12.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import UIKit

class NFCScanResultViewController: UIViewController {

    @IBOutlet weak var resultIconImageView: UIImageView!
    @IBOutlet weak var resultTextView: UILabel!
    
    private var success:Bool = false
    private var message:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       
        if success {
            self.resultTextView.textColor = UIColor.green
            self.resultIconImageView.tintColor = UIColor.green
            self.resultIconImageView.image = UIImage(systemName:"checkmark.circle")
        } else {
            self.resultTextView.textColor =  UIColor.red
            self.resultIconImageView.tintColor =  UIColor.red
            self.resultIconImageView.image = UIImage(systemName:"multiply.circle")
        }
        
        self.resultTextView.text = message
    }
    
    func setSuccess(success: Bool) {
        self.success = success
    }
    
    func setMessage(message: String) {
        self.message = message
    }

}
