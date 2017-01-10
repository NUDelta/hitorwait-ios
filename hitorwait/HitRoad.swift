//
//  HitRoad.swift
//  hitorwait
//
//  Created by Yongsung on 1/5/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit
import MapKit

class HitRoad: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    init (_ title: String, coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.title = title
        super.init()
    }
}
