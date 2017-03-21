//
//  LostItemRegion.swift
//  hitorwait
//
//  Created by Yongsung on 2/7/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit

class LostItemRegion: NSObject {
    public var region:String = ""
    public var item: String = ""
    public var itemDetails: String = ""
    public var nearybyRoads: [String:Any] = [String:Any]()
    public var requester:String = ""
    public var lat: Double = 0.0
    public var lon: Double = 0.0
    public var uid: String = ""
    
    override init(){
        super.init()
    }
    
    public func getLostItemRegion(_ lat: Double,_ lon: Double, completion: @escaping (Bool)->()) {
        let config = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: config)
        let url = URL(string: "\(Config.URL)/getNearbySearchRegion?lat=\(lat)&lon=\(lon)")!
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                        print(json)
                        if let no_result = json["result"]{
                            completion(false)
                        } else {
                            self.requester = (json["user"]! as? String)!
                            self.item = (json["item"]! as? String)!
                            let nearby = json["nearby_regions"]! as! [String: Any]
                            self.nearybyRoads = nearby
                            //                        self.nearybyRoads = (json["nearyby_regions"]! as? [Any])!
                            self.itemDetails = (json["detail"]! as? String)!
                            let loc = json["loc"] as! [String:Any]
                            let coordinates = loc["coordinates"] as! [Double]
                            self.lat = coordinates[1]
                            self.lon = coordinates[0]
                            let id_array = json["_id"] as? [String: String]
                            self.uid = (id_array?["$oid"])!
                            completion(true)
                        }

                    }
                } catch {
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
}
