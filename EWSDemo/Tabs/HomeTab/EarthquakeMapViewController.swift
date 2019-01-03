//
//  EarthquakeMapViewController.swift
//  EWSDemo
//
//  Created by Da Chen on 12/27/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class EarthquakeMapViewController: UIViewController {
    var earthquakeData : [EarthquakeFeature]?
    
    @IBOutlet weak var gmsMap: GMSMapView!
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "Earthquakes"
        gmsMap.mapType = .satellite
        createmarker()
    }
    
    func createmarker() {
        for feature in earthquakeData! {
            let location = CLLocation(latitude: (feature.lat), longitude: (feature.log))
            let marker = GMSMarker()
            marker.position = location.coordinate
            marker.map = gmsMap
            animateMarker(marker: marker)
        }
        let currentPos = CLLocationCoordinate2D(latitude: Double(userInfo.latitude!)!, longitude: Double(userInfo.longitude!)!)
        gmsMap.camera = GMSCameraPosition.camera(withTarget: currentPos, zoom: 1)
    }
    
    func animateMarker(marker : GMSMarker) {
        var frames = [UIImage]()
        for i in 0...44 {
            frames.append(UIImage(named: "Anim 2_\(i)")!)
        }
        marker.icon = UIImage.animatedImage(with: frames, duration: 3.0)
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
