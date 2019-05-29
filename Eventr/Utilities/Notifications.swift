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

func checkIfNearbyQueryIsComplete(){
//Check if the "Nearby" query is complete or if there is more data to load
    //The "Nearby" query works by slowly incrementing the Firebase search radius to load more and more data until the page is full of data.  Once the page is full of data, if the user loads a new page, the page count will increase and more data will be loaded.  This will process will repeat until the user stops loading new pages or until the search radius has been fully loaded.
    
    if tableEvents.count >= nearbyEventPageCount {
        //If the count of events in the table is greater than the total page count, the query is complete and all events have been loaded.  Pagination is no longer in progress and the user can load more pages if necessary.  
        nearbyEventPageCountLoaded = true
        paginationInProgress = false
    } else {
        //If the event count is less than the necessary page count and the search radius is still less than the user selected search radius, then query Firebase for more events in a greater radius
        if incrementingSearchRadius < searchDistanceMiles {
            incrementingSearchRadius += defaultSearchIncrement //Increase the geoquery search radius
            guard let gQ = gQuery else {return}
            gQ.radius = incrementingSearchRadius //Update the current geoquery radius
        }
    }
    
}
