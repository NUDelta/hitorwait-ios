//
//  ViewController.swift
//  hitorwait
//
//  Created by Yongsung on 12/19/16.
//  Copyright © 2016 Delta. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import MapKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    var currentLat:Double = 0.0
    var currentLng: Double = 0.0
    var locationList:[(Double,Double)] = []
    
    @IBOutlet weak var roadLabel: UILabel!
    let notiCenter = UNUserNotificationCenter.current()
    let regionRadius: CLLocationDistance = 500

    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func didClickButton(_ sender: UIButton) {
        print("clicked")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        Pretracker.sharedInstance.changeAccuracy(accuracy: kCLLocationAccuracyBestForNavigation, distanceFilter: 1)
        // Do any additional setup after loading the view, typically from a nib.
//        var user = User()
//        user.getUser("yk") { json in
////            print("json data is \(json["coordinates"])")
//            let array:[Any] = json["coordinates"] as! [Any]
//            for a in array {
////                print(a)
//                let arr:[Double] = a as! [Double]
//                print(arr[0])
//            }
//        }
//        let date = NSDate()
//        print(date)
        
        
        let initialLocation = CLLocation(latitude: 42.065335, longitude: -87.682367)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: false)
        mapView.showsUserLocation = true
//
        let center = NotificationCenter.default
//
//        // important to use OperationQueue.main for main queue to prevent "This application is modifying the autolayout engine from a background thread after the engine was accessed from the main thread. This can lead to engine corruption and weird crashes."
//        
        center.addObserver(forName: Notification.Name(rawValue:"LocationUpdate"), object: nil, queue: OperationQueue.main , using: catchNotification)
    }

    func catchNotification(notification: Notification) -> Void {
        if notification.userInfo != nil {
//            guard let userInfo = notification.userInfo,
//                let lat = userInfo["lat"] as? Double,
//                let lng = userInfo["lng"] as? Double,
//                let road = userInfo["road"] as? String else {
//                    return
//            }
            
            let userInfo = notification.userInfo! as! [String:Any]
            let lat = userInfo["lat"] as? Double
            let lng = userInfo["lng"] as? Double

//            let road = userInfo["road"] as? [Any]
//            let road_name = road![0] as! String
//
//            DispatchQueue.main.async(){
//                self.roadLabel.text = road_name
//            }
//            }
            let currentLocation = CLLocation(latitude: lat!, longitude: lng!)
            
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate,
                                                                      regionRadius * 2.0, regionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: false)
            
        }

    }
}

