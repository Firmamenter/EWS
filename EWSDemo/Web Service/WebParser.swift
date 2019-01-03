//
//  WebParser.swift
//  EWSDemo
//
//  Created by Da Chen on 12/24/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import Foundation

class WebParser {
    static let shared = WebParser()
    
    private init() {}
    
    func parseWeatherInfo(jsonObj : [String : Any]) -> [WeatherInfo]? {
        var result : [WeatherInfo]? = []
        
        if let daily = jsonObj["daily"] as? [String : Any],
            let data = daily["data"] as? [[String : Any]] {
            for item in data {
                let obj = WeatherInfo(icon : (item["icon"] as! String), time : String(item["time"] as! Double), temperatureHigh : String(item["temperatureHigh"] as! Double), temperatureLow : String(item["temperatureLow"] as! Double))
                result?.append(obj)
            }
        }
        return result
    }
    
    func parseWeatherDetailInfo(jsonObj : [String : Any]) -> WeatherDetailInfo? {
        var result : WeatherDetailInfo?
        
        if let lat = jsonObj["latitude"] as? Double,
            let log = jsonObj["longitude"] as? Double,
            let current = jsonObj["currently"] as? [String : Any] {
            result = WeatherDetailInfo(icon : (current["icon"] as! String), precipProbability : String(current["precipProbability"] as! Double), temperature : String(current["temperature"] as! Double), apparentTemperature : String(current["apparentTemperature"] as! Double), windSpeed : String(current["windSpeed"] as! Double), latitude : String(lat), longitude : String(log), time : String(current["time"] as! Double))
        }
        return result
    }
}
