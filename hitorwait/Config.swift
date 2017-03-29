//
//  Config.swift
//  hitorwait
//
//  Created by Yongsung on 3/21/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit

struct Config {
    static let DEBUG = true
    static var URL = ""
    public static let sharedConfig = Config()

    init() {
        if Config.DEBUG {
            Config.URL = "http://10.105.157.241:5000"
        } else {
            Config.URL = "http://hitorwait.herokuapp.com"
        }
    }
}
