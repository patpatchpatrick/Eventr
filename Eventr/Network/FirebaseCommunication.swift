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

//Class to handle communication with Firebase

let firebaseDatabaseRef = Database.database().reference()
let geoFireDatabase = firebaseDatabaseRef.child("geofire")
let geoFire = GeoFire(firebaseRef: geoFireDatabase)

//Query list of events within a certain radius (km) of a location
//Get the keys(eventIDs) of the events within the specified radius
//Query firebase for event data for each of the keys and build events
//Set the events list to include the queried events data and reload the tableview
func queryFirebaseEventsInRadius(centerLocation: CLLocation, radius: Double){
    events.removeAll()
    var keyList: [String] = []
    
    //Query to find all keys(event IDs) within radius of location
    let gQuery = geoFire.query(at: centerLocation, withRadius: radius)
    gQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
        keyList.append(key)
    })
    
    //Method called when the query is finished and all keys(event IDs) are loaded
    gQuery.observeReady {
        addEventsToEventTableView(eventsList: keyList, isUserCreatedEvent: false, searchCriteriaIsRequired: true)
    }
    
    
}

//Query list of Firebase events that were favorited by the user and add them to the eventsTableView
func queryFirebaseFavoriteEvents(){
    
    guard let userID = Auth.auth().currentUser?.uid else { return }
    events.removeAll()
    firebaseDatabaseRef.child("favorited").child(userID).observeSingleEvent(of: .value, with: {
        (snapshot) in
        guard let dict = snapshot.value as? NSDictionary else { return }
        var favoriteEvents : [String] = []
        for value in dict.allValues {
            if let eventString = value as? String {
                print("EVENT STRING " + eventString)
                favoriteEvents.append(eventString)
            }
        }
        addEventsToEventTableView(eventsList: favoriteEvents, isUserCreatedEvent: false, searchCriteriaIsRequired: false)
    })
    
}

//Query list of Firebase events that were created by the user and add them to the eventsTableView
func queryFirebaseCreatedEvents(){
    
    guard let userID = Auth.auth().currentUser?.uid else { return }
    events.removeAll()
    firebaseDatabaseRef.child("created").child(userID).observeSingleEvent(of: .value, with: {
        (snapshot) in
        guard let dict = snapshot.value as? NSDictionary else { return }
        var createdEvents : [String] = []
        for value in dict.allValues {
            if let eventString = value as? String {
                print("EVENT STRING " + eventString)
                createdEvents.append(eventString)
            }
        }
        addEventsToEventTableView(eventsList: createdEvents, isUserCreatedEvent: true, searchCriteriaIsRequired: false)
    })
    
}

func addEventsToEventTableView(eventsList: Array<String>, isUserCreatedEvent: Bool, searchCriteriaIsRequired: Bool){
    for eventID in eventsList {
        firebaseDatabaseRef.child("events").child(eventID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get dictionary of event data
            if let value = snapshot.value as? NSDictionary {
                let event = Event(dict: value, idKey: eventID)
                if isUserCreatedEvent {
                    event.loggedInUserCreatedTheEvent = true //Mark if the user created the event
                }
                //Check if event has been favorited by user
                queryIfFirebaseEventIsFavorited(event: event)
                //Check if event has been upvoted by user
                queryIfFirebaseEventIsUpvoted(event: event)
                
                //Check if event meets search criteria (date and category)
                //If so, add event to table view events list and update table
                if searchCriteriaIsRequired{
                    if let eventDate = event.date{
                        if eventDate > fromDate && eventDate < toDate {
                            if selectedCategory == 0 || event.category.index() == selectedCategory {
                                let index = events.insertionIndexOf(elem: event, isOrderedBefore: >)
                                events.insert(event, at: index)
                                reloadEventTableView()
                            }
                        }
                    }
                } else {
                    //Add event to tableview without search criteria check
                    let index = events.insertionIndexOf(elem: event, isOrderedBefore: >)
                    events.insert(event, at: index)
                    reloadEventTableView()
                }
            }
        }) { (error) in
            print("FB Query Error" + error.localizedDescription)
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
    guard let eventDate = event.date else {return}
    getCoordinates(forAddress: event.location) {
        (location) in
        guard let location = location else {
            //Ensure that event has a valid location before continuing and inserting event into Firebase database
            displayInvalidLocationAlert(viewController: viewController)
            return
        }
        let initialLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        
        let paidString = (event.paid) ? "1" : "0"
        let eventData = [
            "name":  event.name,
            "category": event.category.text(),
            "date": String(eventDate.timeIntervalSince1970),
            "description": event.details,
            "location":   event.location,
            "ticketURL":   event.ticketURL,
            "eventURL":   event.eventURL,
            "contact":   event.contact,
            "phone": event.phoneNumber,
            "tag1":   event.tag1,
            "tag2":   event.tag2,
            "tag3":   event.tag3,
            "upvotes": String(event.upvoteCount),
            "paid" : paidString
        ]
        //Add the event to the "events" section of firebase
        //If event is being created for first time, generate an autoID
        //If event is being updated, the child will be the eventID
        let firebaseEvent : DatabaseReference = {
            switch createOrUpdate {
            case .creating:
                return firebaseDatabaseRef.child("events").childByAutoId()
            case .editing:
                return firebaseDatabaseRef.child("events").child(selectedEvent.id)
            }
        }()
        guard let eventKey = firebaseEvent.key else { return }
        event.id = eventKey
        firebaseEvent.setValue(eventData, withCompletionBlock: { (error, snapshot) in
            if error != nil {
                print("Error writing event to Firebase")
            } else {
                //If event was successfully added to Firebase, add GeoFire event location to firebase
                insertGeofireEvent(location: initialLocation, eventID: eventKey, callback: callback)
            }
        })
        
        
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
        
        if createOrUpdate == .creating {
            //Map the firebase event to the "created" events section of Firebase
            firebaseDatabaseRef.child("created").child(userID).child(event.id).setValue(event.id)
        }
       
    
    
        
        
    }
}

func deleteFirebaseEvent(event: Event, callback: ((Bool) -> Void)?) {
    
    guard let userID = Auth.auth().currentUser?.uid else {
        callback!(false)
        return }
    
    guard let eventDate = event.date else {
        callback!(false)
        return
    }
    
    if event.loggedInUserCreatedTheEvent == false {
        callback!(false)
        return} //If event was not created by user, do not delete it
    
    //Delete every reference to the event (events, created, date and geoFire)
    //User specific references to the event (upvotes, favorited, etc...) are not deleted when the event is deleted
    firebaseDatabaseRef.child("events").child(event.id).removeValue()
    firebaseDatabaseRef.child("created").child(userID).child(event.id).removeValue()
    let firebaseDate = getFirebaseDateFormatYYYYMDD(date: eventDate)
    //firebaseDatabaseRef.child("date").child(firebaseDate).child(event.id).removeValue()
    //Don't delete the date of the event for now when it is deleted... this date may be used to auto-delete upvotes and favorited events in the future
    firebaseDatabaseRef.child("geofire").child(event.id).removeValue()
    callback!(true) //Send callback viewController to let it know that event was deleted successfully
}

//Check to see if the event is marked as upvoted in firebase and update the event data and tableview accordingly
func queryIfFirebaseEventIsUpvoted(event: Event){

    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    firebaseDatabaseRef.child("users").child(userID).child("upvoted").observeSingleEvent(of: .value, with: {
        (snapshot) in
        guard let dict = snapshot.value as? NSDictionary else { return }
        _ = dict.allValues.contains { element in
            if case element as! String = event.id {
                event.upvoted = true
                reloadEventTableView()
                return true
            } else {
                event.upvoted = false
                reloadEventTableView()
                return false
            }
        }
    })
    
}

//Increase number of upvotes for a particular event in Firebase
func upvoteFirebaseEvent(event: Event){
    
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    //Check if event has already been upvoted
    firebaseDatabaseRef.child("users").child(userID).child("upvoted").observeSingleEvent(of: .value, with: {
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
            firebaseDatabaseRef.child("events").child(event.id).observeSingleEvent(of: .value, with: {
                (snapshot) in
                guard let dict = snapshot.value as? NSDictionary else { return }
                guard let upvoteCountString = dict["upvotes"] as? String else { return }
                guard var upvoteCount = Int(upvoteCountString) else { return }
                upvoteCount += 1
                firebaseDatabaseRef.child("events").child(event.id).updateChildValues(["upvotes": String(upvoteCount)])
            firebaseDatabaseRef.child("users").child(userID).child("upvoted").childByAutoId().setValue(event.id)
               
            })
        }
    })
    
    
}

//Remove an upvote for event in Firebase
func removeUpvoteFromFirebaseEvent(event: Event){

    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    //Check if event has already been upvoted
    firebaseDatabaseRef.child("users").child(userID).child("upvoted").observeSingleEvent(of: .value, with: {
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
            firebaseDatabaseRef.child("events").child(event.id).observeSingleEvent(of: .value, with: {
                (snapshot) in
                guard let dict = snapshot.value as? NSDictionary else { return }
                guard let upvoteCountString = dict["upvotes"] as? String else { return }
                guard var upvoteCount = Int(upvoteCountString) else { return }
                upvoteCount -= 1
                firebaseDatabaseRef.child("events").child(event.id).updateChildValues(["upvotes": String(upvoteCount)])
                
                firebaseDatabaseRef.child("users").child(userID).child("upvoted").queryOrderedByValue().queryEqual(toValue: event.id).observeSingleEvent(of: .value) { (querySnapshot) in
                    for result in querySnapshot.children {
                        let resultSnapshot = result as! DataSnapshot
                        let eventKey = resultSnapshot.key
                        firebaseDatabaseRef.child("users").child(userID).child("upvoted").child(eventKey).removeValue()
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
                eventAlreadyFavorited = dict!.allValues.contains { element in
                if case element as! String = event.id { return true } else { return false }
            }
        }
        
        //If not favorited, mark the event as "favorite" in Firebase
        if !eventAlreadyFavorited {
            firebaseDatabaseRef.child("favorited").child(userID).childByAutoId().setValue(event.id)
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
        let eventAlreadyFavorited = dict.allValues.contains { element in
            if case element as! String = event.id { return true } else { return false }
        }
        
        //If favorited, unmark the event as "favorite" in firebase
        if eventAlreadyFavorited {
            firebaseDatabaseRef.child("favorited").child(userID).queryOrderedByValue().queryEqual(toValue: event.id).observeSingleEvent(of: .value) { (querySnapshot) in
                for result in querySnapshot.children {
                    let resultSnapshot = result as! DataSnapshot
                    let eventKey = resultSnapshot.key
                    firebaseDatabaseRef.child("favorited").child(userID).child(eventKey).removeValue()
                    
                    event.favorite = false
                    
                }
            }
        }
        
    })
    
}


//Query a firebase event to determine if it was favorited
func queryIfFirebaseEventIsFavorited(event: Event){
    
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
     //Check if event has already been favorited
    firebaseDatabaseRef.child("favorited").child(userID).observeSingleEvent(of: .value, with: {
        (snapshot) in
        guard let dict = snapshot.value as? NSDictionary else { return }
        let eventAlreadyFavorited = dict.allValues.contains { element in
            if case element as! String = event.id { return true } else { return false }
        }
        
        //If event was marked as favorite, set the event's favorited variable to true
        if eventAlreadyFavorited {
            event.favorite = true
            reloadEventTableView()
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
