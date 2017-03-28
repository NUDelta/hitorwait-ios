//
//  tabBarViewController.swift
//  hitorwait
//
//  Created by Yongsung on 3/28/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit

var CURRENT_USER:User?

class tabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        CURRENT_USER = User(username: defaults.value(forKey: "username") as! String, tokenId: defaults.value(forKey: "tokenId") as! String)
        // Do any additional setup after loading the view.
    }

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
