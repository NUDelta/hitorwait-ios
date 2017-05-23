//
//  LostItemViewController.swift
//  hitorwait
//
//  Created by Yongsung on 2/5/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit

class LostItemViewController: UIViewController {
    var hasInfo:Bool = false
    var searchRegion: LostItemRegion?
//    {
//        didSet {
//            requesterNameTextField.text = searchRegion?.requesterName
//            itemTextField.text = searchRegion?.item
//            itemDetailTextField.text = searchRegion?.itemDetail
//        }
//    }
    let center = NotificationCenter.default
    let defaults = UserDefaults.standard

    @IBOutlet weak var requesterNameTextField: UILabel!
    @IBOutlet weak var itemTextField: UILabel!
    @IBOutlet weak var itemDetailTextField: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        center.addObserver(forName: NSNotification.Name(rawValue: "textFieldUpdate"), object: nil, queue: OperationQueue.main, using: updateTextField)
//        center.addObserver(forName: NSNotification.Name(rawValue: "SearchRegionUpdate"), object: nil, queue: OperationQueue.main, using: updateSearchRegion)
        center.addObserver(forName: NSNotification.Name(rawValue: "updatedDetail"), object: nil, queue: OperationQueue.main, using: updateFields)
        center.addObserver(forName: Notification.Name(rawValue:"PushReceived"), object: nil, queue: OperationQueue.main, using: pushReceived)
//        getItemDetails()
        
        //TODO: add an observer for search region changes from Pretracker.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Pretracker.sharedManager.locationManager?.requestLocation()
        getNearbySearchRegion()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let params = ["view":"lostItemView","user":(CURRENT_USER?.username)! ?? "","time":Date().timeIntervalSince1970] as [String: Any]
        CommManager.instance.urlRequest(route: "appActivity", parameters: params, completion: {
            json in
            print (json)
            // if there is no nearby search region with the item not found yet, server returns {"result":0}
        })
    }
    
    func getNearbySearchRegion() {
//        if let regionId = defaults.value(forKey: "regionId") as? String {
        let lat = Pretracker.sharedManager.currentLocation?.coordinate.latitude ?? 0.0
        let lon = Pretracker.sharedManager.currentLocation?.coordinate.longitude ?? 0.0
        CommManager.instance.getRequest(route: "getNearbySearchRegion", parameters: ["lat":String(describing: lat), "lon":String(describing: lon)]) {
            json in
            print (json)
            // if there is no nearby search region with the item not found yet, server returns {"result":0}
            if json.index(forKey: "found") != nil {
                let loc = json["loc"] as! [String:Any]
                let coord = loc["coordinates"] as! [Double]
                let id = json["_id"] as! [String:Any]
//                    if regionId == id["$oid"] as! String {
                self.searchRegion = LostItemRegion(requesterName: json["user"] as! String, item: json["item"] as! String, itemDetail: json["detail"] as! String, lat: coord[1], lon: coord[0], id: id["$oid"] as! String)
                self.center.post(name: NSNotification.Name(rawValue: "updatedDetail"), object: nil, userInfo:nil)
//                    }
            }
        }
//        }

    }
    
    func getRegionWithId() {
        if let regionId = defaults.value(forKey: "regionId") as? String {
            CommManager.instance.getRequest(route: "getRegionWithId", parameters: ["region_id":regionId]) {
                json in
                print (json)
                // if there is no nearby search region with the item not found yet, server returns {"result":0}
                if json.index(forKey: "found") != nil {
                    let loc = json["loc"] as! [String:Any]
                    let coord = loc["coordinates"] as! [Double]
                    let id = json["_id"] as! [String:Any]
                    if regionId == id["$oid"] as! String {
                        self.searchRegion = LostItemRegion(requesterName: json["user"] as! String, item: json["item"] as! String, itemDetail: json["detail"] as! String, lat: coord[1], lon: coord[0], id: id["$oid"] as! String)
                        self.center.post(name: NSNotification.Name(rawValue: "updatedDetail"), object: nil, userInfo:nil)
                    }
                }
            }
        }
        
    }
    
    @IBAction func FoundItemButtonClicked(_ sender: UIButton) {
        print((CURRENT_USER?.username)!)
        //TODO: add item found.
//        itemFound()
        if self.hasInfo {
            itemFound()
            performSegue(withIdentifier:"ESM View", sender: self)
        }
    }
    
    func itemFound() {
//        let alert = UIAlertController(title: "Thank you!", message: "Thank you for finding the item!", preferredStyle: UIAlertControllerStyle.alert)
//        let okAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default) {
//            act in
//            print("ok")
//        }
//        
//        alert.addAction(okAction)
//        self.present(alert, animated: true, completion: nil)
        
        let defaults = UserDefaults.standard

        let param = ["user":(CURRENT_USER?.username)!,"lat":String(describing: (Pretracker.sharedManager.currentLocation?.coordinate.latitude)!) ?? 0.0,"lon":String(describing: (Pretracker.sharedManager.currentLocation?.coordinate.longitude)!) ?? 0.0,"uid":searchRegion?.id ?? "","decision_activity_id": defaults.value(forKey: "decision_activity_id") ?? "", "search_road": defaults.value(forKey: "search_road") ?? "", "found":true, "date":Date().timeIntervalSince1970] as [String : Any]
        CommManager.instance.urlRequest(route: "updateSearch", parameters: param, completion: {
            json in
            print("thanks")
        })
    }
    
    func itemNotFound() {
//        let alert = UIAlertController(title: "Thank you!", message: "Thank you for looking for the item!", preferredStyle: UIAlertControllerStyle.alert)
//        let okAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default) {
//            act in
//            print("ok")
//        }
//        alert.addAction(okAction)
//
//        self.present(alert, animated: true, completion: nil)

        let defaults = UserDefaults.standard
        
        let param = ["user":(CURRENT_USER?.username)!,"lat":String(describing: (Pretracker.sharedManager.currentLocation?.coordinate.latitude)!) ?? 0.0,"lon":String(describing: (Pretracker.sharedManager.currentLocation?.coordinate.longitude)!) ?? 0.0,"uid":searchRegion?.id ?? "", "decision_activity_id": defaults.value(forKey: "decision_activity_id") ?? "", "search_road": defaults.value(forKey: "search_road") ?? "", "found":false,"date":Date().timeIntervalSince1970] as [String : Any]
        CommManager.instance.urlRequest(route: "updateSearch", parameters: param, completion: {
            json in
            print("thanks anyway")
        })
    }
    
    @IBAction func didNotFindItemButtonClicked(_ sender: UIButton) {
        if self.hasInfo {
            itemNotFound()
            performSegue(withIdentifier:"ESM View", sender: self)
        }
        //TODO: update search counts.
    }
    
    func pushReceived(notification: Notification) -> Void {
        self.hasInfo = true
        getRegionWithId()
    }
    
    func updateFields(notification: Notification) -> Void {
        self.hasInfo = true
        requesterNameTextField.text = searchRegion?.requesterName
        itemTextField.text = searchRegion?.item
        itemDetailTextField.text = searchRegion?.itemDetail
    }
    
//    func updateTextField(notification: Notification) -> Void {
//        if let userInfo = notification.userInfo {
//            requesterNameTextField.text = userInfo["requester"] as? String
//            itemTextField.text = userInfo["item"] as? String
//            itemDetailTextField.text = userInfo["detail"] as? String
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
