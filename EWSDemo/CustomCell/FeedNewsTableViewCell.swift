//
//  FeedNewsTableViewCell.swift
//  EWSDemo
//
//  Created by Da Chen on 12/26/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit

class FeedNewsTableViewCell: UITableViewCell {

    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
