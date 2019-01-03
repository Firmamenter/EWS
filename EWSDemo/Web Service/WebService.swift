//
//  WebService.swift
//  EWSDemo
//
//  Created by Da Chen on 12/23/18.
//  Copyright © 2018 Da Chen. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseDatabase

class WebService {
    let storageRef = Storage.storage().reference()
    var ref = Database.database().reference()
    
    static let shared = WebService()
    
    private init() {}
    
    func getData(lat : String, log : String, completion : @escaping ([String : Any])->()) {
        let api = "https://api.darksky.net/forecast/11ede91352222ff170a84f5e4ca0aca8/\(lat),\(log)?units=si"
        let url = URL(string: api)
        _ = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                do {
                    if let allData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any] {
                        completion(allData)
                    } else {
                        completion([:])
                    }
                } catch {
                    completion([:])
                }
            } else {
                completion([:])
            }
        }.resume()
    }
    
    func getEarthquakeData(completion : @escaping ([[String : Any]])->()) {
        let api = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/4.5_day.geojson"
        let url = URL(string: api)
        _ = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error == nil {
                do {
                    if let allData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any] {
                        if let features = allData["features"] as? [[String : Any]] {
                            completion(features)
                        }
                    } else {
                        completion([])
                    }
                } catch {
                    completion([])
                }
            } else {
                completion([])
            }
        }.resume()
    }
    
    func fetchUserInfo(usrID : String, completion: @escaping (UserInfo) -> ()) {
        ref.child("User").child(usrID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let user = snapshot.value as? [String : Any] else {
                return
            }
            let userInfom = UserInfo.init(userId: user["UserId"] as? String,
                                          userName: user["UserName"] as? String,
                                          firstName: user["FirstName"] as? String,
                                          lastName: user["LastName"] as? String,
                                          emailId: user["Email"] as? String,
                                          address: user["Address"] as? String,
                                          phoneNumber: user["PhoneNumber"] as? String,
                                          password: user["Password"] as? String,
                                          latitude: user["Latitude"] as? String,
                                          longitude: user["Longitude"] as? String)
            completion(userInfom)
        })
    }
    
    func fetchAllImage(directory : String, id: String, completion: @escaping (Any?, Error?) -> ()) {
        let imageName = "\(directory)/\(String(describing: id)).jpeg"
        
        storageRef.child(imageName).getData(maxSize: 10*1024*1024) { (data, error) in
            if error == nil {
                let image = UIImage(data: data!)
                
                completion(image, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func fetchImage(directory : String, id: String, completion: @escaping (Any?, Error?) -> ()) {
        let imageName = "\(directory)/\(id).jpeg"
        self.storageRef.child(imageName).getData(maxSize: 10*1024*1024, completion: { (data, error) in
            completion(data, error)
        })
    }
    
    func uploadImage(directory : String, id : String, img : UIImage, completion: @escaping (Bool) -> ()) {
        let imgData = img.jpegData(compressionQuality: 0.0)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let imgName = "\(directory)/\(String(describing: id)).jpeg"
        let childStorageRef = storageRef.child(imgName)
        childStorageRef.putData(imgData!, metadata: metaData) { (data, error) in
            if error == nil {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
