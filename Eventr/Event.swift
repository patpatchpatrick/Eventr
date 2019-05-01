//
//  Event.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/26/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation

class Event {
    
    
    var name: String = ""
    var id: String = ""
    var category: EventCategory = EventCategory(category: .misc)
    var address: String = ""
    var details: String = ""
    var contact: String = ""
    var ticketURL: String = ""
    var eventURL: String = ""
    var tags: String = ""
    var favorite: Bool = false
    var paid: Bool = false
    var upvoteCount: Int = 0
    
    
    init(name: String, category: EventCategory, address: String, details: String, contact: String, ticketURL: String, eventURL: String, tags: String, paid: Bool) {
        self.name = name
        self.address = address
        self.details = details
        self.contact = contact
        self.ticketURL = ticketURL
        self.eventURL = eventURL
        self.tags = tags
        self.category = category
        self.paid = paid
    }
    
    //Initialize an event from a dictionary retreived from Firebase
    init(dict: NSDictionary, idKey: String){
        if dict["name"] != nil {
            self.name = dict.value(forKey: "name") as! String
        }
        self.id = idKey
        if dict["category"] != nil {
            let categoryString = dict.value(forKey: "category") as! String
            self.category = stringToEventCategory(string: categoryString)
        }
        if dict["location"] != nil {
            self.address = dict.value(forKey: "location") as! String
        }
        if dict["description"] != nil {
            self.details = dict.value(forKey: "description") as! String
        }
        if dict["ticketURL"] != nil {
            self.ticketURL = dict.value(forKey: "ticketURL") as! String
        }
        if dict["eventURL"] != nil {
            self.eventURL = dict.value(forKey: "eventURL") as! String
        }
        if dict["contact"] != nil {
             self.contact = dict.value(forKey: "contact") as! String
        }
        if dict["tags"] != nil {
            self.tags = dict.value(forKey: "tags") as! String
        }
        if dict["upvotes"] != nil {
            let stringUpvoteCount = dict.value(forKey: "upvotes") as! String
            self.upvoteCount = Int(stringUpvoteCount)!
        }
        if dict["paid"] != nil {
            let stringPaid = dict.value(forKey: "paid") as! String
            self.paid = (stringPaid == "1") ? true : false
        }
    }
    
    func upvote(){
        //Upvote the event.  Increase the count by 1 in Firebase.
        upvoteCount += 1
        upvoteFirebaseEvent(event: self)
    }
    
    func markFavorite(){
        favorite = !favorite
    }
    
}
