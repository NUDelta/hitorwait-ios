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

let API_ADDR = Config.URL

class Pretracker: NSObject, CLLocationManagerDelegate, UNUserNotificationCenterDelegate{
    // static let sharedInstance: Pretracker = {
    //    let instance = Pretracker()
    //    return instance
    //}()
    
//    let backgroundTaskManager = BackgroundTaskManager()
//    let bgTask: BackgroundTaskManager = BackgroundTaskManager.shared()
    
    // background task timers
    var bgTimer: Timer? = Timer()
    var bgDelayTimer: Timer? = Timer()
    
    var currentLat:Double = 0.0
    var currentLng: Double = 0.0
    var previousLocation: CLLocation?
    var currentLocation: CLLocation?
    
    var hasPosted = false
    
    // 40-50 meters = road segment change
    let distanceUpdate = 30.0
    var clLocationList = [CLLocation]()
    
    var locationManager:CLLocationManager?
    var hasNotified:Bool = false
    
//    var itemRegion = LostItemRegion()
    
    // search region's lat and lon for debugging. Use LostItemRegion instead.
    // comment this out
    let regionLat = 42.047735
    let regionLng = -87.678919
    var regionLocation:CLLocation?

    var didEnterRegion:Bool?
    var hasDecisions: Bool?
    
    // list of roads for hit
    var hitRoads = [String:[Double]]()
    
    // all roads associated with search region.
    var allRoads = [String:[Double]]()
    
    var username:String = ""
    
    let defaults = UserDefaults.standard
    
    public static let sharedManager = Pretracker()

    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        
        guard let locationManager = self.locationManager else {
            return
        }
        
        // location manager initialization
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.activityType = .fitness
        locationManager.distanceFilter = CLLocationDistance(distanceUpdate)
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        // We should always enable this for background location tracking.
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
//        locationManager.startUpdatingLocation()
        
        // TODO: need to change the logic for finding lost item region.
        // call getNearbySearchRegions
//        let center = CLLocationCoordinate2D(latitude: regionLat, longitude: regionLng)
//        let region = CLCircularRegion(center: center, radius: 100, identifier: "region")
//        regionLocation = CLLocation(latitude: regionLat, longitude: regionLng)
//        locationManager.startMonitoring(for: region)

        didEnterRegion = false
        hasDecisions = false
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    
    //MARK: notification methods
    func showNotification(road: String, decision: String) {
        // TODO: modify contents for the request
        let content = UNMutableNotificationContent()
        content.title = "A lost item is nearby!"
        content.body = "Can you help me look for a lost item?\n It is on \(road)"
        
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
    
    //MARK: HiorWait APIs
    // input: current location, return road name
    func getRoad(_ location: CLLocation, completion: @escaping ([String:Any])->()) {
        let json = ["user":username,"lat": Double(location.coordinate.latitude), "lon": Double(location.coordinate.longitude)] as! [String : Any]
        CommManager.instance.urlRequest(route: "currentroad", parameters: json) {
            json in
            completion(json)
            let nc = NotificationCenter.default
            let userInfo = ["lat": self.currentLocation?.coordinate.latitude,"lng": self.currentLocation?.coordinate.longitude,"road": json["road"]!] as [String : Any]
            nc.post(name: NSNotification.Name(rawValue: "LocationUpdate"), object: nil, userInfo: userInfo)
            //                            completion(json)
        }
    }
    
    //TODO: need to create a class for get and post HTTP methods. Basically I'm copying and pasting this function everywhere.
    // upload locations to the server
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
        
        let date = NSDate()
        let year = Calendar.current.component(.year, from: date as Date)
        let month = Calendar.current.component(.month, from: date as Date)
        let day = Calendar.current.component(.day, from: date as Date)
        let hour = Calendar.current.component(.hour, from: date as Date)
        let minute = Calendar.current.component(.minute, from: date as Date)
        let routeId = "\(year)\(month)\(day)\(hour)\(minute)\(username)"
        let json = ["user":username,"routeId":routeId, "coordinates":arr] as [String : Any]
        
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
            
        } catch let error as NSError {
            //TODO: wherever there is an error, log it to the server.
            print(error)
        }
    }

    //MARK: location methods
    func addtoLocationList(_ location: CLLocation) {
        if !checkLocationAccuracy(location) {
            return
        }
        clLocationList.append(location)
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
        if (location.horizontalAccuracy < 0 || location.horizontalAccuracy > 65 || age > 300) {
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
    /*
     currently, we are calling the following method everytime there is a location changes.
     */
    func decisionForHitorWait() {
        if !hasNotified {
            for key in hitRoads.keys {
                let lat = hitRoads[key]?[0]
                let lng = hitRoads[key]?[1]
                let hitLocation = CLLocation(latitude: lat!, longitude: lng!)
                if let distance:Double = Double((currentLocation?.distance(from: hitLocation))!) {
                    if distance <= 100.0 {
                        showNotification(road: key, decision: "Hit")
                        hasNotified = true
                    }
                }
                
            }
        }
    }
    
    // We don't use this function anymore.
    func requestHitorWait(currentRoad: String) {
        var models:[String: Any]?
        if let loc:CLLocation = currentLocation {
            let param = ["user": (CURRENT_USER?.username)!, "road": currentRoad, "lat":String(describing: (currentLocation?.coordinate.latitude)),"lon":String(describing: (currentLocation?.coordinate.longitude))]
            
            
            //let url = URL(string: "\(API_ADDR)/currentroad?\(body_str)")!
            
            self.getRequest(url:"how", parameters: param as [String: Any]) {
                decisions in
                print(decisions)
                let decisionTable:[[String: String]] = decisions["decisions"] as! [[String:String]]
                let valueTable:[[String: Double]] = decisions["values"] as! [[String:Double]]
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
                            print(latlng)
                            print(self.hitRoads)
                            if !self.hasDecisions! {
                                self.hasDecisions = true
                            }
                            self.allRoads[road] = latlng
                        } else {
                            let idx = coordinateTable.index(forKey: road)
                            let coord = coordinateTable[idx!]
                            let latlng = coord.value as! [Double]
                            print(latlng)
                            self.allRoads[road] = latlng
                        }
                    }
                    models = decisions["models"] as! [String: Any]
                }
                let nc = NotificationCenter.default
                let userInfo = ["roads": self.allRoads, "models": models, "coordinates": coordinateTable, "values":valueTable.last]
                nc.post(name: NSNotification.Name(rawValue: "HitRoads"), object: nil, userInfo: userInfo)
                print(self.hitRoads)
            }
        }
    }
    
    // MARK: location manager delegate methods
//    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
//        locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        locationManager?.distanceFilter = CLLocationDistance(distanceUpdate)
//        
//        //TODO: change accuracy timer interval
////        accuracyTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(changeAccuracy), userInfo: nil, repeats: false)
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//        //        changeAccuracy(accuracy: kCLLocationAccuracyHundredMeters, distanceFilter: 300)
//    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        currentLocation = lastLocation

        //call CommManager POST method
        if checkLocationAccuracy(lastLocation) {
//            //call CommManager POST method
//            let params = ["user": (CURRENT_USER?.username)!, "lat": lastLocation.coordinate.latitude, "lon": lastLocation.coordinate.longitude, "date":date] as [String : Any]
//            CommManager.instance.urlRequest(route: "currentlocation", parameters: params, completion: {
//                json in
//                print(json)
//            })
            
            getRoad(lastLocation){_ in}
            
            //TODO: replace this with getNearbySearchRegions
//            let distance = currentLocation?.distance(from: regionLocation!)
//            if Double(distance!) <= 40.0 && didEnterRegion! == false {
////                requestHitorWait()
//                //showNotification(road: "testing", decision: "hit")
////                didEnterRegion = true
//            }
            
        }
        
//        if didEnterRegion! && hasDecisions! && !hasNotified {
//            decisionForHitorWait()
//        }
     
        // receive observers with LocationUpdate
        let nc = NotificationCenter.default
        let userInfo = ["lat": lastLocation.coordinate.latitude,"lng": lastLocation.coordinate.longitude,"road": ["no road"]] as [String : Any]
        nc.post(name: NSNotification.Name(rawValue: "LocationUpdate"), object: nil, userInfo: userInfo)
        
        
        let distance = calculateDistance(currentLocation: lastLocation)
        
        if distance >= distanceUpdate {
            addtoLocationList(lastLocation)
            //lastUpdated()
        }
        

        // all the stuff for background tasking.
//        if (bgTimer != nil) {
//            return
//        }
        
//        let bgTask = BackgroundTaskManager.shared()
//        bgTask?.beginNewBackgroundTask()
//        
//        // restart location manager after 1 minute
//        let intervalLength = 60.0
//        let delayLength = intervalLength - 10.0
//        
//        bgTimer = Timer.scheduledTimer(timeInterval: intervalLength, target: self, selector: #selector(Pretracker.restartLocationUpdates), userInfo: nil, repeats: false)
//        
//        // keep location manager inactive for 10 seconds every minute to save battery
//        if (bgDelayTimer != nil) {
//            bgDelayTimer!.invalidate()
//            bgDelayTimer = nil
//        }
//        
//        bgDelayTimer = Timer.scheduledTimer(timeInterval: delayLength, target: self, selector: #selector(Pretracker.stopLocationWithDelay), userInfo: nil, repeats: false)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: send error messages to DBs
        
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
