//
//  User.swift
//  hitorwait
//
//  Created by Yongsung on 12/19/16.
//  Copyright © 2016 Delta. All rights reserved.
//

import UIKit

class User: NSObject {
    let username: String
    let tokenId: String
    var location: Location?
    var hasDecision: Bool?
    
    init(username: String, tokenId: String) {
        self.username = username
        self.tokenId = tokenId
    }
}
