//
//  User.swift
//  hitorwait
//
//  Created by Yongsung on 12/19/16.
//  Copyright © 2016 Delta. All rights reserved.
//

import UIKit

class User: NSObject, URLSessionTaskDelegate {

    var userName: String = "yk"
    
    func getUser(_ userId: String, completion: @escaping ([String:Any]) -> ()){
        let config = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: config)
        let url = URL(string: "\(Config.URL)/routes/\(userId)")!
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in
            if error != nil {
                print(error?.localizedDescription as Any)
            } else {
//                if data != nil {
//                    completion(data)
//                }
                do {
//                    print(data as Any)
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
//                        print(json)
                        completion(json)
                    }
                } catch {
                    print("error in JSONSerialization")
                }
            }
        })
        task.resume()
    }
    
}
