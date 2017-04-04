//
//  SettingsViewController.swift
//  hitorwait
//
//  Created by Yongsung on 3/28/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var movementModelControl: UISegmentedControl!
    @IBOutlet weak var headingSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        headingSwitch.setOn(false, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func movementModelControl(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
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
