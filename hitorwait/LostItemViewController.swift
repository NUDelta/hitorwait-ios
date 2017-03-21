//
//  LostItemViewController.swift
//  hitorwait
//
//  Created by Yongsung on 2/5/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit

class LostItemViewController: UIViewController {
    
    var searchRegion: LostItemRegion = LostItemRegion() {
        didSet {
            
//            getItemDetails()
            requesterNameTextField.text = searchRegion.requester
            itemTextField.text = searchRegion.item
            itemDetailTextField.text = searchRegion.itemDetails
        }
    }


    @IBOutlet weak var requesterNameTextField: UILabel!
    @IBOutlet weak var itemTextField: UILabel!
    @IBOutlet weak var itemDetailTextField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let center = NotificationCenter.default
        Pretracker.sharedManager
        
        center.addObserver(forName: NSNotification.Name(rawValue: "textFieldUpdate"), object: nil, queue: OperationQueue.main, using: updateTextField)
        center.addObserver(forName: NSNotification.Name(rawValue: "SearchRegionUpdate"), object: nil, queue: OperationQueue.main, using: updateSearchRegion)
//        getItemDetails()
        
        //TODO: add an observer for search region changes from Pretracker.
        
    }
    
    @IBAction func FoundItemButtonClicked(_ sender: UIButton) {
        
    }
    
    @IBAction func didNotFindItemButtonClicked(_ sender: UIButton) {
//        print(Pretracker.sharedManager.currentLocation)
        if let currentLocation = Pretracker.sharedManager.currentLocation {
            //update searches
            let config = URLSessionConfiguration.default
            let session: URLSession = URLSession(configuration: config)
            
            //        let escapedAddress = search_region.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
            //        print(escapedAddress)
            
            let lat = currentLocation.coordinate.latitude
            let lon = currentLocation.coordinate.longitude
//            let url : String = "http://127.0.0.1:5000/updateSearch?lat=\(Double(lat))&lon=\(Double(lon))"
            let url : String = "\(Config.URL)/updateSearch?uid=\(searchRegion.uid)&lat=\(Double(lat))&lon=\(Double(lon))"
            let urlStr : String = url.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
            let searchURL : URL = URL(string: urlStr as String)!
            do {
                let task = session.dataTask(with: searchURL, completionHandler: {
                    (data, response, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                    //                print(response)
                    if data != nil {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                                print(json)
//                                let nc = NotificationCenter.default
//                                let userInfo = ["requester": json["user"] as! String, "item": json["item"] as! String, "detail": json["detail"] as! String] as [String : Any]
//                                nc.post(name: NSNotification.Name(rawValue: "textFieldUpdate"), object: nil, userInfo: userInfo)
                                //                                                        completion(json)
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
    func getItemDetails() {
        let config = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: config)
        
//        let escapedAddress = search_region.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
//        print(escapedAddress)
        
        let url : String = "\(Config.URL)/getRegions/\(searchRegion.region)"
        let urlStr : String = url.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
        let searchURL : URL = URL(string: urlStr as String)!
        
        do {
            let task = session.dataTask(with: searchURL, completionHandler: {
                (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                //                print(response)
                if data != nil {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                            print(json)
                            let nc = NotificationCenter.default
                            let userInfo = ["requester": json["user"] as! String, "item": json["item"] as! String, "detail": json["detail"] as! String] as [String : Any]
                            nc.post(name: NSNotification.Name(rawValue: "textFieldUpdate"), object: nil, userInfo: userInfo)
//                                                        completion(json)
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
