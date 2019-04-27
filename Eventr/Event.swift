//
//  Event.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/26/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation

class Event : CustomStringConvertible {
    
    var description: String
    var name: String
    var address: String
    var details: String
    
    
    init(name: String, address: String, details: String) {
        self.name = name
        self.address = address
        self.description = name
        self.details = details
    }
    
}
