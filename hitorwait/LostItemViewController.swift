//
//  LostItemViewController.swift
//  hitorwait
//
//  Created by Yongsung on 2/5/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit

class LostItemViewController: UIViewController {
    
    var searchRegion: LostItemRegion? {
        didSet {
            requesterNameTextField.text = searchRegion?.requesterName
            itemTextField.text = searchRegion?.item
            itemDetailTextField.text = searchRegion?.itemDetail
        }
    }

    @IBOutlet weak var requesterNameTextField: UILabel!
    @IBOutlet weak var itemTextField: UILabel!
    @IBOutlet weak var itemDetailTextField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NotificationCenter.default
        Pretracker.sharedManager.locationManager?.requestLocation()
        
        getNearbySearchRegion()
        
        center.addObserver(forName: NSNotification.Name(rawValue: "textFieldUpdate"), object: nil, queue: OperationQueue.main, using: updateTextField)
        center.addObserver(forName: NSNotification.Name(rawValue: "SearchRegionUpdate"), object: nil, queue: OperationQueue.main, using: updateSearchRegion)
//        getItemDetails()
        
        //TODO: add an observer for search region changes from Pretracker.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getNearbySearchRegion()
    }
    
    func getNearbySearchRegion() {
        CommManager.instance.getRequest(route: "getNearbySearchRegion", parameters: ["lat":String(describing: Pretracker.sharedManager.currentLocation?.coordinate.latitude), "lon":String(describing: Pretracker.sharedManager.currentLocation?.coordinate.longitude)]) {
            json in
            print (json)
            
            // if there is no nearby search region with the item not found yet, server returns {"result":0}
            if json.index(forKey: "found") != nil {
                let loc = json["loc"] as! [String:Any]
                let coord = loc["coordinates"] as! [Double]
                let id = json["_id"] as! [String:Any]
                self.searchRegion = LostItemRegion(requesterName: json["user"] as! String, region: json["region"] as! String, item: json["item"] as! String, itemDetail: json["detail"] as! String, lat: coord[1], lon: coord[0], id: id["$oid"] as! String)
            }
        }
    }
    
    @IBAction func FoundItemButtonClicked(_ sender: UIButton) {
        print((CURRENT_USER?.username)!)
        //TODO: add item found.
        itemFound()
        
    }
    
    func itemFound() {
        let param = ["user":(CURRENT_USER?.username)!,"lat":String(describing: (Pretracker.sharedManager.currentLocation?.coordinate.latitude)!) ?? 0.0,"lon":String(describing: (Pretracker.sharedManager.currentLocation?.coordinate.longitude)!) ?? 0.0,"uid":searchRegion?.id ?? "","found":true] as [String : Any]
        CommManager.instance.urlRequest(route: "updateSearch", parameters: param, completion: {
            json in
            print("thanks")
        })
    }
    
    func itemNotFound() {
        let param = ["user":(CURRENT_USER?.username)!,"lat":String(describing: (Pretracker.sharedManager.currentLocation?.coordinate.latitude)!) ?? 0.0,"lon":String(describing: (Pretracker.sharedManager.currentLocation?.coordinate.longitude)!) ?? 0.0,"uid":searchRegion?.id ?? "","found":false] as [String : Any]
        CommManager.instance.urlRequest(route: "updateSearch", parameters: param, completion: {
            json in
            print("thanks anyway")
        })
    }
    
    @IBAction func didNotFindItemButtonClicked(_ sender: UIButton) {
        itemNotFound()
        //TODO: update search counts.
        CommManager.instance

//        print(Pretracker.sharedManager.currentLocation)
//        if let currentLocation = Pretracker.sharedManager.currentLocation {
//            //update searches
//            let config = URLSessionConfiguration.default
//            let session: URLSession = URLSession(configuration: config)
//            
//            //        let escapedAddress = search_region.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
//            //        print(escapedAddress)
//            
//            let lat = currentLocation.coordinate.latitude
//            let lon = currentLocation.coordinate.longitude
////            let url : String = "\(Config.URL)/updateSearch?lat=\(Double(lat))&lon=\(Double(lon))"
//            let url : String = "\(Config.URL)/updateSearch?uid=\(searchRegion.uid)&lat=\(Double(lat))&lon=\(Double(lon))"
//            let urlStr : String = url.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
//            let searchURL : URL = URL(string: urlStr as String)!
//            do {
//                let task = session.dataTask(with: searchURL, completionHandler: {
//                    (data, response, error) in
//                    if error != nil {
//                        print(error?.localizedDescription)
//                    }
//                    //                print(response)
//                    if data != nil {
//                        do {
//                            if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
//                                print(json)
////                                let nc = NotificationCenter.default
////                                let userInfo = ["requester": json["user"] as! String, "item": json["item"] as! String, "detail": json["detail"] as! String] as [String : Any]
////                                nc.post(name: NSNotification.Name(rawValue: "textFieldUpdate"), object: nil, userInfo: userInfo)
//                                //                                                        completion(json)
//                            }
//                        } catch let error as NSError {
//                            print(error)
//                        }
//                    }
//                })
//                task.resume()
//                
//            } catch let error as NSError{
//                print(error)
//            }
//        }

    }
    
    func updateSearchRegion(notification: Notification) -> Void {
        if let userInfo = notification.userInfo {
            searchRegion = userInfo["searchRegion"] as! LostItemRegion
            
        }
    }
    
    func updateTextField(notification: Notification) -> Void {
        if let userInfo = notification.userInfo {
            requesterNameTextField.text = userInfo["requester"] as? String
            itemTextField.text = userInfo["item"] as? String
            itemDetailTextField.text = userInfo["detail"] as? String
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    func getItemDetails() {
//        let config = URLSessionConfiguration.default
//        let session: URLSession = URLSession(configuration: config)
//        
////        let escapedAddress = search_region.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
////        print(escapedAddress)
//        
//        let url : String = "\(Config.URL)/getRegions/\(searchRegion.region)"
//        let urlStr : String = url.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
//        let searchURL : URL = URL(string: urlStr as String)!
//        
//        do {
//            let task = session.dataTask(with: searchURL, completionHandler: {
//                (data, response, error) in
//                if error != nil {
//                    print(error?.localizedDescription)
//                }
//                //                print(response)
//                if data != nil {
//                    do {
//                        if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
//                            print(json)
//                            let nc = NotificationCenter.default
//                            let userInfo = ["requester": json["user"] as! String, "item": json["item"] as! String, "detail": json["detail"] as! String] as [String : Any]
//                            nc.post(name: NSNotification.Name(rawValue: "textFieldUpdate"), object: nil, userInfo: userInfo)
////                                                        completion(json)
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

    /*
     given a street, we should be able to retur
     */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
