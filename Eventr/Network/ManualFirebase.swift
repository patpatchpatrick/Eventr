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
    "|NBA Draft |1560884400.0|620 Atlantic Ave.Brooklyn, New York.11217| Barclays Center, Brooklyn, New York|1|2|https://www.barclayscenter.com/events/detail/nba-draft-2019|>$90",
    "|Travelers Championship: Thursday Admission |1560884400.0|1 Golf Club Rd.Cromwell, Connecticut.06416| TPC River Highlands, Cromwell, Connecticut|1|0|https://travelerschampionship.com/|>$75",
    "|Portland Sea Dogs at Trenton Thunder |1560942000.0|1 Thunder Rd.Trenton, New Jersey.08611| Arm & Hammer Park, Trenton, New Jersey|0|0|https://www.milb.com/trenton/tickets/single-game-tickets|>$12",
    "|Golden Boy Boxing: BALLARD V. ESPADAS |1560942000.0|500 Boardwalk.Atlantic City, New Jersey.08401| Ovation Hall at Ocean Casino Resort, Atlantic City, New Jersey|0|0||",
    "XXXXX |1560942300.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0||",
    "|New York Yankees vs. Houston Astros |1560942300.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|1|https://www.mlb.com/yankees/tickets|>$15",
    "XXXXXNew York Yankees V Houston Astros |1560942300.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0||",
    "|Scranton/Wilkes-Barre RailRiders vs. Norfolk Tides |1560942300.0|235 Montage Mountain Rd.Moosic, Pennsylvania.18507| PNC Field, Moosic, Pennsylvania|0|0|https://www.milb.com/scranton-wb/tickets/single-game-tickets|>$11",
    "|Travelers Championship: Friday Admission |1560970800.0|1 Golf Club Rd.Cromwell, Connecticut.06416| TPC River Highlands, Cromwell, Connecticut|1|0||",
    "XXXXX |1561028700.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0||",
    "|New York Yankees vs. Houston Astros |1561028700.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|1|https://www.mlb.com/yankees/tickets|>$15",
    "XXXXXNew York Yankees V Houston Astros |1561028700.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0||",
    "|Scranton/Wilkes-Barre RailRiders vs. Durham Bulls |1561028700.0|235 Montage Mountain Rd.Moosic, Pennsylvania.18507| PNC Field, Moosic, Pennsylvania|0|0|https://www.milb.com/scranton-wb/tickets/single-game-tickets|>$11",
    "|Travelers Championship: Friday Admission |1560985200.0|1 Golf Club Rd.Cromwell, Connecticut.06416| TPC River Highlands, Cromwell, Connecticut|1|0||",
    "XXXXX |1561043100.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0||",
    "|New York Yankees vs. Houston Astros |1561043100.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0|https://www.mlb.com/yankees/tickets|>$15",
    "XXXXXNew York Yankees V Houston Astros |1561043100.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0||",
    "|Scranton/Wilkes-Barre RailRiders vs. Durham Bulls |1561043100.0|235 Montage Mountain Rd.Moosic, Pennsylvania.18507| PNC Field, Moosic, Pennsylvania|0|0|https://www.milb.com/scranton-wb/tickets/single-game-tickets|>$11",
    "|Travelers Championship: Saturday Admission |1561071600.0|1 Golf Club Rd.Cromwell, Connecticut.06416| TPC River Highlands, Cromwell, Connecticut|1|0||",
    "XXXXX Park - Reserved XXXXX |1561102200.0|2150 Hempstead Turnpike.Elmont, New York.11003| Belmont Park, Elmont, New York|0|0||",
    "|Scranton/Wilkes-Barre RailRiders vs. Durham Bulls |1561127700.0|235 Montage Mountain Rd.Moosic, Pennsylvania.18507| PNC Field, Moosic, Pennsylvania|0|0|https://www.milb.com/scranton-wb/tickets/single-game-tickets|>$11",
    "XXXXX |1561130100.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0||",
    "|New York Yankees vs. Houston Astros |1561130100.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0|https://www.mlb.com/yankees/tickets|>$15",
    "XXXXXNew York Yankees V Houston Astros |1561130100.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0||",
    "|Tampa Bay Rowdies at Bethlehem Steel FC |1561131000.0|Seaport Drive.Chester, Pennsylvania.19013| Talen Energy Stadium, Chester, Pennsylvania|0|0||",
    "|Travelers Championship: Saturday Admission |1561086000.0|1 Golf Club Rd.Cromwell, Connecticut.06416| TPC River Highlands, Cromwell, Connecticut|1|0||",
    "XXXXX Park - Reserved XXXXX |1561116600.0|2150 Hempstead Turnpike.Elmont, New York.11003| Belmont Park, Elmont, New York|0|0||",
    "|Scranton/Wilkes-Barre RailRiders vs. Durham Bulls |1561142100.0|235 Montage Mountain Rd.Moosic, Pennsylvania.18507| PNC Field, Moosic, Pennsylvania|0|0|https://www.milb.com/scranton-wb/tickets/single-game-tickets|>$11",
    "XXXXX |1561144500.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0||",
    "|New York Yankees vs. Houston Astros |1561144500.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0|https://www.mlb.com/yankees/tickets|>$15",
    "XXXXXNew York Yankees V Houston Astros |1561144500.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0||",
    "|Tampa Bay Rowdies at Bethlehem Steel FC |1561145400.0|Seaport Drive.Chester, Pennsylvania.19013| Talen Energy Stadium, Chester, Pennsylvania|0|0||",
    "|Travelers Championship: Sunday Admission |1561172400.0|1 Golf Club Rd.Cromwell, Connecticut.06416| TPC River Highlands, Cromwell, Connecticut|1|0||",
    "XXXXX Park - Reserved XXXXX |1561203000.0|2150 Hempstead Turnpike.Elmont, New York.11003| Belmont Park, Elmont, New York|0|0||",
    "|Scranton/Wilkes-Barre RailRiders vs. Durham Bulls |1561208700.0|235 Montage Mountain Rd.Moosic, Pennsylvania.18507| PNC Field, Moosic, Pennsylvania|0|0|https://www.milb.com/scranton-wb/tickets/single-game-tickets|>$11",
    "XXXXX |1561212300.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0||",
    "|New York Yankees vs. Houston Astros |1561212300.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0|https://www.mlb.com/yankees/tickets|>$15",
    "XXXXXNew York Yankees V Houston Astros |1561212300.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0||",
    "|Travelers Championship: Good Any One Day |1561247940.0|1 Golf Club Rd.Cromwell, Connecticut.06416| TPC River Highlands, Cromwell, Connecticut|0|0||",
    "|Travelers Championship: Sunday Admission |1561186800.0|1 Golf Club Rd.Cromwell, Connecticut.06416| TPC River Highlands, Cromwell, Connecticut|1|0||",
    "XXXXX Park - Reserved XXXXX |1561217400.0|2150 Hempstead Turnpike.Elmont, New York.11003| Belmont Park, Elmont, New York|0|0||",
    "|Scranton/Wilkes-Barre RailRiders vs. Durham Bulls |1561223100.0|235 Montage Mountain Rd.Moosic, Pennsylvania.18507| PNC Field, Moosic, Pennsylvania|0|0|https://www.milb.com/scranton-wb/tickets/single-game-tickets|>$11",
    "XXXXX |1561226700.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0||",
    "|New York Yankees vs. Houston Astros |1561226700.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0|https://www.mlb.com/yankees/tickets|>$15",
    "XXXXXNew York Yankees V Houston Astros |1561226700.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0||",
    "|Travelers Championship: Good Any One Day |1561262340.0|1 Golf Club Rd.Cromwell, Connecticut.06416| TPC River Highlands, Cromwell, Connecticut|0|0||",
    "|CONCACAF Gold Cup Group B - VIP Packages |1561273200.0|600 Cape May Street.Harrison, New Jersey.07029| Red Bull Arena, Harrison, New Jersey|1|0||",
    "|CONCACAF Gold Cup Group B Doubleheader |1561329000.0|600 Cape May Street.Harrison, New Jersey.07029| Red Bull Arena, Harrison, New Jersey|0|0||",
    "|Portland Sea Dogs at Trenton Thunder |1561330800.0|1 Thunder Rd.Trenton, New Jersey.08611| Arm & Hammer Park, Trenton, New Jersey|0|0|https://www.milb.com/trenton/tickets/single-game-tickets|>$12",
    "XXXXX |1561331100.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0||",
    "|New York Yankees vs. Toronto Blue Jays |1561331100.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0|https://www.mlb.com/yankees/tickets|>$15",
    "XXXXXNew York Yankees V Toronto Blue Jays |1561331100.0|1 East 161st Street.Bronx, New York.10451| Yankee Stadium, Bronx, New York|0|0||",
    "|CONCACAF Gold Cup Group B - VIP Packages |1561287600.0|600 Cape May Street.Harrison, New Jersey.07029| Red Bull Arena, Harrison, New Jersey|1|0||",
    "|CONCACAF Gold Cup Group B Doubleheader |1561343400.0|600 Cape May Street.Harrison, New Jersey.07029| Red Bull Arena, Harrison, New Jersey|0|0||"
]

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
