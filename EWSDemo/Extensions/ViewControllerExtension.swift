//
//  ViewControllerExtension.swift
//  EWSDemo
//
//  Created by Da Chen on 12/28/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//
import UIKit
import Foundation

extension UIViewController {
    func showAlert(title : String, msg : String) {
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .destructive) { (okAction) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
}
