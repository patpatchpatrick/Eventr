//
//  ManualFirebase.swift
//  Eventr
//
//  Created by Patrick Doyle on 5/27/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import UIKit

var count = 0

let testMusicData: [String] = [
   
]

let testSportData: [String] = [
    
]

let testStandardData: [String] = [

   
]

var testEventIDArr: [String]  = []
var countUpdated = 0

//Class used to manually remove events from Firebase if necessary
func manuallyDeleteEvent(event: Event){
    //START
    if (event.category.index() == 6 || event.category.index() == 7 || event.category.index() == 8 || event.category.index() == 9) && !testEventIDArr.contains(event.id) {
        
        
        //Update the upvote count in both the "events" and "events-category" sections of Firebase
        deleteFirebaseEvent(event: event, callback: {
            eventWasDeletedSuccessfully in
            if eventWasDeletedSuccessfully {
                print("EVENT DELETED SUCCESSFULLY")
                
            } else {
                print("EVENT UNABLE TO BE DELETED")
                
            }
            
        })
        testEventIDArr.append(event.id)
        countUpdated += 1
        print(countUpdated)
    }
    //END
}

//Class used to manually add data to Firebase if necessary

func addTestDataToFirebase(vc: UIViewController){
    
    for eventString in testMusicData {
        
        let eventStringArr = eventString.components(separatedBy: "|")
        let dateString = eventStringArr[2]
        let dateDouble = Double(dateString)!
        let GMTDate = Date(timeIntervalSince1970: TimeInterval(dateDouble))
        let city = "NYC"
        let address = eventStringArr[3]
        let venue = eventStringArr[4]
        let name = eventStringArr[1] + " at " + venue
        var upvoteCount = 0
        var userCount = 0
        let eventLink = eventStringArr[6]
        let eventPrice = eventStringArr[7]
        if let multiplier = Int(eventStringArr[5] ){
             upvoteCount = (multiplier + 1) * Int(arc4random_uniform(17) + 1)
            userCount = (multiplier + 1) * Int(arc4random_uniform(4) + 1)
        }
        let category = stringToEventCategory(string: "Music")
        let tag1 = "Concert"
        let tag2 = "NY"
        let tag3 = "Show"
        
        if name != nil && GMTDate != nil && address != nil && venue != nil {
            let event = Event(name: name, category: category, date: GMTDate, city: city, address: address, venue: venue, details: name, contact: "", phoneNumber: "", ticketURL: eventLink, eventURL: eventLink, tag1: tag1, tag2: tag2, tag3: tag3, paid: true, price: eventPrice)
            event.upvoteCount = upvoteCount
            event.userCount = userCount
            
            createOrUpdateFirebaseEvent(viewController: vc, event: event, createOrUpdate: .creating, dateChanged: false, callback: {
                eventWasCreatedSuccessfully in
                if eventWasCreatedSuccessfully {
                    count += 1
                    print("TEST DATA ADDED SUCCESSFULLY")
                    print(count)
                } else {
                    print("TEST DATA ADDED FAIL")
                }})
            
        }
        
        
    }
    
}

func addTestSportDataToFirebase(vc: UIViewController){
    
    for eventString in testSportData {
        
        let eventStringArr = eventString.components(separatedBy: "|")
        if !eventStringArr[1].contains("XXXX"){
        let dateString = eventStringArr[2]
            if let dateDouble = Double(dateString){
        let GMTDate = Date(timeIntervalSince1970: TimeInterval(dateDouble + 25200))
        let city = "NYC"
        let address = eventStringArr[3]
        let venue = eventStringArr[4]
        let name = eventStringArr[1] + " at " + venue
        let eventLink = eventStringArr[7]
        let eventPrice = eventStringArr[8]
        var upvoteCount = 0
        var userCount = 0
        if let multiplier = Int(eventStringArr[6] ){
            upvoteCount = (multiplier + 1) * Int(arc4random_uniform(17) + 1)
            userCount = (multiplier + 1) * Int(arc4random_uniform(4) + 1)
        }
        let category = stringToEventCategory(string: "Sports")
        let tag1 = "Sports"
        let tag2 = "NY"
        let tag3 = "Athletics"
        
        if name != nil && !name.contains("XXXX") && GMTDate != nil && address != nil && venue != nil {
            let event = Event(name: name, category: category, date: GMTDate, city: city, address: address, venue: venue, details: name, contact: "", phoneNumber: "", ticketURL: eventLink, eventURL: eventLink, tag1: tag1, tag2: tag2, tag3: tag3, paid: true, price: eventPrice)
            event.upvoteCount = upvoteCount
            event.userCount = userCount
            
            createOrUpdateFirebaseEvent(viewController: vc, event: event, createOrUpdate: .creating, dateChanged: false, callback: {
                eventWasCreatedSuccessfully in
                if eventWasCreatedSuccessfully {
                    count += 1
                    print("TEST DATA ADDED SUCCESSFULLY")
                    print(count)
                } else {
                    print("TEST DATA ADDED FAIL")
                }})
            
                }}}
        
        
    }
    
}

func addTestStandardDataToFirebase(vc: UIViewController){
    
    for eventString in testStandardData {
        
        let eventStringArr = eventString.components(separatedBy: "|")
        let dateString = eventStringArr[1]
        let duration = Int(eventStringArr[2])
        if let dateDouble = Double(dateString){
        let GMTDate = Date(timeIntervalSince1970: TimeInterval(dateDouble + 25200))
        let city = "NYC"
        let name = eventStringArr[0]
        let address = eventStringArr[3]
        let venue = eventStringArr[4]
        let description = eventStringArr[5]
        let eventLink = eventStringArr[6]
        let eventPrice = eventStringArr[7]
        var upvoteCount = 0
        var userCount = 0
        let phone = eventStringArr[8]
        if let multiplier = Int(eventStringArr[9] ){
                upvoteCount = (multiplier + 1) * Int(arc4random_uniform(17) + 1)
                userCount = (multiplier + 1) * Int(arc4random_uniform(4) + 1)
            }
            let category = stringToEventCategory(string: "Food")
            let tag1 = "Food"
            let tag2 = "Summer"
            let tag3 = "Drink"
            
            if name != nil && !name.contains("XXXX") && GMTDate != nil && address != nil && venue != nil {
                let event = Event(name: name, category: category, date: GMTDate, city: city, address: address, venue: venue, details: name + " @ " + venue, contact: "", phoneNumber: phone, ticketURL: eventLink, eventURL: eventLink, tag1: tag1, tag2: tag2, tag3: tag3, paid: true, price: eventPrice)
                if let dur = duration {
                   event.duration = dur * 60
                }
                event.upvoteCount = upvoteCount
                event.userCount = userCount
                
                //event.printEvent()
                
               
                createOrUpdateFirebaseEvent(viewController: vc, event: event, createOrUpdate: .creating, dateChanged: false, callback: {
                    eventWasCreatedSuccessfully in
                    if eventWasCreatedSuccessfully {
                        count += 1
                        print("TEST DATA ADDED SUCCESSFULLY")
                        print(count)
                    } else {
                        print("TEST DATA ADDED FAIL")
                    }})
                
                
                
            }}
        
        
    }
    
    
}
