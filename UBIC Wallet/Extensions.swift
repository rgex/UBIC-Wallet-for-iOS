//
//  Extensions.swift
//  UBIC Wallet
//
//  Created by Jan Moritz on 13.10.19.
//  Copyright © 2019 Bondi. All rights reserved.
//

import Foundation
import UIKit

extension String {
  func hexToData() -> Data? {
      let hexStr = self.dropFirst(self.hasPrefix("0x") ? 2 : 0)

      guard hexStr.count % 2 == 0 else { return nil }

      var newData = Data(capacity: hexStr.count/2)

      var indexIsEven = true
      for i in hexStr.indices {
          if indexIsEven {
              let byteRange = i...hexStr.index(after: i)
              guard let byte = UInt8(hexStr[byteRange], radix: 16) else { return nil }
              newData.append(byte)
          }
          indexIsEven.toggle()
      }
      return newData
  }
}

extension Data {

    /// Hexadecimal string representation of `Data` object.

    func toHexString() -> String {
        return map { String(format: "%02x", $0) }
            .joined()
    }
}

extension Date {
    func timeAgoDisplay() -> String {

        let calendar = Calendar.current
        let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date())!
        let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date())!
        let dayAgo = calendar.date(byAdding: .day, value: -1, to: Date())!
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!

        if minuteAgo < self {
            let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
            return "\(diff) sec ago"
        } else if hourAgo < self {
            let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
            return "\(diff) min ago"
        } else if dayAgo < self {
            let diff = Calendar.current.dateComponents([.hour], from: self, to: Date()).hour ?? 0
            return "\(diff) hrs ago"
        } else if weekAgo < self {
            let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
            return "\(diff) days ago"
        }
        let diff = Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear ?? 0
        return "\(diff) weeks ago"
    }
}

extension UIViewController {

    func showToast(message : String) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 125, y: self.view.frame.size.height-250, width: 250, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
