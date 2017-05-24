//
//  ESMModalViewController.swift
//  hitorwait
//
//  Created by Yongsung on 5/21/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit

class ESMModalViewController: UIViewController {

    var rating = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        greetingsLabel.text = "Hi \((CURRENT_USER?.username)!)"
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var answerLabel: UILabel!
    
    @IBOutlet weak var greetingsLabel: UILabel!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let lat = Pretracker.sharedManager.currentLocation?.coordinate.latitude ?? 0.0
        let lon = Pretracker.sharedManager.currentLocation?.coordinate.longitude ?? 0.0
        if lat != 0.0 {
            let params = ["view":"esmView","user":(CURRENT_USER?.username)! ?? "","time":Date().timeIntervalSince1970,"lat":String(describing: lat),"lon":String(describing: lon)] as [String: Any]
            CommManager.instance.urlRequest(route: "appActivity", parameters: params, completion: {
                json in
                print (json)
                // if there is no nearby search region with the item not found yet, server returns {"result":0}
            })
        }
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        submitRating()
        dismiss(animated: false) { 
            let nc = NotificationCenter.default
            nc.post(name: NSNotification.Name(rawValue: "ESMSent"), object: nil, userInfo: nil)
        }
    }
    
    func submitRating() {
        let lat = Pretracker.sharedManager.currentLocation?.coordinate.latitude ?? 0.0
        let lon = Pretracker.sharedManager.currentLocation?.coordinate.longitude ?? 0.0
        if lat != 0.0 {
            
            let params = ["view":"esmView","user":(CURRENT_USER?.username)! ?? "","time":Date().timeIntervalSince1970, "rating":rating,"lat":String(describing: lat),"lon":String(describing: lon)] as [String: Any]
            
            CommManager.instance.urlRequest(route: "esm", parameters: params, completion: {
                json in
                print("thanks")
            })
        }
    }

    @IBAction func valueChange(_ sender: UISlider) {
        var interval = 1
        var answerValue = Int(sender.value / Float(interval) ) * interval
        rating = answerValue
        sender.value = Float(answerValue) // remove this if you don't want discrete slider.
        switch sender.value {
        case 1:
            answerLabel.text = "Not at all disruptive"
        case 2:
            answerLabel.text = "Slightly disruptive"
        case 3:
            answerLabel.text = "Moderately disruptive"
        case 4:
            answerLabel.text = "Disruptive"
        case 5:
            answerLabel.text = "Very disruptive"
        default:
            answerLabel.text = "Not at all disruptive"
        }
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
