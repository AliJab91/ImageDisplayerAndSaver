//
//  Extensions.swift
//  ImageSaver
//
//  Created by Ali Jaber on 5/20/19.
//  Copyright © 2019 Ali Jaber. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
extension Dictionary where Key:
ExpressibleByStringLiteral {
    subscript(jsonKey:APIKeys) ->Value? {
        get {
            return self[jsonKey.rawValue as! Key]
        }
        set {
            self[jsonKey.rawValue as! Key] = newValue
        }
    }
}

extension UIViewController {
    func showLoader()  {
        SVProgressHUD.show()
    }
    
    func hideLoader()  {
        SVProgressHUD.dismiss()
    }
    
    func showAlert(title:String, body:String)  {
        let alertVC = UIAlertController(title: title, message: body, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
}
