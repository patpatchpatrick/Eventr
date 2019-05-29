//
//  Notifications.swift
//  Eventr
//
//  Created by Patrick Doyle on 5/14/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

//Class to track notifications
import Foundation

func reloadEventTableView(){
       NotificationCenter.default.post(name: Notification.Name("UPDATED_EVENT_DATA"), object: nil)
}

func reloadEventViewController(){
    NotificationCenter.default.post(name: Notification.Name("RELOAD_EVENT_VC"), object: nil)
}

//Notification for when pagination has finished loading
func paginationFinishedLoading(){
    paginationInProgress = false
}

func checkIfDistanceSearchIsComplete(){
    print("TABLEVIEWCOUNT")
    print(tableEvents.count)
    print("NEARBYEVENTPAGECOUNT")
    print(nearbyEventPageCount)
    print("SEARCHRADIUS")
    print(incrementingSearchRadius)
    
    if tableEvents.count >= nearbyEventPageCount {
        
        //If the count of events in the table is greater than the total page count, the query is complete and all events have been loaded
        nearbyEventPageCountLoaded = true
        paginationInProgress = false
    } else {
        //If the event count is less than the necessary page count and the search radius is still less than the user selected search radius, then query Firebase for more events in a greater radius
        if incrementingSearchRadius < searchDistanceMiles {
            incrementingSearchRadius += 0.5
            guard let gQ = gQuery else {return}
            gQ.radius = incrementingSearchRadius //Update the query radius 
        }
    }
    
}
