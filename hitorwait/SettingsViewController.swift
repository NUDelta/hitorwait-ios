//
//  SettingsViewController.swift
//  hitorwait
//
//  Created by Yongsung on 3/28/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    var searchCount = ""
    @IBOutlet weak var searchCountLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameLabel.text = CURRENT_USER?.username
        searchCountLabel.text = "0"
//        let center = NotificationCenter.default
//        center.addObserver(forName: NSNotification.Name(rawValue: "updatedDetail"), object: nil, queue: OperationQueue.main, using: updateFields)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let params = ["view":"profileView","user":(CURRENT_USER?.username)! ?? "","time":Date().timeIntervalSince1970] as [String: Any]
        CommManager.instance.urlRequest(route: "appActivity", parameters: params, completion: {
            json in
            print (json)
            // if there is no nearby search region with the item not found yet, server returns {"result":0}
        })
        getUserInfo()
    }
    
    func getUserInfo() {
        CommManager.instance.getRequest(route: "getUser", parameters: ["user":CURRENT_USER?.username ?? ""]) {
            json in
            print (json)
            // if there is no nearby search region with the item not found yet, server returns {"result":0}
            if json.index(forKey: "searches") != nil {
                if let searches = json["searches"] as? Int!{
                    self.searchCountLabel.text = String(searches!)
                }
                
            }
        }

    }
    
//    func updateFields(notification: Notification) -> Void {
//        self.searchCountLabel.text = searchCount
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
