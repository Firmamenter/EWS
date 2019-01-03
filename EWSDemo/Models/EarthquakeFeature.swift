//
//  EarthquakeFeature.swift
//  EWSDemo
//
//  Created by Da Chen on 12/27/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import Foundation

struct EarthquakeFeature {
    var title : String
    var mag : Int
    var lat : Double
    var log : Double
    
    init (title : String, mag : Int, lat : Double, log : Double) {
        self.title = title
        self.mag = mag
        self.lat = lat
        self.log = log
    }
}
