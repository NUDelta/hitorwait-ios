//
//  AppDelegate.swift
//  hitorwait
//
//  Created by Yongsung on 12/19/16.
//  Copyright © 2016 Delta. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate{

    var window: UIWindow?
    let center = UNUserNotificationCenter.current()
    let options: UNAuthorizationOptions = [.alert, .sound]
    let defaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        _ = Config()
        center.requestAuthorization(options: options) { (granted, error) in
            let generalCategory = UNNotificationCategory(identifier: "general", actions: [], intentIdentifiers: [], options: .customDismissAction)
            self.center.setNotificationCategories([generalCategory])
        }
        
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
        } else {
            // commment out after debugging.
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let tabbarVC = storyboard.instantiateViewController(withIdentifier: "tabbarVC")
//            self.window?.makeKeyAndVisible()
//            self.window?.rootViewController?.present(tabbarVC, animated: true, completion: nil)
            CURRENT_USER = User(username: defaults.value(forKey: "username") as! String, tokenId: defaults.value(forKey: "tokenId") as! String)
        }
        
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

    // we only have 30 seconds here.
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

        if (userInfo.index(forKey: "decisions") != nil) {
            print("hit or wait decision is here")
            print(userInfo["decisions"])
            
            // TODO: how to deal with hit-or-wait decisions?
            let decisionTable:[[String: String]] = userInfo["decisions"] as! [[String:String]]
            let coordinateTable:[String: Any] = userInfo["coordinates"] as! [String: Any]
            let models = userInfo["models"] as! [String: Any]
            
            
            if let decision = decisionTable.last {
                for road in decision.keys {
                    print(road)
                    if decision[road] == "Hit" {
                        print("\(decision[road]) on the road \(road))")
                        if let idx = coordinateTable.index(forKey: road){
                            let coord = coordinateTable[idx]
                            let latlng = coord.value as! [Double]
                            //                        self.hitRoads[road] = latlng
                            //                        print(latlng)
                            //                        print(self.hitRoads)
                            //                        if !self.hasDecisions! {
                            //                            self.hasDecisions = true
                            //                        }
                            //                        self.allRoads[road] = latlng
                        } else {
                            print("not in the coordinate table")
                        }
                    } else {
                        if let idx = coordinateTable.index(forKey: road) {
                            let coord = coordinateTable[idx]
                            let latlng = coord.value as! [Double]
                            print(latlng)
                        } else {
                            print("not in the coordinate table")
                        }
//                        self.allRoads[road] = latlng
                    }
                }
                let nc = NotificationCenter.default
                let allRoads = [HitRoad]()
//                let models = [String:Any]()
                
                //TODO: should add models and values for admin view.
                let userInfo = ["coordinates": coordinateTable, "decisions":decisionTable, "models": models] as [String : Any]
                nc.post(name: NSNotification.Name(rawValue: "HitRoads"), object: nil, userInfo: userInfo)
            }
        }
        
        Pretracker.sharedManager.locationManager!.requestLocation()

    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }
    
//    func sendUserToken(_ tokenId: String) {
//        let config = URLSessionConfiguration.default
//        let session: URLSession = URLSession(configuration: config)
//
//        let url : String = "\(Config.URL)/user?tokenId=\(tokenId)"
//        let urlStr : String = url.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
//        let searchURL : URL = URL(string: urlStr as String)!
//        do {
//            let task = session.dataTask(with: searchURL, completionHandler: {
//                (data, response, error) in
//                if error != nil {
//                    print(error?.localizedDescription)
//                }
//                if data != nil {
//                    do {
//                        if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
//                            print(json)
//                        }
//                    } catch let error as NSError {
//                        print(error)
//                    }
//                }
//            })
//            task.resume()
//            
//        } catch let error as NSError{
//            print(error)
//        }
//    }
    
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
        showNotificationForTermination()
    }
    
    func showNotificationForTermination() {
        let content = UNMutableNotificationContent()
        content.title = "Please reopen the app"
        content.body = "Your app is about to be terminated."
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)
        
        let request = UNNotificationRequest(identifier: "local", content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }


}

