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

let testData: [String] = []



 

func addTestDataToFirebase(vc: UIViewController){
    
    for eventString in testData {
        
        let eventStringArr = eventString.components(separatedBy: "|")
        let dateString = eventStringArr[2]
        let dateDouble = Double(dateString)!
        let GMTDate = Date(timeIntervalSince1970: TimeInterval(dateDouble))
        let address = eventStringArr[3]
        let venue = eventStringArr[4]
        let name = eventStringArr[1] + " at " + venue
        let category = stringToEventCategory(string: "Music")
        let tag1 = "Concert"
        let tag2 = "NYC"
        let tag3 = "Show"
        
        if name != nil && GMTDate != nil && address != nil && venue != nil {
            let event = Event(name: name, category: category, date: GMTDate, address: address, venue: venue, details: name, contact: "", phoneNumber: "", ticketURL: "", eventURL: "", tag1: tag1, tag2: tag2, tag3: tag3, paid: true)
            
            
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
