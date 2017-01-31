//
//  Constant.swift
//  GooglePlacesAPI-DEMO
//
//  Created by Nasrullah Khan on 31/01/2017.
//  Copyright © 2017 Nasrullah Khan. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, details: String) {
        
        let alertController = UIAlertController(title: title, message:
            details, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}
