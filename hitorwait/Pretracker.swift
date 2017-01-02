//
//  Pretracker.swift
//  hitorwait
//
//  Created by Yongsung on 12/29/16.
//  Copyright © 2016 Delta. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import UserNotifications

let API_ADDR = "http://127.0.0.1:5000"

class Pretracker: NSObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate{
    static let sharedInstance: Pretracker = {
        let instance = Pretracker()
        return instance
    }()
    
    let backgroundTaskManager = BackgroundTaskManager()
    let bgTask: BackgroundTaskManager = BackgroundTaskManager.shared()
    
    // background task timers
    var bgTimer: Timer? = Timer()
    var bgDelayTimer: Timer? = Timer()
    
    var currentLat:Double = 0.0
    var currentLng: Double = 0.0
    var previousLocation: CLLocation?
    var currentLocation: CLLocation?
    
    var hasPosted = false
    var locationCounter = 4
    // 40-50 meters = road segment change
    let distanceUpdate = 45.0
    var clLocationList = [CLLocation]()
    
    var locationManager:CLLocationManager?
    var hasNotified:Bool = false
    var accuracyTimer: Timer? = Timer()
        
    let regionLat = 42.047735
    let regionLng = -87.678919
    var regionLocation:CLLocation?
    var didEnterRegion:Bool?
    var hasDecisions: Bool?
    
    var hitRoads = [String:[Double]]()
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = distanceUpdate
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            print("here")
        }
        
        let center = CLLocationCoordinate2D(latitude: regionLat, longitude: regionLng)
        let region = CLCircularRegion(center: center, radius: 100, identifier: "region")
        regionLocation = CLLocation(latitude: regionLat, longitude: regionLng)
        
        locationManager.startUpdatingLocation()
        
        locationManager.startMonitoring(for: region)
        
        didEnterRegion = false
        hasDecisions = false
        
        UNUserNotificationCenter.current().delegate = self

    }
    
    // TODO: stop location updates after x minutes in any given region. add region to monitor with x distance to notify

    //MARK: notification methods
    func showNotification(road: String, decision: String) {
        // TODO: modify contents for the request
        let content = UNMutableNotificationContent()
        content.title = "A lost item is nearby!"
        content.body = "Can you help me look for a lost item?\n it is on \(road)"
        //        locationManager.delegate = self
        
        
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
    
    func notify(location: CLLocation, atDistance distance: Double) {
        // get rid of inaccurate location updates
        if checkLocationAccuracy(location) {
//            let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
//            let region = CLCircularRegion(center: center, radius: 100, identifier: "region")
//            
//            let distanceToRegion = location.distance(from: CLLocation(latitude: region.center.latitude, longitude: region.center.longitude))
//            
//            print("distance to region is \(distanceToRegion)")
//            
//            if distanceToRegion <= distance {
//                showNotification()
//            }
        }
    }
    
    //MARK: network methods
    func getRoad(_ location: CLLocation, completion: @escaping ([String:Any])->()) {
        let config = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: config)
        
        let body_str = "user=yk&lat=\(Float(location.coordinate.latitude))&lng=\(Float(location.coordinate.longitude))"
        
        let url = URL(string: "\(API_ADDR)/currentroad?\(body_str)")!
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
                            completion(json)
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
        var request = URLRequest(url: URL(string: "\(API_ADDR)/postRoutes")!)
        
        request.httpMethod = "POST"
        var arr = [Any]()
        for location in locations {
            print(location.coordinate.latitude)
            print(location.coordinate.latitude)
            print("diretion is: \(location.horizontalAccuracy)")
            print("timestamp is: \(location.timestamp)")
            arr.append([location.coordinate.latitude,location.coordinate.longitude])
        }
        
        //TODO: change user to actual username.
        
        let json = ["user":"yk","coordinates":arr] as [String : Any]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                print(response)
            })
            task.resume()
            
        } catch {
            print("error")
        }
    }

    //MARK: location methods
    func addtoLocationList(_ location: CLLocation) {
        if !checkLocationAccuracy(location) {
            return
        }
        clLocationList.append(location)
        if clLocationList.count >= locationCounter {
            // upload to the server
//            Location.sharedInstance.postLocation(clLocationList)
            clLocationList = []
        }
    }
    
    func calculateDistance(currentLocation: CLLocation) -> Double{
        if previousLocation == nil {
            previousLocation = currentLocation
        }
        
        var locationDistance = currentLocation.distance(from: previousLocation!)
        print(locationDistance)
        previousLocation = currentLocation
        return locationDistance
    }
    
    func checkLocationAccuracy(_ location: CLLocation) -> Bool {
        let age = -location.timestamp.timeIntervalSinceNow
        if (location.horizontalAccuracy < 0 || location.horizontalAccuracy > 65 || age > 5) {
            return false
        }
        return true
    }
    
    func getRequest(url: String, parameters: [String: Any], completion: @escaping ([String: Any]) -> ()) {
        let config = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: config)
        let params = parameters.stringFromHttpParameters()
        let urlString = URL(string: "\(API_ADDR)/\(url)?\(params)")!
        let task = session.dataTask(with: urlString, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                        completion(json)
                    }
                } catch {
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
    //MARK: Hit or Wait methods
    
    func decisionForHitorWait() {
        if !hasNotified {
            for key in hitRoads.keys {
                let lat = hitRoads[key]?[0]
                let lng = hitRoads[key]?[1]
                let hitLocation = CLLocation(latitude: lat!, longitude: lng!)
                if Double((currentLocation?.distance(from: hitLocation))!) <= 40.0 {
                    showNotification(road: key, decision: "Hit")
                    hasNotified = true
                }
                
            }
        }
    }
    
    func requestHitorWait() {
        if let loc:CLLocation = currentLocation {
//            getRoad(loc) {
//                json in
//                print(json)
//                let road = json["road"] as! [Any]
//                let currentRoad = road[0] as! String
//                print(currentRoad)
//                let param = ["user":"yk", "road": currentRoad]
//                self.getRequest(url:"how", parameters: param as [String: Any]) {
//                    decisions in
//                    print(decisions)
//                }
//            }

            let currentRoad = "1633-1699 Chicago Ave"
            print(currentRoad)
            let param = ["user":"yk", "road": currentRoad]
            self.getRequest(url:"how", parameters: param as [String: Any]) {
                decisions in
                print(decisions)
                let decisionTable:[[String: String]] = decisions["decisions"] as! [[String:String]]
                let coordinateTable:[String: Any] = decisions["coordinates"] as! [String: Any]
                print(decisionTable.count)

                if let decision = decisionTable.last {
                    for road in decision.keys {
                        if decision[road] == "Hit" {
                            print("\(decision[road]) on the road \(road))")
                            let idx = coordinateTable.index(forKey: road)
                            let coord = coordinateTable[idx!]
                            let latlng = coord.value as! [Double]
                            self.hitRoads[road] = latlng
//                            self.hitRoads[road] = latlng
                            print(latlng)
                            print(self.hitRoads)
                            self.hasDecisions = true
                        }
                    }
                }
                print(self.hitRoads)
            }
        }
        
    }
    
    // MARK: location manager delegate methods
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.distanceFilter = 1
        
        requestHitorWait()
        //TODO: change accuracy timer interval
//        accuracyTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(changeAccuracy), userInfo: nil, repeats: false)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        //        changeAccuracy(accuracy: kCLLocationAccuracyHundredMeters, distanceFilter: 300)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        
//        print(lastLocation.coordinate.latitude)
        if checkLocationAccuracy(lastLocation) {
            currentLocation = lastLocation
            let distance = currentLocation?.distance(from: regionLocation!)
            if Double(distance!) <= 80.0 && didEnterRegion! == false {
                requestHitorWait()
                showNotification(road: "testing", decision: "hit")
                didEnterRegion = true
            }
            
        }
        
        if didEnterRegion! && hasDecisions! && !hasNotified {
            decisionForHitorWait()
        }
        
        // TODO: call functions with last location updates
        
//        let distance = calculateDistance(currentLocation: lastLocation)
//        if distance >= 30 {
//            getRoad(lastLocation)
//        }
        let nc = NotificationCenter.default
        let userInfo = ["lat": lastLocation.coordinate.latitude,"lng": lastLocation.coordinate.longitude,"road": "no road"] as [String : Any]
        nc.post(name: NSNotification.Name(rawValue: "LocationUpdate"), object: nil, userInfo: userInfo)
        
        addtoLocationList(lastLocation)
        notify(location: lastLocation, atDistance: 25.0)
        
        // reset timer
        if (bgTimer != nil) {
            return
        }
        
        let bgTask = BackgroundTaskManager.shared()
        bgTask?.beginNewBackgroundTask()
        
        // restart location manager after 1 minute
        let intervalLength = 60.0
        let delayLength = intervalLength - 10.0
        
        bgTimer = Timer.scheduledTimer(timeInterval: intervalLength, target: self, selector: #selector(restartLocationUpdates), userInfo: nil, repeats: false)
        
        // keep location manager inactive for 10 seconds every minute to save battery
        if (bgDelayTimer != nil) {
            bgDelayTimer!.invalidate()
            bgDelayTimer = nil
        }
        
        bgDelayTimer = Timer.scheduledTimer(timeInterval: delayLength, target: self, selector: #selector(stopLocationWithDelay), userInfo: nil, repeats: false)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    //MARK: Background Task Functions
    @objc private func stopLocationWithDelay() {
        print("Background delay 10 seconds")
        locationManager!.stopUpdatingLocation()
    }
    
    @objc private func restartLocationUpdates() {
        print("Background restarting location updates")
        
        if (bgTimer != nil) {
            bgTimer!.invalidate()
            bgTimer = nil
        }
        locationManager!.startUpdatingLocation()
    }
    
    //MARK: Utils
    func changeAccuracy(accuracy: Double, distanceFilter: Double) {
        locationManager?.desiredAccuracy = accuracy
        locationManager?.distanceFilter = distanceFilter
    }
    
}

// TODO: come back later to change this
// copied from the below stackoverflow answer.
// http://stackoverflow.com/questions/27723912/swift-get-request-with-parameters

extension Dictionary {
    
    /// Build string representation of HTTP parameter dictionary of keys and objects
    ///
    /// This percent escapes in compliance with RFC 3986
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: String representation in the form of key1=value1&key2=value2 where the keys and values are percent escaped
    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).addingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).addingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joined(separator: "&")
    }
    
}

extension String {
    
    /// Percent escapes values to be added to a URL query as specified in RFC 3986
    ///
    /// This percent-escapes all characters besides the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: Returns percent-escaped string.
    
    func addingPercentEncodingForURLQueryValue() -> String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
}
