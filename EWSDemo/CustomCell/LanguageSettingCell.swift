//
//  LanguageSettingCell.swift
//  EWSDemo
//
//  Created by Da Chen on 12/23/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit

class LanguageSettingCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var switcher: UISwitch!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
