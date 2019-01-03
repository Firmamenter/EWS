//
//  UsersMapViewController.swift
//  EWSDemo
//
//  Created by Da Chen on 12/25/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit
import GoogleMaps

let RECTNOTEZoomIn: CGRect = CGRect(x: 0, y: 0, width: 80, height: 80)
let RECTNOTEZomOut: CGRect = CGRect(x: 0, y: 0, width: 40, height: 40)

class UsersMapViewController: UIViewController {
    var userInfoArray : [UserInfo]?
    var userImg : [String : UIImage]?
    var selectedMarker : GMSMarker?
    var currentUserMarker : GMSMarker?
    
    @IBOutlet weak var mapView: GMSMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        setupMap()
    }
    
    func setupMap() {
        mapView.mapType = .normal
        for user in userInfoArray! {
            let lat = Double(user.latitude!)!
            let log = Double(user.longitude!)!
            let location = CLLocation(latitude: lat, longitude: log)
            let marker = GMSMarker()
            marker.position = location.coordinate
            let imgView = UIImageView(frame: RECTNOTEZomOut)
            imgView.contentMode = .scaleAspectFill
            imgView.layer.borderWidth = 2
            imgView.layer.borderColor = user.userId != userInfo.userId ? UIColor.white.cgColor : UIColor.red.cgColor
            imgView.layer.cornerRadius = imgView.frame.height/2
            imgView.layer.masksToBounds = false
            imgView.clipsToBounds = true
            imgView.image = userImg![user.userId!] ?? UIImage(named: "UserProfileBackground")!
            marker.iconView = imgView
            marker.map = self.mapView
            if currentUserMarker == nil {
                currentUserMarker = user.userId == userInfo.userId ? marker : nil
            }
            mapView.camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 17)
        }
    }
}

extension UsersMapViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker == currentUserMarker {
            return true
        }
        if let previousmarker = selectedMarker {
            previousmarker.iconView!.frame = RECTNOTEZomOut
            previousmarker.iconView!.layer.cornerRadius = 40/2
            previousmarker.iconView!.layer.masksToBounds = false
            previousmarker.iconView!.clipsToBounds = true
        }
        if let ImageView = marker.iconView as? UIImageView{
            selectedMarker = marker
            ImageView.frame = RECTNOTEZoomIn
            ImageView.layer.cornerRadius = 80/2
            ImageView.layer.masksToBounds = false
            ImageView.clipsToBounds = true
            self.mapView.camera = GMSCameraPosition.camera(withTarget: marker.position, zoom: 17)
        }
        return true
    }
}
