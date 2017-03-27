//
//  CommManager.swift
//  hitorwait
//
//  Created by Yongsung on 3/26/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit
import Foundation

class CommManager: NSObject {
    let config:URLSessionConfiguration
    let session: URLSession
    let url: String
    
    public static let instance = CommManager()
    
    private override init() {
        self.config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config)
        self.url = Config.URL
    }
    
//    func urlRequest(route: String, parameters: [String: Any]? = nil, completion: @escaping ([String:Any])->()) {
//        var request = URLRequest(url: URL(string: "\(API_ADDR)/\(route)")!)
//        
//        // GET, POST
//        request.httpMethod = "POST"
//        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//        
//        let json = parameters!
//        print(json)
//        
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
//            request.httpBody = jsonData
//            
//            let task = session.dataTask(with: request, completionHandler: {
//                (data, response, error) in
//                if error != nil {
//                    print(error?.localizedDescription)
//                }
//                if data != nil {
//                    do {
//                        if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
//                            print(json)
//                            completion(json)
//                        }
//                    } catch {
//                        print("serialization error")
//                    }
//                }
//            })
//            task.resume()
//            
//        } catch let error as NSError {
//            //TODO: wherever there is an error, log it to the server.
//            print(error)
//        }
//    }
    
    func urlRequest(route: String, parameters: [String: Any]? = nil, completion: @escaping ([String:Any])->()) {
        var request = URLRequest(url: URL(string: "\(API_ADDR)/\(route)")!)
        
        // GET, POST
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        let json = parameters!
        print(json)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            request.httpBody = jsonData
            
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                if data != nil {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                            print(json)
                            completion(json)
                        }
                    } catch {
                        print("serialization error")
                    }
                }
            })
            task.resume()
            
        } catch let error as NSError {
            //TODO: wherever there is an error, log it to the server.
            print(error)
        }
    }
    
}

