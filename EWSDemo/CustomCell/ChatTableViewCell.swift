//
//  ChatTableViewCell.swift
//  EWSDemo
//
//  Created by Da Chen on 12/27/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var otherMsg: UILabel!
    @IBOutlet weak var otherMsgView: UIView!
    @IBOutlet weak var myMsg: UILabel!
    @IBOutlet weak var myMsgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
