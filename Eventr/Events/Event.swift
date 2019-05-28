//
//  Event.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/26/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import Firebase

class Event : Comparable {

    var name: String = ""
    var id: String = ""
    var category: EventCategory = EventCategory(category: .misc)
    var GMTDate: Date? // Event date in GMT timezone
    var previousDate: Date = Date() // Variable to store previous date if date was updated
    var city: String = ""
    var location: String = ""
    var venue: String = ""
    var details: String = ""
    var contact: String = ""
    var phoneNumber: String = ""
    var ticketURL: String = ""
    var eventURL: String = ""
    var tag1: String = ""
    var tag2: String = ""
    var tag3: String = ""
    var favorite: Bool = false
    var paid: Bool = false
    var upvoteCount: Int = 0
    var upvoted: Bool = false
    var userCount = 0 //count of users who are attending the event
    
    
    var loggedInUserCreatedTheEvent: Bool = false //Bool to determine if it was a user-created event
    var loggedInUserAttendingTheEvent: Bool = false //Bool to track if user is attending the event
    
    init(name: String, category: EventCategory, date: Date, city: String, address: String, venue: String, details: String, contact: String, phoneNumber: String, ticketURL: String, eventURL: String, tag1: String, tag2: String, tag3: String, paid: Bool) {
        self.name = name
        self.city = city
        self.location = address
        self.venue = venue
        self.GMTDate = date
        self.details = details
        self.contact = contact
        self.phoneNumber = phoneNumber
        self.ticketURL = ticketURL
        self.eventURL = eventURL
        self.tag1 = tag1
        self.tag2 = tag2
        self.tag3 = tag3
        self.category = category
        self.paid = paid
    }
    
    //Initialize an event from a dictionary retreived from Firebase
    init(dict: NSDictionary, idKey: String){
        if let nameDict = dict["name"] as? String {
            self.name = nameDict
        }
        self.id = idKey
        if let categoryString = dict["category"] as? String {
            self.category = stringToEventCategory(string: categoryString)
        }
        if let dateString = dict["date"] as? String {
            if let dateDouble = Double(dateString) {
                //Date is stored in Firebase in GMT time (unix time)
                self.GMTDate = Date(timeIntervalSince1970: TimeInterval(dateDouble))
            }
        }
        if let cityDict = dict["city"] as? String {
            self.city = cityDict
        }
        if let locationDict = dict["location"] as? String {
            self.location = locationDict
        }
        if let venueDict = dict["venue"] as? String {
            self.venue = venueDict
        }
        if let descriptionDict = dict["description"] as? String {
            self.details = descriptionDict
        }
        if let ticketURLDict = dict["ticketURL"] as? String {
            self.ticketURL = ticketURLDict
        }
        if let eventURLDict = dict["eventURL"] as? String {
            self.eventURL = eventURLDict
        }
        if let contactDict = dict["contact"] as? String {
             self.contact = contactDict
        }
        if let phoneNumberDict = dict["phone"] as? String {
            self.phoneNumber = phoneNumberDict
            
        }
        if let tag1 = dict["tag1"] as? String {
            self.tag1 = tag1
        }
        if let tag2 = dict["tag2"] as? String {
            self.tag2 = tag2
        }
        if let tag3 = dict["tag3"] as? String {
            self.tag3 = tag3
        }
        if let upvoteCountDict = dict["upvotes"] as? Int {
            self.upvoteCount = upvoteCountDict
        }
        if let stringPaid = dict["paid"] as? String {
            self.paid = (stringPaid == "1") ? true : false
        }
        if let userCount = dict["userCount"] as? Int {
            self.userCount = userCount
        }
    }
    
    func upvote(){
        if userIsNotLoggedIn() {return}
        
        //If the event was already upvoted by user and they click the upvote button, downvote the event
        //If event was not upvoted, upvoted the event
        if upvoted {
            //Update UI
            upvoted = false
            upvoteCount -= 1
            reloadEventTableView()
            removeUpvoteFromFirebaseEvent(event: self)
        } else {
            //Update UI
            upvoted = true
            upvoteCount += 1
            reloadEventTableView()
            //Update Firebase
            upvoteFirebaseEvent(event: self)
        }
        
    }
    
    func markFavorite(){
        if userIsNotLoggedIn() {return}
        
        //Update the UI to account for icon changes
        favorite = !favorite
        reloadEventTableView()
        
        //Update firebase
        if favorite {
            favoriteFirebaseEvent(event: self)
        } else {
            unfavoriteFirebaseEvent(event: self)
        }
       
    }
    
    //Comparable protocol stub
    //Determine how events should be compared based on user's sort preferences
    static func < (lhs: Event, rhs: Event) -> Bool {
        guard let lhsEventDate = lhs.GMTDate, let rhsEventDate = rhs.GMTDate else {
            return lhs.upvoteCount < rhs.upvoteCount
        }
        
        switch sortByPreference {
        case .popularity: return lhs.upvoteCount < rhs.upvoteCount
        case .datedesc: return lhsEventDate < rhsEventDate
        case .dateasc: return lhsEventDate < rhsEventDate
        }
    }
    
    //Comparable protocol stub
     //Determine how events should be compared based on user's sort preferences
    static func == (lhs: Event, rhs: Event) -> Bool {
        
        guard let lhsEventDate = lhs.GMTDate, let rhsEventDate = rhs.GMTDate else {
            return lhs.upvoteCount == rhs.upvoteCount
        }
        
        switch sortByPreference {
        case .popularity: return lhs.upvoteCount == rhs.upvoteCount
        case .datedesc: return lhsEventDate == rhsEventDate
        case .dateasc: return lhsEventDate == rhsEventDate
        }

    }
    
    func getDateCurrentTimeZone() -> Date? {
        guard let gmtDate = self.GMTDate else {
            return nil
        }
         return gmtDate.convertToTimeZone(initTimeZone: TimeZone(secondsFromGMT: 0)!, timeZone: Calendar.current.timeZone)
    }
    
    
    
}
