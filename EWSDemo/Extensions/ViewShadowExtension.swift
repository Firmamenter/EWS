//
//  ViewShadowExtension.swift
//  EWSDemo
//
//  Created by Da Chen on 12/28/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit
import Foundation

extension UIView {
    func makeShadow() {
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 3)
        self.layer.shadowRadius = 1
    }
}
