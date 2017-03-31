//
//  ViewController.swift
//  MAC
//
//  Created by Yongsung on 3/31/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import Cocoa
import MapKit

class ViewController: NSViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleTextField: NSTextField!
    let regionRadius: CLLocationDistance = 500

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mapView.delegate = self

        let initialLocation = CLLocation(latitude: 42.060126, longitude: -87.674241)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(initialLocation.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: false)
        mapView.showsUserLocation = true
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

