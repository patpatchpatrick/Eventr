//
//  Friend.swift
//  Eventr
//
//  Created by Patrick Doyle on 6/11/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation

let FRIEND_REQUEST_NOT_APPROVED = 0
let FRIEND_REQUEST_APPROVED = 1

enum friendStatus {
    case requested
    case connected
    case notconnected
}

class Friend {
    
    var name: String = ""
    var userID: String = ""
    var status: friendStatus = .notconnected
    
    init(name: String, userID: String){
        self.name = name
        self.userID = userID
    }
    
}
