//
//  Location.swift
//  hitorwait
//
//  Created by Yongsung on 12/19/16.
//  Copyright © 2016 Delta. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import UserNotifications

//let API_ADDR = "http://127.0.0.1:5000"
class Location: NSObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate{
    
    // MARK: Pretracking background task
    let backgroundTaskManager = BackgroundTaskManager()
    
    
    static let sharedInstance: Location = {
        let instance = Location()
        return instance
    }()
    
    var currentLat:Double = 0.0
    var currentLng: Double = 0.0
    
    var hasPosted = false
    var counter = 0
    
    var locationDistance: Double?
    
    var prevLocation: CLLocation?
    var currLocation: CLLocation?

    var locationManager:CLLocationManager?

//    func postLocation() {
//        
//    }
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
        self.currentLat = 0.0
        self.currentLng = 0.0
        
//        locationManager.delegate = self
        
//        if CLLocationManager.authorizationStatus() == .notDetermined {
//            locationManager.requestAlwaysAuthorization()
//            locationManager.requestWhenInUseAuthorization()
//            print("here")
//        }
//
////        locationManager.requestWhenInUseAuthorization()
////        locationManager.requestAlwaysAuthorization()
//        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
//        locationManager.distanceFilter = 20
//        locationManager.startUpdatingLocation()
//        locationManager.requestLocation()
//        
//        
//        UNUserNotificationCenter.current().delegate = self
//
//        let center = CLLocationCoordinate2D(latitude: 37.337566, longitude: -122.04120)
//        let region = CLCircularRegion(center: center, radius: 1000, identifier: "region")
//        
//        locationManager.startMonitoring(for: region)
//    
//        print("requested location")
    }
    
    deinit {
        print("deinitialized")
    }
    
    // MARK: Location Manager Delegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if prevLocation == nil {
            prevLocation = locations.last
        }
        
        let currentLocation = locations.last
        locationDistance = currentLocation?.distance(from: prevLocation!)
        print(locationDistance)
        prevLocation = currentLocation
        
//        print("\(currentLocation?.coordinate.latitude) and \(currentLocation?.coordinate.longitude)")
        currentLat = (currentLocation?.coordinate.latitude)!
        currentLng = (currentLocation?.coordinate.longitude)!

        getRoad(currentLocation!)
//        { json in
//
//        }
//        if counter < 10 {
////            postLocation(locations)
//            counter += 1
//            print(counter)
//        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let content = UNMutableNotificationContent()
        content.title = "A lost item is nearby!"
        content.body = "Can you help me look for a lost item?"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1,
                                                        repeats: false)
        
        let request = UNNotificationRequest(identifier: "local", content: content, trigger: trigger)
        
        let notiCenter = UNUserNotificationCenter.current()
        
        notiCenter.add(request) { (error) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    // MARK: API calls
    // FIXME: change this
    // TODO: todo
    func getRoad(_ location: CLLocation) {
        let config = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: config)
        
        let body_str = "user=yk&lat=\(Float(location.coordinate.latitude))&lng=\(Float(location.coordinate.longitude))"
    
        let url = URL(string: "\(API_ADDR)/currentroad?\(body_str)")!
//        request.httpMethod = "GET"
//        let json = ["user":"yk", "lat": Float(location.coordinate.latitude), "lng": Float(location.coordinate.longitude)] as [String: Any]
//        print(json)
        do {
            let task = session.dataTask(with: url, completionHandler: {
                (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }                
//                print(response)
                if data != nil {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                            print(json)
                            let nc = NotificationCenter.default
                            let userInfo = ["lat": self.currentLat,"lng": self.currentLng,"road": json["road"]!] as [String : Any]
                            nc.post(name: NSNotification.Name(rawValue: "LocationUpdate"), object: nil, userInfo: userInfo)
//                            completion(json)
                        }
                    } catch {
                        print("serialization error")
                    }
                }
            })
            task.resume()
            
        } catch {
            print("error")
        }
    }
    
    func postLocation(_ locations:[CLLocation]) {
        let config = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: config)
        var request = URLRequest(url: URL(string: "http://192.168.1.65:5000/postRoutes")!)
        
        request.httpMethod = "POST"
        var arr = [Any]()
        for location in locations {
            print("diretion is: \(location.horizontalAccuracy)")
            print("timestamp is: \(location.timestamp)")
            arr.append([location.coordinate.latitude,location.coordinate.longitude])
        }
        
        let date = NSDate()
        let year = Calendar.current.component(.year, from: date as Date)
        let month = Calendar.current.component(.month, from: date as Date)
        let day = Calendar.current.component(.day, from: date as Date)
        let hour = Calendar.current.component(.hour, from: date as Date)
        let minute = Calendar.current.component(.minute, from: date as Date)
        let routeId = "\(year)\(month)\(day)\(hour)\(minute)yk"
        let json = ["user":"yk","routeId":routeId, "coordinates":arr] as [String : Any]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            //            request.httpBody = "user=yk&route=42.52".data(using: .utf8)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            //            print(jsonData)
            //            do {
            //                if let json = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any] {
            //                    print(json)
            //                }
            //            } catch {
            //                print("serialization error")
            //            }
            
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                
                print(response)
                //                do {
                //                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                //                        print(json)
                //                    }
                //                } catch {
                //                    print("serialization error")
                //                }
            })
            task.resume()
            
        } catch {
            print("error")
        }
    }
}
