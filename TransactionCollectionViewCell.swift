//
//  TransactionCollectionViewCell.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 02.11.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import UIKit

class TransactionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountValue: UITextView!
    @IBOutlet weak var notValidatedSign: UIImageView!
    
}
