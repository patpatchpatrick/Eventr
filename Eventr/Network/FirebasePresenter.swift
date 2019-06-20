//
//  FirebasePresenter.swift
//  Eventr
//
//  Created by Patrick Doyle on 6/10/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import Firebase
import GeoFire
import MapKit

//Class to return Firebase data back to view controllers

func addQueriedEventsToTableViewByValue(eventsList: NSDictionary){
    
    //Add queried events to tableView
    //This method is used for queried events that already have all event data in NSDictionary format
    //First create an event, then add it to both the allEvents list and tableEvents list in sorted order
    for eventID in eventsList.allKeys {
        if let id = eventID as? String, let eventDict = eventsList[eventID] as? NSDictionary {
            let event = Event(dict: eventDict, idKey: id)
            
            //Keep track of the most recently queried values for pagination purposes.
            updatePaginationValues(event: event)
            
            //Check if event has been favorited by user
            queryIfFirebaseEventIsFavorited(event: event)
            //Check if event has been upvoted by user
            queryIfFirebaseEventIsUpvoted(event: event)

            
            //First, add the event to the allEvents list (this list is used to maintain events so that they can be re-filtered without needing to query Firebase again)
            addEventToEventsListInOrder(event: event, eventList: &allEvents)
            if selectedCategory == categoryAll || selectedCategory == event.category.index() {
                //Secondly, use the current selected category to filter the events and add them to tableView
                addEventToEventsListInOrder(event: event, eventList: &tableEvents)
            }
            
            reloadEventTableView()
            paginationFinishedLoading()
        }
        
    }
    
    
}

//Add events to the tableView by Key(eventID)
func addEventsToTableViewByKey(eventIDMap: NSDictionary, isUserCreatedEvent: Bool, addToListsInSortedOrder: Bool, addToAllEventsList: Bool){
    for (id, city) in eventIDMap {
        //Method used by "Nearby Queries" and "List Descriptor Queries" to add events to tableview
        
        //Get the Event ID and the City as string values
        //The Event ID and the City are stored as Key:Value pairs in Firebase
        guard let eventID = id as? String, let eventCity = city as? String else {
            return
        }
        firebaseDatabaseRef.child("events").child(eventCity).child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get dictionary of event data by querying the event ID
            if let value = snapshot.value as? NSDictionary {
                let event = Event(dict: value, idKey: eventID)
                
                if isUserCreatedEvent {
                    event.loggedInUserCreatedTheEvent = true //Mark if the user created the event
                    //This will currently only be triggered if the user clicks the "My Events" button
                }
                //Check if event has been favorited by user
                queryIfFirebaseEventIsFavorited(event: event)
                //Check if event has been upvoted by user
                queryIfFirebaseEventIsUpvoted(event: event)

                
                if addToListsInSortedOrder{
                    //ListDescriptor events and Specific Category queries are added here
                    updatePaginationValues(event: event) //Update values used for pagination purposes
                    addEventToEventsListInOrder(event: event, eventList: &tableEvents)
                    reloadEventTableView()
                    if addToAllEventsList{
                        addEventToEventsListInOrder(event: event, eventList: &allEvents)
                        paginationFinishedLoading()
                    }
                    
                } else {
                    //"Nearby" events are added here
                    //They do not need to be added to the tableView in order since "Nearby" events are not queried in any particular order
                    //First, add the event to the allEvents list (this list is used as a cache so that events  can be re-filtered without needing to query Firebase again)
                    addEventToEventsListInOrder(event: event, eventList: &allEvents)
                    if selectedCategory == categoryAll || selectedCategory == event.category.index() {
                        //Secondly, use the current selected category to filter the events and add them to tableView
                        tableEvents.append(event)
                        reloadEventTableView()
                        if firebaseQueryType != .nearby {
                            paginationFinishedLoading()
                        }
                    }
                }
            }
        }) { (error) in
            print("FB Query Error" + error.localizedDescription)
        }
    }
    
}

func updatePaginationValues(event: Event){
    
    //Keep track of the most recently queried values for pagination purposes.
    //The most recently queried date is always the greatest date, since dates are queried in ascending order
    //The most recently queried upvote count is always the lowest count since upvotes are queried in descending order
    
    if mostRecentlyQueriedDate == nil {
        mostRecentlyQueriedDate = event.GMTDate
    } else {
        if let eventDate = event.GMTDate {
            if eventDate > mostRecentlyQueriedDate! {
                mostRecentlyQueriedDate = event.GMTDate
            }
        }
    }
    
    if mostRecentlyQueriedUpvoteCount == nil {
        mostRecentlyQueriedUpvoteCount = event.upvoteCount
    } else {
        if event.upvoteCount < mostRecentlyQueriedUpvoteCount! {
            mostRecentlyQueriedUpvoteCount = event.upvoteCount
        }
    }
    
}

//Method to add event snippets to friends event lists in sorted order
func addEventSnipToFriendsEventsListInOrder(eventSnip: EventSnippet, eventSnipList: inout [EventSnippet]){
    var index = 0
    index = eventSnipList.insertionIndexOf(elem: eventSnip, isOrderedBefore: <)
    eventSnipList.insert(eventSnip, at: index)
}
