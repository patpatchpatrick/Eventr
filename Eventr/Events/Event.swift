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
    var duration = 0 // Event duration in minutes
    var dateWithDurationAdded: Date = Date()
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
    var price: String = ""
    var upvoteCount: Int = 0
    var upvoted: Bool = false
    var userCount = 0 //count of users who are attending the event
    
    
    var loggedInUserCreatedTheEvent: Bool = false //Bool to determine if it was a user-created event
    var loggedInUserAttendingTheEvent: Bool = false //Bool to track if user is attending the event
    
    init(name: String, category: EventCategory, date: Date, city: String, address: String, venue: String, details: String, contact: String, phoneNumber: String, ticketURL: String, eventURL: String, tag1: String, tag2: String, tag3: String, paid: Bool, price: String) {
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
        self.price = price
        
    }
    
    init(otherEvent:Event) {
        self.name = otherEvent.name
        self.id = otherEvent.id
        self.category = otherEvent.category
        self.GMTDate = otherEvent.GMTDate
        self.duration = otherEvent.duration
        self.dateWithDurationAdded = otherEvent.dateWithDurationAdded
        self.city = otherEvent.city
        self.location = otherEvent.location
        self.venue = otherEvent.venue
        self.details = otherEvent.details
        self.contact = otherEvent.contact
        self.phoneNumber = otherEvent.phoneNumber
        self.ticketURL = otherEvent.ticketURL
        self.eventURL = otherEvent.eventURL
        self.tag1 = otherEvent.tag1
        self.tag2 = otherEvent.tag2
        self.tag3 = otherEvent.tag3
        self.favorite = otherEvent.favorite
        self.paid = otherEvent.paid
        self.price = otherEvent.price
        self.upvoteCount = otherEvent.upvoteCount
        self.upvoted = otherEvent.upvoted
        self.userCount = otherEvent.userCount
        
    }
    
    //Returns a copy of the event
    func copy() -> Event {
        return Event(otherEvent: self)
    }
    
    func printEvent(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)!
        
        print("Name: " + name + "Date: " + dateFormatter.string(from: GMTDate!) + "Duration: " + String(duration) + "City: " + city + "Address: " + location + "Venue: " + venue + "Details: " + details + "Contact: " + contact + "Phone: " + phoneNumber + "TicketURL: " + ticketURL + "EventURL: " + eventURL + "Category " + category.text() + "Price: " + price + "Upvotes: " + String(upvoteCount) + "Attending: " + String(userCount))
    }
    
    //Initialize an event from a dictionary retreived from Firebase
    init(dict: NSDictionary, idKey: String){
        if let nameDict = dict["name"] as? String {
            self.name = nameDict
        }
        self.id = idKey
        if let categoryInt = dict["category"] as? Int {
            self.category = intToEventCategory(integer: categoryInt)
        }
        if let dateDouble = dict["date"] as? Double {

                //Date is stored in Firebase in GMT time (unix time)
                self.GMTDate = Date(timeIntervalSince1970: TimeInterval(dateDouble))
            
        }
        if let durationInt = dict["duration"] as? Int {
            self.duration = durationInt
        }
        setUpDurationDate()
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
        if let stringPrice = dict["price"] as? String {
            self.price = stringPrice
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
    
    func getDateWithDurationCurrentTimeZone() -> Date {
        
        return dateWithDurationAdded.convertToTimeZone(initTimeZone: TimeZone(secondsFromGMT: 0)!, timeZone: Calendar.current.timeZone)
    }
    
    func setUpDurationDate(){
        
        guard let gmtDate = GMTDate else {return}
        if duration != 0 {
            dateWithDurationAdded = gmtDate.addingTimeInterval(TimeInterval(60*duration))
        }
        
    }
    
    func getPriceLabel() -> String {
        if price != "" && price.contains("$"){
            let formattedPrice = price.replacingOccurrences(of: "$", with: "", options: .literal, range: nil)
            return formattedPrice
        }
        return price
    }
    
    
    
}
