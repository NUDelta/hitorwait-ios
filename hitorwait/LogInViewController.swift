//
//  LogInViewController.swift
//  hitorwait
//
//  Created by Yongsung on 2/5/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    @IBOutlet weak var userNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        var itemRegion = LostItemRegion()
        //42.047409, -87.679081
        itemRegion.getLostItemRegion(42.077902,87.691171) { completed in
            if completed {
                print(itemRegion.requester)
            } else {
                print("no result")
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         Get the new view controller using segue.destinationViewController.
//         Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
                case "Login Segue":
                    if let vc = segue.destination  as? ViewController {
                        vc.userName = userNameTextField.text
                        let defaults = UserDefaults.standard
                        defaults.set(userNameTextField.text,forKey: "username")
                }
                default: break
            }
        }
    }
}
