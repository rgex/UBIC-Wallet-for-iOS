//
//  SelectCurrencyTextField.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 22.12.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import UIKit

@IBDesignable
class SelectCurrencyTextField: UITextField {
    
    @IBInspectable var flagImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        if let image = flagImage {
            leftViewMode = .always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            imageView.image = flagImage
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            view.addSubview(imageView)
            leftView = view
        } else {
            leftViewMode = .never
        }
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }

}
