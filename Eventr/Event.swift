//
//  Event.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/26/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation

class Event {
    
    
    var name: String
    var address: String
    var details: String
    var contact: String
    var ticketURL: String = ""
    var eventURL: String = ""
    var tags: String = ""
    var favorite: Bool = false
    var paid: Bool = false
    var upvoteCount: Int = 0
    
    
    init(name: String, address: String, details: String, contact: String, ticketURL: String, eventURL: String, tags: String) {
        self.name = name
        self.address = address
        self.details = details
        self.contact = contact
        self.ticketURL = ticketURL
        self.eventURL = eventURL
        self.tags = tags
    }
    
    func upvote(){
        upvoteCount += 1
    }
    
    func markFavorite(){
        favorite = !favorite
    }
    
}
