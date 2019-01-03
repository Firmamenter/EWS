//
//  TextFieldExtesnsion.swift
//  EWSDemo
//
//  Created by Da Chen on 12/21/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//
import UIKit
import Foundation

extension UITextField {
    func setIcon(_ image: UIImage) {
        let iconView = UIImageView(frame:
            CGRect(x: 10, y: 5, width: 20, height: 20))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
            CGRect(x: 20, y: 0, width: 30, height: 30))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }
}
