//
//  LanguageSettingViewController.swift
//  EWSDemo
//
//  Created by Da Chen on 12/23/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit

class LanguageSettingViewController: UIViewController {
    let data = ["en", "zh-Hans", "ja"]
    let defaults = UserDefaults.standard

    @IBOutlet weak var tbView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        uiSetup()
    }
    
    func uiSetup() {
        title = NSLocalizedString("Language Setting", comment: "")
        tbView.delegate = self
        tbView.dataSource = self
        tbView.allowsSelection = false
        // Remove last cell's seperator
        tbView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tbView.frame.size.width, height: 1))
    }
    
    @objc func switchChanged(sender: UISwitch) {
        if sender.isOn == false {
            showAlert(title: NSLocalizedString("Oops", comment: ""), msg: NSLocalizedString("You need choose one language at least.", comment: ""))
            sender.isOn = true
        } else {
            defaults.set(sender.tag, forKey: "language")
            for i in 0...2 {
                if sender.tag != i {
                    let cell = tbView.cellForRow(at: IndexPath(row: i, section: 0)) as! LanguageSettingCell
                    if cell.switcher.isOn {
                        cell.switcher.setOn(false, animated: true)
                    }
                }
            }
            UserDefaults.standard.set([data[sender.tag]], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
            showAlert(title: NSLocalizedString("Success", comment: ""), msg: NSLocalizedString("Restart app to see changes.", comment: ""))
        }
    }
}

extension LanguageSettingViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
}

extension LanguageSettingViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguageSettingCell", for: indexPath) as! LanguageSettingCell
        switch indexPath.row {
        case 0:
            cell.label.text = NSLocalizedString("English", comment: "")
            cell.switcher.tag = 0
            cell.switcher.addTarget(self, action: #selector(switchChanged(sender:)), for: UIControl.Event.valueChanged)
            cell.img.image = UIImage(named: "English")
        case 1:
            cell.label.text = NSLocalizedString("Chinese", comment: "")
            cell.switcher.tag = 1
            cell.switcher.addTarget(self, action: #selector(switchChanged(sender:)), for: UIControl.Event.valueChanged)
            cell.img.image = UIImage(named: "Chinese")
        default:
            cell.label.text = NSLocalizedString("Japanese", comment: "")
            cell.switcher.tag = 2
            cell.switcher.addTarget(self, action: #selector(switchChanged(sender:)), for: UIControl.Event.valueChanged)
            cell.img.image = UIImage(named: "Japanese")
        }
        if defaults.integer(forKey: "language") == indexPath.row {
            cell.switcher.isOn = true
        } else {
            cell.switcher.isOn = false
        }
        return cell
    }
}
