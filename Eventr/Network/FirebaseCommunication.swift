//
//  FirebaseCommunication.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/29/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import Firebase
import GeoFire
import MapKit

var testEventIDArr: [String]  = []
var countUpdated = 0

//Class to handle communication with Firebase

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

//Delete events by Key(eventID)
func deleteEventsByKey(eventIDMap: NSDictionary, isUserCreatedEvent: Bool){
    for (id, city) in eventIDMap {
        //This method will query events using the event ids/keys and will then delete the events from Firebase
        
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
                    event.loggedInUserCreatedTheEvent = true //Users can only delete events that they created
                }
                
                deleteFirebaseEvent(event: event, callback: {
                    eventWasDeletedSuccessfully in
                    if eventWasDeletedSuccessfully {
                        print("EVENT DELETED SUCCESSFULLY")
                    } else {
                        print("EVENT UNABLE TO BE DELETED")
                    }
                    
                })
                
            }
        }) { (error) in
            print("FB Deletion Error" + error.localizedDescription)
        }
    }
    
}

//Create a firebase event
//This method will write all necessary data to firebase for an event when a new event is created
//First it will create an event in the Events section of the database
//Then, it will create an event in the GeoFire section of the database so the event can be searched by location
//Then, it will create an event in the Dates section of the database so the event can be searched by date (and removed from database when the date has passed)
func createOrUpdateFirebaseEvent(viewController: UIViewController, event: Event, createOrUpdate: eventAction, dateChanged: Bool, callback: ((Bool) -> Void)?){
    if userIsNotLoggedIn() {return}
    guard let userID = Auth.auth().currentUser?.uid else { return }
    guard let eventDate = event.GMTDate else {return}
    getCoordinates(forAddress: event.location) {
        (location) in
        guard let location = location else {
            //Ensure that event has a valid location before continuing and inserting event into Firebase database
            displayInvalidLocationAlert(viewController: viewController)
            return
        }
        

        let initialLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
    
        let eventDateDouble = Double(eventDate.timeIntervalSince1970)
        
        let paidString = (event.paid) ? "1" : "0"
        let eventData = [ //Data for the event-metadata in Firebase
            "name":  event.name,
            "category": event.category.index(),
            "date": eventDateDouble,
            "dateSort": 0 - eventDateDouble,
            "duration": event.duration,
            "description": event.details,
            "city": event.city,
            "location":   event.location,
            "venue": event.venue,
            "ticketURL":   event.ticketURL,
            "eventURL":   event.eventURL,
            "contact":   event.contact,
            "phone": event.phoneNumber,
            "tag1":   event.tag1,
            "tag2":   event.tag2,
            "tag3":   event.tag3,
            "upvotes": event.upvoteCount,
            "paid" : paidString,
            "price" : event.price,
            "userCount" : event.userCount
            ] as [String : Any]
        let eventCategoryData = [ //Data to sort the event by category in Firebase
            "date": eventDateDouble,
            "dateSort": 0 - eventDateDouble,
            "upvotes": event.upvoteCount,
            ] as [String : Any]
        //Add the event to the "events" section of firebase
        //If event is being created for first time, generate an autoID
        //If event is being updated, the child will be the eventID
        let firebaseEvent : DatabaseReference = {
            switch createOrUpdate {
            case .creating:
                return firebaseDatabaseRef.child("events").child(event.city).childByAutoId()
            case .editing:
                return firebaseDatabaseRef.child("events").child(event.city).child(selectedEvent.id)
            }
        }()
        
        guard let eventKey = firebaseEvent.key else { return }
        
        //Add events-metadata to Firebase
        event.id = eventKey
        firebaseEvent.setValue(eventData, withCompletionBlock: { (error, snapshot) in
            if error != nil {
                print("Error writing event to Firebase")
            } else {
                //If event was successfully added to Firebase, add GeoFire event location to firebase
                     insertGeofireEvent(location: initialLocation, eventID: eventKey, callback: callback)
                
            }
        })
        
        
        //Add events-category data to Firebase
        let firebaseCategoryEvent : DatabaseReference = {
            switch createOrUpdate {
            case .creating:
                return firebaseDatabaseRef.child("events-category").child(event.city).child(String(event.category.index())).child(event.id)
            case .editing:
                return firebaseDatabaseRef.child("events-category").child(event.city).child(String(event.category.index())).child(event.id)
            }
        }()
        
        firebaseCategoryEvent.setValue(eventCategoryData)
        
        
        //Map the firebase event to the appropriate date in the database
        let firebaseDate = getFirebaseDateFormatYYYYMDD(date: eventDate)
        
        switch createOrUpdate {
        case .creating: firebaseDatabaseRef.child("date").child(firebaseDate).child(event.id).setValue(event.id)
        case .editing:
            if dateChanged {
                //If you are editing an event and the date changed, remove the old date and add the new date
                 let previousDate = getFirebaseDateFormatYYYYMDD(date: event.previousDate)
                firebaseDatabaseRef.child("date").child(previousDate).child(event.id).removeValue()
                firebaseDatabaseRef.child("date").child(firebaseDate).child(event.id).setValue(event.id)
                
            }
        }
        
        //Add user creation data and event-city data to Firebase
        
        if createOrUpdate == .creating {
            //Map the firebase event to the "created" events section of Firebase
            firebaseDatabaseRef.child("created").child(userID).child(event.id).setValue(event.city)
            
            //Add the event to the event-city section of firebase used to find events based on the city
            firebaseDatabaseRef.child("event-city").child(event.id).child(event.city).setValue(event.city)
        }
       
    
    
        
        
    }
}

func deleteFirebaseEvent(event: Event, callback: ((Bool) -> Void)?) {
    
    
    guard let userID = Auth.auth().currentUser?.uid else {
        print("UID FAIL")
        callback!(false)
        return }
    
    
    guard let eventDate = event.GMTDate else {
        print("DATE FAIL")
        callback!(false)
        return
    }
    
     //If event was not created by user, do not delete it
    if event.loggedInUserCreatedTheEvent == false {
        print("LOGGEDINUSERCREATEERRROR")
        callback!(false)
        return}

    
    //Delete every reference to the event (events, created, date and geoFire)
    //User specific references to the event (upvotes, favorited, etc...) are not deleted when the event is deleted
    firebaseDatabaseRef.child("events").child(event.city).child(event.id).removeValue()
    firebaseDatabaseRef.child("events-category").child("NYC").child(String(event.category.index())).child(event.id).removeValue()
    firebaseDatabaseRef.child("attendingEvents").child(event.id).removeValue()
    firebaseDatabaseRef.child("created").child(userID).child(event.id).removeValue()
    let firebaseDate = getFirebaseDateFormatYYYYMDD(date: eventDate)
    firebaseDatabaseRef.child("date").child(firebaseDate).child(event.id).removeValue()
    //Don't delete the date of the event for now when it is deleted... this date may be used to auto-delete upvotes and favorited events in the future
    firebaseDatabaseRef.child("geofire").child(event.id).removeValue()
    callback!(true) //Send callback viewController to let it know that event was deleted successfully
}

func deleteUserFirebaseData(callback: ((Bool) -> Void)?) {
    
    guard let userID = Auth.auth().currentUser?.uid else {
        return
    }
   
    //Delete all of the events that the user created
    firebaseDatabaseRef.child("created").child(userID).observeSingleEvent(of: .value, with: {
        (snapshot) in
        guard let dict = snapshot.value as? NSDictionary else { return }
        deleteEventsByKey(eventIDMap: dict, isUserCreatedEvent: true)
    })
    
    //Delete all of the user's "attending" and "favorited" data
    firebaseDatabaseRef.child("attendingUsers").child(userID).removeValue()
    
    firebaseDatabaseRef.child("favorited").child(userID).removeValue()
    
    
    callback!(true) //Send callback viewController to let it know that event was deleted successfully
}

//Increase number of upvotes for a particular event in Firebase
func upvoteFirebaseEvent(event: Event){
    
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    //Check if event has already been upvoted
    firebaseDatabaseRef.child("upvotes").child(userID).observeSingleEvent(of: .value, with: {
        (snapshot) in
        var eventAlreadyUpvoted = false
        let dict = snapshot.value as? NSDictionary
        if dict != nil {
            eventAlreadyUpvoted = dict!.allValues.contains { element in
                if case element as! String = event.id { return true } else { return false}
            }
        }
        
        //If event has not been upvoted, upvote the event
        //Increment the overall upvote count of the event in Firebase
        //Add event to user's "upvoted" section of Firebase
        if !eventAlreadyUpvoted {
            
            //Update the upvotes in Firebase
            firebaseDatabaseRef.child("events").child(event.city).child(event.id).observeSingleEvent(of: .value, with: {
                (snapshot) in
                guard let dict = snapshot.value as? NSDictionary else { return }
                guard var upvoteCount = dict["upvotes"] as? Int else { return }
                
                upvoteCount += 1
               
                //Update the upvote count in both the "events" and "events-category" sections of Firebase
                firebaseDatabaseRef.child("events").child(event.city).child(event.id).updateChildValues(["upvotes": upvoteCount])
                
                firebaseDatabaseRef.child("events-category").child(event.city).child(String(event.category.index())).child(event.id).updateChildValues(["upvotes": upvoteCount])
            firebaseDatabaseRef.child("upvotes").child(userID).childByAutoId().setValue(event.id)
               
            })
        }
    })
    
    
}

//Remove an upvote for event in Firebase
func removeUpvoteFromFirebaseEvent(event: Event){

    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    //Check if event has already been upvoted
    firebaseDatabaseRef.child("upvotes").child(userID).observeSingleEvent(of: .value, with: {
        (snapshot) in
        guard let dict = snapshot.value as? NSDictionary else { return }
        let eventAlreadyUpvoted = dict.allValues.contains { element in
            if case element as! String = event.id { return true } else { return false }
        }
        
        //Decrement the upvote count by 1
        //Decrement the overall upvote count of the event in firebase
        //Remove event from the users "upvoted events" section of firebase
        if eventAlreadyUpvoted {
            
            //Update Firebase
            firebaseDatabaseRef.child("events").child(event.city).child(event.id).observeSingleEvent(of: .value, with: {
                (snapshot) in
                guard let dict = snapshot.value as? NSDictionary else { return }
                guard var upvoteCount = dict["upvotes"] as? Int else { return }
    
                upvoteCount -= 1
               
                //Update the upvote count in both the "events" and "events-category" sections of Firebase
                firebaseDatabaseRef.child("events").child(event.city).child(event.id).updateChildValues(["upvotes": upvoteCount])
                
                firebaseDatabaseRef.child("events-category").child(event.city).child(String(event.category.index())).child(event.id).updateChildValues(["upvotes": upvoteCount])
                
                
                firebaseDatabaseRef.child("upvotes").child(userID).queryOrderedByValue().queryEqual(toValue: event.id).observeSingleEvent(of: .value) { (querySnapshot) in
                    for result in querySnapshot.children {
                        let resultSnapshot = result as! DataSnapshot
                        let eventKey = resultSnapshot.key
                        firebaseDatabaseRef.child("upvotes").child(userID).child(eventKey).removeValue()
                    }
                }
                
            })
        }
        
    })
    
    
}

//Mark a particular event in Firebase as a "favorite"
func favoriteFirebaseEvent(event: Event){

    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    //Check if event has already been favorited
    firebaseDatabaseRef.child("favorited").child(userID).observeSingleEvent(of: .value, with: {
        (snapshot) in
        var eventAlreadyFavorited = false
        let dict = snapshot.value as? NSDictionary
        if dict != nil {
                eventAlreadyFavorited = dict!.allKeys.contains { element in
                if case element as! String = event.id { return true } else { return false }
            }
        }
        
        //If not favorited, mark the event as "favorite" in Firebase
        if !eventAlreadyFavorited {
            firebaseDatabaseRef.child("favorited").child(userID).child(event.id).setValue(event.city)
        }
        
    })
    
}

//Unmark an event as "favorite" in Firebase
func unfavoriteFirebaseEvent(event: Event){
  
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    //Check if event has already been favorited
    firebaseDatabaseRef.child("favorited").child(userID).observeSingleEvent(of: .value, with: {
        (snapshot) in
        guard let dict = snapshot.value as? NSDictionary else { return }
        let eventAlreadyFavorited = dict.allKeys.contains { element in
            if case element as! String = event.id { return true } else { return false }
        }
        
        //If favorited, unmark the event as "favorite" in firebase
        if eventAlreadyFavorited {
            firebaseDatabaseRef.child("favorited").child(userID).child(event.id).removeValue()
            
            event.favorite = false
        }
        
    })
    
}

//Attend a particular event in Firebase
func attendFirebaseEvent(event: Event){
    
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    //Mark that the user is attending the event in Firebase
    //Add user to list of users attending the event and add event to the list of events that the user attended
    firebaseDatabaseRef.child("attendingEvents").child(event.id).child(userID).setValue(userID)
    
    firebaseDatabaseRef.child("attendingUsers").child(userID).child(event.id).setValue("NYC")
    

   //Update the count of users attending the event.  If no one is attending, set the count to 1.
    firebaseDatabaseRef.child("events").child(event.city).child(event.id).child("userCount").observeSingleEvent(of: .value, with: { snapshot in
        if !snapshot.exists() {
                firebaseDatabaseRef.child("events").child(event.city).child(event.id).child("userCount").setValue(1)
                selectedEvent.userCount = 1
            
        } else {
            if var count = snapshot.value as? Int {
                count = count + 1
                print("NEW COUNT")
                print(count)
                firebaseDatabaseRef.child("events").child(event.city).child(event.id).child("userCount").setValue(count)
                selectedEvent.userCount = count
            }
        }
    })
    
    
}

func unattendFirebaseEvent(event: Event){
    
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    //User is no longer attending the event, so remove all of the "attending" user and event data from Firebase
    firebaseDatabaseRef.child("attendingEvents").child(event.id).child(userID).removeValue()
    
    firebaseDatabaseRef.child("attendingUsers").child(userID).child(event.id).removeValue()
    
    //Update the count of users attending the event.
    firebaseDatabaseRef.child("events").child(event.city).child(event.id).child("userCount").observeSingleEvent(of: .value, with: { snapshot in
        
        if var count = snapshot.value as? Int {
            count = count - 1
            print("NEW COUNT")
            print(count)
            firebaseDatabaseRef.child("events").child(event.city).child(event.id).child("userCount").setValue(count)
            selectedEvent.userCount = count
        }
        
    })
    
}

//Get coordinates for event address so they can be provided to GeoFire when event is created
func getCoordinates(forAddress address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
    let geocoder = CLGeocoder()
    geocoder.geocodeAddressString(address) {
        (placemarks, error) in
        guard error == nil else {
            print("Geocoding error: \(error!)")
            completion(nil)
            return
        }
        completion(placemarks?.first?.location?.coordinate)
    }
}

//Insert a GeoFire event into Firebase database using Event address and ID
//Send a callback to the calling method with a bool to indicate if event was created successfully
func insertGeofireEvent(location: CLLocation, eventID: String, callback: ((Bool) -> Void)?){
    geoFire.setLocation(location, forKey: eventID) { (error) in
        if (error != nil) {
            print("An error occured: \(error)")
            callback!(false)
        } else {
            print("Saved location successfully: " + eventID)
            callback!(true)
        }
    }
}

func userIsNotLoggedIn() -> Bool{
    guard Auth.auth().currentUser?.uid != nil else { return true }
    return false
}

func getFirebaseDateFormatYYYYMDD(date: Date) -> String {
    //Return dateString used to map events with dates in Firebase
    //The format looks like so "2019m5d22"
     let calendar = Calendar.current
     let dateString = String(calendar.component(.year, from: date)) + "m" + String(calendar.component(.month, from: date)) + "d" + String(calendar.component(.day, from: date))
    return dateString
}

func displayInvalidLocationAlert(viewController: UIViewController) {
    let alertController = UIAlertController(title: "Invalid Location Entered", message: "Please enter valid location/address and try again", preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    
    alertController.addAction(defaultAction)
    viewController.present(alertController, animated: true, completion: nil)
}

