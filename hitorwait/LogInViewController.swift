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
    var uuid = UUID().uuidString
    override func viewDidLoad() {
        super.viewDidLoad()
        uuid = uuid.replacingOccurrences(of: "-", with: "")
//        userNameTextField.text = uuid
//        var itemRegion = LostItemRegion()
//        //42.047409, -87.679081
//        itemRegion.getLostItemRegion(42.077902,87.691171) { completed in
//            if completed {
//                print(itemRegion.requester)
//            } else {
//                print("no result")
//            }
//        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func postUserInfo(_ username:String, _ tokenId: String) {
        let config = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: config)
        
        let url : String = "\(Config.URL)/user?username=\(username)&tokenId=\(tokenId)"
        let urlStr : String = url.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!
        let searchURL : URL = URL(string: urlStr as String)!
        do {
            let task = session.dataTask(with: searchURL, completionHandler: {
                (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                if data != nil {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                            print(json)
                            CURRENT_USER = User(username: username, tokenId: tokenId)
                        }
                    } catch let error as NSError {
                        print(error)
                    }
                }
            })
            task.resume()
            
        } catch let error as NSError{
            print(error)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//         Get the new view controller using segue.destinationViewController.
//         Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
                case "Login Segue":
//                    if let vc = segue.destination  as? ViewController {
//                        vc.userName = userNameTextField.text
//                        let defaults = UserDefaults.standard
//                        defaults.set(userNameTextField.text,forKey: "username")
//                        let username = (defaults.value(forKey: "username") as? String)!
//                        print(username)
//                     }
                    if let username = userNameTextField.text {
                        let defaults = UserDefaults.standard
                        defaults.set(uuid,forKey: "username")
                        print(uuid)
                        let tokenId:String = defaults.value(forKey: "tokenId") as! String
                        postUserInfo(uuid, tokenId)
                    }
            
                default: break
            }
        }
    }
}
