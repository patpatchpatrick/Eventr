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
    var friendWhoIsAttending: String = "" //friend who is attending this particular event
    var id: String = ""
    var category: EventCategory = EventCategory(category: .misc)
    var GMTDate: Date? // Event date in GMT timezone
    var duration = 0 // Event duration in minutes
    var dateWithDurationAdded: Date = Date()
    var city: String = ""
    var paid: Bool = false
    var price: String = ""
    
    init(dict: NSDictionary, eventID: String, friendName: String){
        
        if let nameDict = dict["name"] as? String {
            self.name = nameDict
        }
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
        if let stringPaid = dict["paid"] as? String {
            self.paid = (stringPaid == "1") ? true : false
        }
        if let stringPrice = dict["price"] as? String {
            self.price = stringPrice
        }
        
        self.id = eventID
        self.friendWhoIsAttending = friendName
        
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
    
    func getDateCurrentTimeZone() -> Date? {
        guard let gmtDate = self.GMTDate else {
            return nil
        }
        return gmtDate.convertToTimeZone(initTimeZone: TimeZone(secondsFromGMT: 0)!, timeZone: Calendar.current.timeZone)
    }
    
    func getDateWithDurationCurrentTimeZone() -> Date {
        
        return dateWithDurationAdded.convertToTimeZone(initTimeZone: TimeZone(secondsFromGMT: 0)!, timeZone: Calendar.current.timeZone)
    }
    
    static func < (lhs: EventSnippet, rhs: EventSnippet) -> Bool {
        print("ADD COMPARABLE CODE")
        return true
    }
    
    static func == (lhs: EventSnippet, rhs: EventSnippet) -> Bool {
        print("ADD COMPARABLE CODE")
        return true
    }

    
    
    

}
