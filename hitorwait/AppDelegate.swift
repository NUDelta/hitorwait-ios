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
//        _ = Location.sharedInstance
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
            print(defaults.value(forKey: "username"))
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabbarVC = storyboard.instantiateViewController(withIdentifier: "tabbarVC")
            self.window?.makeKeyAndVisible()
            self.window?.rootViewController?.present(tabbarVC, animated: true, completion: nil)
        } else {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let tabbarVC = storyboard.instantiateViewController(withIdentifier: "tabbarVC")
//            self.window?.makeKeyAndVisible()
//            self.window?.rootViewController?.present(tabbarVC, animated: true, completion: nil)
            print("no username stored")
            CURRENT_USER = User(username: defaults.value(forKey: "username") as! String, tokenId: defaults.value(forKey: "tokenId") as! String)
        }
        
        return true
    }

    func registerForPushNotifications(application: UIApplication) {
        let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        application.registerUserNotificationSettings(settings)
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
//        sendUserToken(deviceTokenString)
    }
//    
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
        print("received notification")
        
        if (userInfo.index(forKey: "decisions") != nil) {
            print("hit or wait decision is here")
            print(userInfo["decisions"])
            
            // TODO: how to deal with hit-or-wait decisions?
            //
        }
        
//        Pretracker.sharedManager.locationManager!.startUpdatingLocation()
        Pretracker.sharedManager.locationManager!.requestLocation()
        
        //TODO: need notification center to observer the didupdatelocation
        
        if let currentLocation = Pretracker.sharedManager.currentLocation {
            let lat = currentLocation.coordinate.latitude
            let lon = currentLocation.coordinate.longitude
            let config = URLSessionConfiguration.default
            let session: URLSession = URLSession(configuration: config)
            
            let date = Date().timeIntervalSince1970
            
            let user = defaults.value(forKey: "username")!
            let url : String = "\(Config.URL)/currentlocation?lat=\(lat)&lon=\(lon)&date=\(Int(date))&user=\(user)"
            
            let urlStr : String = url.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
            let searchURL : URL = URL(string: urlStr as String)!
            do {
                let task = session.dataTask(with: searchURL, completionHandler: {
                    (data, response, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                    if data != nil {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                                print(json)
                                completionHandler(UIBackgroundFetchResult.noData)
                            }
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                })
                task.resume()
                
            } catch let error as NSError{
                print(error)
            }
        } else {
            let lat = 0.0
            let lon = 0.0
            let config = URLSessionConfiguration.default
            let session: URLSession = URLSession(configuration: config)
            
            let date = Date().timeIntervalSince1970
            
            let user = defaults.value(forKey: "username")!
            let url : String = "\(Config.URL)/currentlocation?lat=\(lat)&lon=\(lon)&date=\(Int(date))&user=\(user)"
            
            let urlStr : String = url.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
            let searchURL : URL = URL(string: urlStr as String)!
            do {
                let task = session.dataTask(with: searchURL, completionHandler: {
                    (data, response, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                    if data != nil {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                                print(json)
                                completionHandler(UIBackgroundFetchResult.noData)
                            }
                        } catch let error as NSError {
                            print(error)
                        }
                    }
                })
                task.resume()
                
            } catch let error as NSError{
                print(error)
            }
        }
    }
    
    //MARK: send user's current location
    func sendCurrentLocation(lat: Float, lon: Float) {

    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Print the error to console (you should alert the user that registration failed)
        print("APNs registration failed: \(error)")
    }
    
    func sendUserToken(_ tokenId: String) {
        let config = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: config)

        let url : String = "\(Config.URL)/user?tokenId=\(tokenId)"
        let urlStr : String = url.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
        let searchURL : URL = URL(string: urlStr as String)!
        do {
            let task = session.dataTask(with: searchURL, completionHandler: {
                (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                if data != nil {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                            print(json)
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            })
            task.resume()
            
        } catch let error as NSError{
            print(error)
        }
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
        //TODO: Let's add notification here.
        print("before termination")
        showNotificationForTermination()
    }
    
    func showNotificationForTermination() {
        let content = UNMutableNotificationContent()
        content.title = "Please reopen the app"
        content.body = "Your app is about to be terminated."
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)
        
        let request = UNNotificationRequest(identifier: "local", content: content, trigger: trigger)
        
        let notiCenter = UNUserNotificationCenter.current()
        
        notiCenter.add(request) { (error) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }


}

