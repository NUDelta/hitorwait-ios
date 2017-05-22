//
//  LostItemRegion.swift
//  hitorwait
//
//  Created by Yongsung on 2/7/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit

class LostItemRegion: NSObject {
    let item: String
    let itemDetail: String
    var nearybyRoads: [String:Any]?
    let requesterName:String
    let lat: Double
    let lon: Double
    let id: String
    
    init(requesterName: String, item: String, itemDetail: String, lat: Double, lon: Double, id: String) {
        self.requesterName = requesterName
        self.item = item
        self.itemDetail = itemDetail
        self.id = id
        self.lat = lat
        self.lon = lon
    }
}
