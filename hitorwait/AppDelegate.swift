//
//  AppDelegate.swift
//  hitorwait
//
//  Created by Yongsung on 12/19/16.
//  Copyright © 2016 Delta. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{

    var window: UIWindow?
    let center = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound]
    let defaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        _ = Config()

//        center.requestAuthorization(options: options) { (granted, error) in
//            let generalCategory = UNNotificationCategory(identifier: "general", actions: [], intentIdentifiers: [], options: .customDismissAction)
//            self.center.setNotificationCategories([generalCategory])
//        }
        
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }
            // iOS 9 support
        else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 8 support
        else if #available(iOS 8, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
            // iOS 7 support
        else {  
            application.registerForRemoteNotifications(matching: [.badge, .sound, .alert])
        }
        
        if (defaults.object(forKey: "username") != nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabbarVC = storyboard.instantiateViewController(withIdentifier: "tabbarVC")
            self.window?.makeKeyAndVisible()
            self.window?.rootViewController?.present(tabbarVC, animated: true, completion: nil)
            CURRENT_USER = User(username: defaults.value(forKey: "username") as! String, tokenId: defaults.value(forKey: "tokenId") as! String)

        } else {
            // commment out after debugging.
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let tabbarVC = storyboard.instantiateViewController(withIdentifier: "tabbarVC")
//            self.window?.makeKeyAndVisible()
//            self.window?.rootViewController?.present(tabbarVC, animated: true, completion: nil)
        }
//        showNotificationForTermination()
        return true
    }

    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .none {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print(deviceTokenString)
        defaults.set(deviceTokenString, forKey: "tokenId")
    }

    // we don't use this when there is a background task needs to be handled.
//    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
//        print("Push notification received: \(data)")
//        Pretracker.sharedManager.locationManager!.startUpdatingLocation()
//        if let currentLocation = Pretracker.sharedManager.currentLocation {
//            let lat = currentLocation.coordinate.latitude
//            let lon = currentLocation.coordinate.longitude
//            sendCurrentLocation(lat: Float(lat),lon: Float(lon))
//        }
//    }
    
    func VCforPush() {
        let nc = NotificationCenter.default
//        let userInfo = ["lat": self.currentLocation?.coordinate.latitude,"lng": self.currentLocation?.coordinate.longitude,"road": json["road"]!] as [String : Any]
        nc.post(name: NSNotification.Name(rawValue: "PushReceived"), object: nil, userInfo: nil)
    }

    // we only have 30 seconds here.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        //TODO: need to send decision_activity_id
        if (userInfo.index(forKey: "search_road") != nil) {
            if let region_id = userInfo["search_region_id"] {
//                print(region_id)
                defaults.set(region_id, forKey: "regionId")
                let decision_activity_id = userInfo["decision_activity_id"]
                defaults.set(decision_activity_id, forKey:"decision_activity_id")
                let search_road = userInfo["search_road"]
                defaults.set(search_road, forKey: "search_road")
                VCforPush()
            }
        }
        
        if (userInfo.index(forKey: "geofence") != nil) {
            let lat = userInfo["lat"] as! Double
            let lon = userInfo["lon"] as! Double
            let radius = userInfo["radius"] as! Double
            let region = userInfo["geofence"] as! String
            addGeofence(lat: lat,lon: lon,radius: radius,region: region)
        }
        
        if (userInfo.index(forKey: "removeOneGeofence") != nil) {
            let region = userInfo["remove"] as! String
            removeOneGeofence(region: region)
        }
        
        if (userInfo.index(forKey: "removeAllGeofence") != nil) {
            removeAllGeofence()
        }
        
//        if (userInfo.index(forKey: "isPretrack") != nil) {
//            if let isPretrack = userInfo["isPretrack"] {
//                let nc = NotificationCenter.default
//                nc.post(name: NSNotification.Name(rawValue: "isPretrack"), object: nil, userInfo: ["isPretrack":isPretrack])
//            }
//        }
        
        Pretracker.sharedManager.locationManager!.startUpdatingLocation()
        
        if let currentLocation = Pretracker.sharedManager.currentLocation {
            let lat = currentLocation.coordinate.latitude
            let lon = currentLocation.coordinate.longitude
            let speed = currentLocation.speed
            let date = Date().timeIntervalSince1970
            let accuracy = currentLocation.horizontalAccuracy
            let params = ["user": (CURRENT_USER?.username)! ?? "", "lat": lat, "lon": lon, "date":date, "accuracy":accuracy, "speed":speed] as [String : Any]
            CommManager.instance.urlRequest(route: "currentlocation", parameters: params, completion: {
                json in
                print(json)
                // need to add this for handling background fetch.
                completionHandler(UIBackgroundFetchResult.noData)
            })
        }
    }
    
    func removeAllGeofence() {
        for monitoredRegion in (Pretracker.sharedManager.locationManager?.monitoredRegions)! {
            Pretracker.sharedManager.locationManager?.stopMonitoring(for: monitoredRegion)
        }
    }
    
    func removeOneGeofence(region: String) {
        for monitoredRegion in (Pretracker.sharedManager.locationManager?.monitoredRegions)! {
            if region ==  monitoredRegion.identifier {
                Pretracker.sharedManager.locationManager?.stopMonitoring(for: monitoredRegion)
            }
        }
    }
    
    func addGeofence(lat: Double,lon: Double, radius: Double, region:String) {
//        // region 1
//        // 42.058400,-87.680636
//        let center1 = CLLocationCoordinate2D(latitude: 42.058400, longitude: -87.680636)
//        let region1 = CLCircularRegion(center: center1, radius: 100, identifier: "noyes1")
//        
//        // region 2
//        // 42.058387, -87.678826
//        let center2 = CLLocationCoordinate2D(latitude: 42.058387, longitude: -87.678826)
//        let region2 = CLCircularRegion(center: center2, radius: 100, identifier: "noyes2")
//        
//        // region 3
//        // 42.057995, -87.678015
//        let center3 = CLLocationCoordinate2D(latitude: 42.057995, longitude: -87.678015)
//        let region3 = CLCircularRegion(center: center3, radius: 100, identifier: "noyes3")
//        
//        // foster 1
//        // 42.053864, -87.680771
//        let center4 = CLLocationCoordinate2D(latitude: 42.053864, longitude: -87.680771)
//        let region4 = CLCircularRegion(center: center4, radius: 100, identifier: "foster1")
//        
//        // foster 2
//        // 42.053868, -87.679536
//        let center5 = CLLocationCoordinate2D(latitude: 42.053868, longitude: -87.679536)
//        let region5 = CLCircularRegion(center: center5, radius: 100, identifier: "foster2")
//        
//        // foster 3
//        // 42.053882, -87.678355
        
        var addRegion = true
        for monitoredRegion in (Pretracker.sharedManager.locationManager?.monitoredRegions)! {
            if region ==  monitoredRegion.identifier {
                addRegion = false
            }
        }
        
        if addRegion {
            let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let region = CLCircularRegion(center: center, radius: 100, identifier: region)
            Pretracker.sharedManager.locationManager!.startMonitoring(for: region)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//        showNotificationForTermination()
////        calendarNotificationForTermination()
//        let params = ["view":"appTerminated","user":(CURRENT_USER?.username)! ?? "","time":Date().timeIntervalSince1970] as [String: Any]
//        CommManager.instance.urlRequest(route: "appActivity", parameters: params, completion: {
//            json in
//            print (json)
//            // if there is no nearby search region with the item not found yet, server returns {"result":0}
//        })
    }
    
    func showNotificationForTermination() {
        let content = UNMutableNotificationContent()
        content.title = "Please reopen the app"
        content.body = "Your app is about to be terminated."
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2,
                                                        repeats: false)
        
        let request = UNNotificationRequest(identifier: "local", content: content, trigger: trigger)
        
        center.add(request)
    }
    
    func calendarNotificationForTermination() {
        let content = UNMutableNotificationContent()
        content.title = "Please reopen the app"
        content.body = "Your app is about to be terminated."
        
        var dateComponent = DateComponents()
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        dateComponent.hour = hour
        dateComponent.minute = minute + 1
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        
        let request = UNNotificationRequest(identifier: "local", content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }


}

