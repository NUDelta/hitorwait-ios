//
//  RequestViewController.swift
//  hitorwait
//
//  Created by Yongsung on 2/15/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit
import MapKit

class RequestViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate{

    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var itemDetailTextField: UITextField!
    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var lonTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var lostItemCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemTextField.delegate = self
        itemDetailTextField.delegate = self
        
        //initializing annonation and map
        dropPins()
        mapViewSetup()
        // Do any additional setup after loading the view.
    }
    
    
    // ways to make keyboard disappear.
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapViewSetup() {
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        var center = CLLocationCoordinate2D()
        center.latitude = 42.056929
        center.longitude = -87.676519
        let region = MKCoordinateRegionMakeWithDistance (center, 1000, 1000)
        self.mapView.setRegion(region, animated: false)
    }
   
    @IBAction func requestButtonClick(_ sender: UIButton) {
        let params = ["user":(CURRENT_USER?.username)!, "item": (itemTextField.text)! ?? "", "detail": (itemDetailTextField.text)! ?? "", "lat":(lostItemCoordinate?.latitude)! ?? 0.0, "lon":(lostItemCoordinate?.longitude)! ?? 0.0] as [String : Any]
        
        CommManager.instance.urlRequest(route: "regions", parameters: params){
            json in
            print(json)
        }
        print("requested")
    }
     /*
        let config = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: config)
        var request = URLRequest(url: URL(string: "\(Config.URL)/regions")!)
        
        request.httpMethod = "POST"
        print(username)
        let json = ["user":username,"item":itemTextField.text ?? "", "detail":itemDetailTextField.text ?? "", "lat": latTextField.text ?? "", "lng": lonTextField.text ?? ""] as [String : Any]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                print(response)
            })
            task.resume()
            
        } catch let error as NSError {
            //TODO: wherever there is an error, log it to the server.
            print(error)
        }
    }
    */
    
    func dropPins() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.1
        self.mapView.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongPress(gesture: UIGestureRecognizer) {
        if (gesture.state != UIGestureRecognizerState.began) {
            return
        }
        
        let touchPoint: CGPoint = gesture.location(in: mapView)
        let touchMapCoordinate: CLLocationCoordinate2D = self.mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        self.lostItemCoordinate = touchMapCoordinate
        
        let point: MKPointAnnotation = MKPointAnnotation()
        point.title = "Lost item location"
        point.coordinate = touchMapCoordinate
        mapView.removeAnnotations(self.mapView.annotations)
        mapView.addAnnotation(point)
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
