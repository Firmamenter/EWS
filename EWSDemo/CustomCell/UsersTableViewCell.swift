//
//  UsersTableViewCell.swift
//  EWSDemo
//
//  Created by Da Chen on 12/24/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit

class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var cellImg: UIImageView!
    @IBOutlet weak var cellUserName: UILabel!
    @IBOutlet weak var cellName: UILabel!
    @IBOutlet weak var cellBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
