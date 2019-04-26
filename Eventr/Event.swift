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
    
    
    init(name: String) {
        self.name = name
        self.description = name
    }
    
}
