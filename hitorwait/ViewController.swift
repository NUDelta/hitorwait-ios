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

class ViewController: UIViewController, UNUserNotificationCenterDelegate, MKMapViewDelegate {
    var currentLat:Double = 0.0
    var currentLng: Double = 0.0
    var locationList:[(Double,Double)] = []
    var movementModel: [String:Any]?
    var coordinateTable: [String:[Double]]?
    var valueTable: [String:Double]?
    var hitRoads: [String:[Double]]?
    
    @IBOutlet weak var roadLabel: UILabel!
    let notiCenter = UNUserNotificationCenter.current()
    let regionRadius: CLLocationDistance = 500
    var setRegion:Bool = false

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
        mapView.delegate = self
//
        let center = NotificationCenter.default
//
//        // important to use OperationQueue.main for main queue to prevent "This application is modifying the autolayout engine from a background thread after the engine was accessed from the main thread. This can lead to engine corruption and weird crashes."
//        
        center.addObserver(forName: Notification.Name(rawValue:"LocationUpdate"), object: nil, queue: OperationQueue.main , using: catchNotification)
        center.addObserver(forName: Notification.Name(rawValue:"HitRoads"), object: nil, queue: OperationQueue.main, using: catchHitRoadsNotification)
//        addModelOverlay()
        
        let coordinate = CLLocationCoordinate2D(latitude: 42.04783640895302, longitude: -87.67942116214238)
//        getDirection(coordinate: coordinate)
    }
    
    func catchHitRoadsNotification(notification: Notification) -> Void {
        if let userInfo = notification.userInfo {
            print(userInfo)
            let roads = userInfo["roads"] as! [String:[Double]]
            hitRoads = roads

            
            coordinateTable = userInfo["coordinates"] as! [String: [Double]]
            let models = userInfo["models"] as! [String:Any]
            movementModel = models
            valueTable = userInfo["values"] as? [String: Double]
            
            for road in roads.keys {
                let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: roads[road]![0], longitude: roads[road]![1])
                let annotationDescription = "\(road): \((valueTable?[road])!)"
                let newRoad = HitRoad.init(annotationDescription, coordinate: coordinate)
                mapView.addAnnotation(newRoad)
            }
            
//            let currentCoordinate = CLLocationCoordinate2D(latitude: 42.0474593265802, longitude: -87.6790835961543)
//            for model in models.keys {
//                print(model)
//                let roadModel = models[model] as! [String: Float]
//                for r in roadModel.keys {
//                    print("road \(r): with \(roadModel[r]) chance")
//                    var coordinates = [CLLocationCoordinate2D]()
//                    coordinates.append(currentCoordinate)
//                    let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: coordinateTable![r]![0], longitude: coordinateTable![r]![1])
//                    coordinates.append(coordinate)
//
//                    if (hitRoads?.keys.contains(r))! {
//                        getDirection(coordinate: coordinate) { polyline in
//                            
//                            //                        let polyline = MKGeodesicPolyline(coordinates: coordinates, count: coordinates.count)
//                            polyline.title = r
//                            if roadModel[r]! >= 0.4 {
//                                polyline.subtitle = "High"
//                            } else if roadModel[r]! < 0.4 {
//                                polyline.subtitle = "Low"
//                            }
//                            self.mapView.add(polyline)
//                        }
//                    }
//
////                    let polyline = MKGeodesicPolyline(coordinates: coordinates, count: coordinates.count)
////                    polyline.title = r
////                    if roadModel[r]! >= 0.4 {
////                        polyline.subtitle = "High"
////                    } else if roadModel[r]! < 0.4 {
////                        polyline.subtitle = "Low"
////                    }
////                    mapView.add(polyline)
//                }
//            }
        } else {
            print("it's nil")
        }
    }
    
    func getDirection(coordinate: CLLocationCoordinate2D, completion: @escaping(MKPolyline) -> ()) {
        let request = MKDirectionsRequest()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        request.transportType = .walking
        
        let direction = MKDirections(request: request)
        direction.calculate { (response, error) in
            if let res = response {
                print(res.routes[0].polyline)
                completion(res.routes[0].polyline)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            var pr = MKPolylineRenderer(overlay: overlay)
            if overlay.subtitle! == "High" {
                let color = UIColor.init(red: 0.2, green: 0, blue: 0, alpha: 1)
                pr.strokeColor = color
                pr.lineWidth = 5
                return pr
            } else if overlay.subtitle! == "Low" {
                let color = UIColor.init(red: 0.8, green: 0, blue: 0, alpha: 1)
                pr.strokeColor = color
                pr.lineWidth = 5
                return pr
            }
            
        }
        return MKPolylineRenderer()
    }
    
    func addModelOverlay() {
        var coordinates = [CLLocationCoordinate2D]()
        let coordinate1 = CLLocationCoordinate2D(latitude: 42.047836408953017, longitude: -87.679421162142376)
        let coordinate2 = CLLocationCoordinate2D(latitude: 42.047458871232131, longitude: -87.677858397405913)
        coordinates = [coordinate1,coordinate2]
        let polyline = MKGeodesicPolyline(coordinates: coordinates, count: coordinates.count)
        
        mapView.add(polyline)
        
    }
    
    func drawRoads(road: String, location: CLLocationCoordinate2D) {
        //TODO: draw lines based on current road, location and next roads
        // next roads are in movementModel[road].keys
        if (movementModel != nil) {
            if let roadModel:[String:Float] = movementModel?[road] as! [String : Float]?{
                removeOverlays()

                for r in roadModel.keys {
                    print("road \(r): with \(roadModel[r]) chance")
                    //            var coordinates = [CLLocationCoordinate2D]()
                    //            coordinates.append(currentCoordinate)
                    let coordinate:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: coordinateTable![r]![0], longitude: coordinateTable![r]![1])
                    //            coordinates.append(coordinate)
                    
                    if (hitRoads?.keys.contains(r))! {
                        getDirection(coordinate: coordinate) { polyline in
                            //                        let polyline = MKGeodesicPolyline(coordinates: coordinates, count: coordinates.count)
                            polyline.title = r
                            if roadModel[r]! >= 0.4 {
                                polyline.subtitle = "High"
                            } else if roadModel[r]! < 0.4 {
                                polyline.subtitle = "Low"
                            }
                            self.mapView.add(polyline)
                        }
                    }
                }
            }
        }
    }
    
    func removeOverlays() {
        mapView.removeOverlays(mapView.overlays)
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

            
            let currentLocation = CLLocation(latitude: lat!, longitude: lng!)
            
            let currentCoordinate = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
            
            if let road_name:String = userInfo["road"] as? String {
                DispatchQueue.main.async(){
                    self.roadLabel.text = road_name
                }
                
                drawRoads(road: road_name, location: currentCoordinate)
            }

            if !setRegion {
                let coordinateRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate,
                                                                          regionRadius * 2.0, regionRadius * 2.0)
                mapView.setRegion(coordinateRegion, animated: false)
                setRegion = true
            }

            
        }

    }
}

