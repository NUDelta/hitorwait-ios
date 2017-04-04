//
//  LostItemViewController.swift
//  hitorwait
//
//  Created by Yongsung on 2/5/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit

class LostItemViewController: UIViewController {
    
    var searchRegion: LostItemRegion?
//    {
//        didSet {
//            requesterNameTextField.text = searchRegion?.requesterName
//            itemTextField.text = searchRegion?.item
//            itemDetailTextField.text = searchRegion?.itemDetail
//        }
//    }

    @IBOutlet weak var requesterNameTextField: UILabel!
    @IBOutlet weak var itemTextField: UILabel!
    @IBOutlet weak var itemDetailTextField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NotificationCenter.default
        Pretracker.sharedManager.locationManager?.requestLocation()
        
        getNearbySearchRegion()
        
//        center.addObserver(forName: NSNotification.Name(rawValue: "textFieldUpdate"), object: nil, queue: OperationQueue.main, using: updateTextField)
//        center.addObserver(forName: NSNotification.Name(rawValue: "SearchRegionUpdate"), object: nil, queue: OperationQueue.main, using: updateSearchRegion)
        center.addObserver(forName: NSNotification.Name(rawValue: "updatedDetail"), object: nil, queue: OperationQueue.main, using: updateFields)
//        getItemDetails()
        
        //TODO: add an observer for search region changes from Pretracker.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getNearbySearchRegion()
    }
    
    func getNearbySearchRegion() {
        let defaults = UserDefaults.standard
        let nc = NotificationCenter.default

        if let regionId = defaults.value(forKey: "regionId") as? String {
            CommManager.instance.getRequest(route: "getNearbySearchRegion", parameters: ["lat":String(describing: Pretracker.sharedManager.currentLocation?.coordinate.latitude), "lon":String(describing: Pretracker.sharedManager.currentLocation?.coordinate.longitude)]) {
                json in
                print (json)
                // if there is no nearby search region with the item not found yet, server returns {"result":0}
                if json.index(forKey: "found") != nil {
                    let loc = json["loc"] as! [String:Any]
                    let coord = loc["coordinates"] as! [Double]
                    let id = json["_id"] as! [String:Any]
                    if regionId == id["$oid"] as! String {
                        self.searchRegion = LostItemRegion(requesterName: json["user"] as! String, region: json["region"] as! String, item: json["item"] as! String, itemDetail: json["detail"] as! String, lat: coord[1], lon: coord[0], id: regionId)
                        nc.post(name: NSNotification.Name(rawValue: "updatedDetail"), object: nil, userInfo:nil)
                    }
                }
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
    }
    
    func updateFields(notification: Notification) -> Void {
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
