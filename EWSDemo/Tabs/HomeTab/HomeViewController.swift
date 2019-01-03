//
//  HomeViewController.swift
//  EWSDemo
//
//  Created by Da Chen on 12/20/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import GoogleMaps
import GooglePlaces
import CoreLocation

class HomeViewController: UIViewController {
    let webService = WebService.shared
    let webParser = WebParser.shared
    var weatherInfoArray : [WeatherInfo]?
    var weatherDetailInfo : WeatherDetailInfo?
    let autoCompleteController = GMSAutocompleteViewController()
    var lat : String?
    var log : String?
    var earthquakeData = [EarthquakeFeature]()

    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var backToCurrentPlaceBtn: UIButton!
    @IBOutlet weak var searchPlaceBtn: UIButton!
    @IBOutlet weak var earthquakeBtn: UIButton!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var currentTemp: UILabel!
    @IBOutlet weak var currentPlace: UILabel!
    @IBOutlet weak var currentDate: UILabel!
    @IBOutlet weak var currentWeatherIcon: UIImageView!
    @IBOutlet weak var currentPrecipProbImg: UIImageView!
    @IBOutlet weak var currentPrecipProb: UILabel!
    @IBOutlet weak var currentTempImg: UIImageView!
    @IBOutlet weak var currentTempRange: UILabel!
    @IBOutlet weak var currentWindSpeedImg: UIImageView!
    @IBOutlet weak var currentWindSpeed: UILabel!
    @IBOutlet weak var weakWeatherView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoCompleteController.delegate = self
        SVProgressHUD.show()
        NotificationCenter.default.addObserver(self, selector: #selector(fetchWeatherDataFromSignUp), name: NSNotification.Name(rawValue: "UserInfoIsReady"), object: nil)
    }
    
    @objc func fetchWeatherDataFromSignUp() {
        guard let latitude = userInfo.latitude,
            let longitude = userInfo.longitude else {
                SVProgressHUD.dismiss()
                self.showAlert(title: "Failed", msg: "We don't your location.")
                return
        }
        fetchWeatherData(lat: latitude, log: longitude)
    }
    
    func fetchWeatherData(lat : String, log : String) {
        webService.getData(lat: lat, log: log) { (data) in
            if data.count > 0 {
                DispatchQueue.main.async {
                    self.setupUI(data : data)
                }
            } else {
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.showAlert(title: "Oops", msg: "Something went wrong, please try again later.")
                }
            }
        }
    }
    
    func setupUI(data : [String : Any]) {
        guard let weatherDetailInfo = webParser.parseWeatherDetailInfo(jsonObj: data),
            let weatherInfo = webParser.parseWeatherInfo(jsonObj: data) else {
                SVProgressHUD.dismiss()
                showAlert(title: "Oops", msg: "Can't get weather data, please again later.")
                return
        }
        setBackgroundImg(icon: weatherDetailInfo.icon!)
        searchPlaceBtn.setBackgroundImage(UIImage(named: "SearchPlace"), for: .normal)
        backToCurrentPlaceBtn.setBackgroundImage(UIImage(named: "BackToCurrentPlace"), for: .normal)
        earthquakeBtn.setBackgroundImage(UIImage(named: "EarthquakeMap"), for: .normal)
        // Make image circle
        profileImg.makeCircle()
        currentTemp.text = weatherDetailInfo.temperature! + "°C"
        lat = weatherDetailInfo.latitude
        log = weatherDetailInfo.longitude
        getPlaceName(lat: lat!, log: log!)
        currentDate.text = getDate(timestamp: weatherDetailInfo.time!, format: "EEEE, MMMM dd, yyyy")
        currentPrecipProb.text = weatherDetailInfo.precipProbability! + "%"
        currentTempRange.text = weatherDetailInfo.apparentTemperature! + "°C"
        currentWindSpeed.text = weatherDetailInfo.windSpeed! + "m/s"
        currentPrecipProbImg.image = UIImage(named: "PrecipProbability")
        currentTempImg.image = UIImage(named: "Temprature")
        currentWindSpeedImg.image = UIImage(named: "WindSpeed")
        setImage(img: currentWeatherIcon, icon: weatherDetailInfo.icon!)
        getUserImage()
        weatherInfoArray = weatherInfo
        weakWeatherView.delegate = self
        weakWeatherView.dataSource = self
        weakWeatherView.reloadData()
        SVProgressHUD.dismiss()
    }
    
    func setBackgroundImg(icon : String) {
        switch icon {
        case "clear-day", "clear-night":
            backgroundImg.image = UIImage(named: "SunnyDay")
        case "rain":
            backgroundImg.image = UIImage(named: "RainyDay")
        case "snow", "sleet":
            backgroundImg.image = UIImage(named: "SnowyDay")
        default:
            backgroundImg.image = UIImage(named: "CloudyDay")
        }
    }
    
    func setImage(img : UIImageView, icon : String) {
        switch icon {
        case "clear-day", "clear-night":
            img.image = UIImage(named: "Clear")
        case "rain":
            img.image = UIImage(named: "Rain")
        case "snow":
            img.image = UIImage(named: "Snow")
        case "sleet":
            img.image = UIImage(named: "Sleet")
        case "wind":
            img.image = UIImage(named: "Wind")
        case "fog":
            img.image = UIImage(named: "Fog")
        case "cloudy":
            img.image = UIImage(named: "Cloud")
        default:
            img.image = UIImage(named: "PartlyCould")
        }
    }
    
    func getPlaceName(lat : String, log : String) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: Double(lat)!, longitude: Double(log)!)
        geocoder.reverseGeocodeLocation(location) { (places, error) in
            if let placemark = places?.last {
                self.currentPlace.text = placemark.locality
            }
        }
    }

    @IBAction func backToCurrentPlace(_ sender: UIButton) {
        SVProgressHUD.show()
        let latitude = userInfo.latitude!
        let longitude = userInfo.longitude!
        fetchWeatherData(lat: latitude, log: longitude)
    }
    
    @IBAction func searchPlace(_ sender: UIButton) {
        self.present(autoCompleteController, animated: true)
    }
    
    @IBAction func showEarthquakeMap(_ sender: UIButton) {
        webService.getEarthquakeData { (features) in
            for item in features {
                if let properties = item["properties"] as? [String : Any],
                    let title = properties["title"] as? String,
                    let mag = properties["mag"] as? NSNumber,
                    let geometry = item["geometry"] as? [String : Any],
                    let coordinate = geometry["coordinates"] as? [Double] {
                    let featureItem = EarthquakeFeature(title: title, mag: Int(mag), lat: coordinate[1], log: coordinate[0])
                    self.earthquakeData.append(featureItem)
                } else {
                    self.showAlert(title: "Oops", msg: "Can not fetch earthquake info, please try again later.")
                }
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mapVC = storyboard.instantiateViewController(withIdentifier: "EarthquakeMapVC") as! EarthquakeMapViewController
            mapVC.earthquakeData = self.earthquakeData
            DispatchQueue.main.async {
                self.present(mapVC, animated: true)
            }
        }
    }
    
    func getDate(timestamp : String, format : String) -> String {
        let date = Date(timeIntervalSince1970: Double(timestamp)!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dateString: String = dateFormatter.string(from: date)
        return dateString
    }
    
    func getUserImage() {
        let id = (Auth.auth().currentUser?.uid)!
        let imgName = "UserImg/\(String(describing: id)).jpeg"
        var storageRef = Storage.storage().reference()
        storageRef = storageRef.child(imgName)
        DispatchQueue.global().async {
            storageRef.getData(maxSize: 10*1024*1024) { (data, error) in
                if data != nil && error == nil {
                    DispatchQueue.main.async {
                        let img = UIImage(data: data!)
                        self.profileImg.image = img
                    }
                }
            }
        }
    }
}

extension HomeViewController : GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        dismiss(animated: true, completion: nil)
        SVProgressHUD.show()
        let latitude = String(place.coordinate.latitude)
        let longitude = String(place.coordinate.longitude)
        fetchWeatherData(lat: latitude, log: longitude)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        showAlert(title: "Oops", msg: "Can not change place, please try later again.")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension HomeViewController : UICollectionViewDelegate {}

extension HomeViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weatherInfoArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeakWeatherCell", for: indexPath) as! WeakWeatherCollectionViewCell
        let weather = weatherInfoArray![indexPath.row]
        cell.date.text = self.getDate(timestamp: weather.time!, format: "EEEE")
        cell.temp.text = "\(weather.temperatureLow!)°C"
        setImage(img: cell.img, icon: weather.icon!)
        return cell
    }
}
