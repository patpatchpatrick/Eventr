//
//  EventSnippet.swift
//  Eventr
//
//  Created by Patrick Doyle on 6/19/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation


//Event Snippets are created to show pieces of the event data
//These are used to populate the list of events that friends are attending
class EventSnippet : Comparable {
    
    var name: String = ""
    var id: String = ""
    var category: EventCategory = EventCategory(category: .misc)
    var GMTDate: Date? // Event date in GMT timezone
    var duration = 0 // Event duration in minutes
    var dateWithDurationAdded: Date = Date()
    var city: String = ""
    var paid: Bool = false
    var price: String = ""
    
    static func < (lhs: EventSnippet, rhs: EventSnippet) -> Bool {
        print("ADD COMPARABLE CODE")
        return true
    }
    
    static func == (lhs: EventSnippet, rhs: EventSnippet) -> Bool {
        print("ADD COMPARABLE CODE")
        return true
    }

    
    
    

}
