//
//  CustomMarkerView.swift
//  EWSDemo
//
//  Created by Da Chen on 12/25/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit
import Foundation

class CustomMarkerView: UIView {
    var img : UIImage!
    var borderColor : UIColor!
    var imgView : UIImageView!
    
    init(frame : CGRect, image : UIImage, borderColor : UIColor, tag : Int) {
        super.init(frame : frame)
        self.img = image
        self.borderColor = borderColor
        self.tag = tag
        setupViews(ratio: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(ratio : Int) {
        imgView = UIImageView(image: img)
        imgView.contentMode = .scaleAspectFill
        imgView.frame = CGRect(x: 0, y: 0, width: 48 * ratio, height: 48 * ratio)
        imgView.layer.cornerRadius = CGFloat(24 * ratio)
        imgView.layer.borderColor = borderColor?.cgColor
        imgView.layer.borderWidth = CGFloat(3 * ratio)
        imgView.layer.masksToBounds = false
        imgView.clipsToBounds = true
        self.addSubview(imgView)
    }
}
