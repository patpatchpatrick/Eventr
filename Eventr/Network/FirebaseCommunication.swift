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
        for key in keyList {
            let eventID = key
            firebaseDatabaseRef.child("events").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get dictionary of event data
                if let value = snapshot.value as? NSDictionary {
                    let event = Event(dict: value, idKey: eventID)
                    //Check if event has been favorited by user
                    queryIfFirebaseEventIsFavorited(event: event)
                    //Check if event has been upvoted by user
                    queryIfFirebaseEventIsUpvoted(event: event)
                    //Add event to table view events list and update table
                    events.append(event)
                    //Notify the tableview to reload
                    NotificationCenter.default.post(name: Notification.Name("UPDATED_EVENT_DATA"), object: nil)
                }
            }) { (error) in
                print("FB Query Error" + error.localizedDescription)
            }
        }
    }
    
    
    
}

//Create a firebase event
//This method will write all necessary data to firebase for an event when a new event is created
//First it will create an event in the Events section of the database
//Then, it will create an event in the GeoFire section of the database so the event can be searched by location
func createFirebaseEvent(event: Event, callback: ((Bool) -> Void)?){
    guard Auth.auth().currentUser != nil else { return }
    let paidString = (event.paid) ? "1" : "0"
    let eventData = [
        "name":  event.name,
        "category": event.category.text(),
        "date": String(event.date.timeIntervalSince1970),
        "description": event.details,
        "location":   event.address,
        "ticketURL":   event.ticketURL,
        "eventURL":   event.eventURL,
        "contact":   event.contact,
        "tag1":   event.tag1,
        "tag2":   event.tag2,
        "tag3":   event.tag3,
        "upvotes": String(event.upvoteCount),
        "paid" : paidString
    ]
    //Add the event to the "events" section of firebase
    let firebaseEvent = firebaseDatabaseRef.child("events").childByAutoId()
    guard let eventKey = firebaseEvent.key else { return }
    event.id = eventKey
    firebaseEvent.setValue(eventData, withCompletionBlock: { (error, snapshot) in
        if error != nil {
            print("Error writing event to Firebase")
        } else {
            //If event was successfully added to Firebase, add GeoFire event location to firebase
            getCoordinates(forAddress: event.address) {
                (location) in
                guard let location = location else {
                    //Handle geolocation error
                    return
                }
                let initialLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                insertGeofireEvent(location: initialLocation, eventID: eventKey, callback: callback)
                
            }
        }
    })
    
    
}

//Check to see if the event is marked as upvoted in firebase and update the event data and tableview accordingly
func queryIfFirebaseEventIsUpvoted(event: Event){
    guard Auth.auth().currentUser != nil else { return }
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    firebaseDatabaseRef.child("users").child(userID).child("upvoted").observeSingleEvent(of: .value, with: {
        (snapshot) in
        guard let dict = snapshot.value as? NSDictionary else { return }
        _ = dict.allValues.contains { element in
            if case element as! String = event.id {
                event.upvoted = true
                //Notify the tableview to reload
                NotificationCenter.default.post(name: Notification.Name("UPDATED_EVENT_DATA"), object: nil)
                return true
            } else {
                event.upvoted = false
                //Notify the tableview to relaod
                NotificationCenter.default.post(name: Notification.Name("UPDATED_EVENT_DATA"), object: nil)
                return false
            }
        }
    })
    
}

//Increase number of upvotes for a particular event in Firebase
func upvoteFirebaseEvent(event: Event){
    guard Auth.auth().currentUser != nil else { return }
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    //Check if event has already been upvoted
    firebaseDatabaseRef.child("users").child(userID).child("upvoted").observeSingleEvent(of: .value, with: {
        (snapshot) in
        guard let dict = snapshot.value as? NSDictionary else { return }
        let eventAlreadyUpvoted = dict.allValues.contains { element in
            if case element as! String = event.id { return true } else { return false}
        }
        
        //Upvote the event
        //Increment the overall upvote count of the event in Firebase
        //Add event to user's "upvoted" section of Firebase
        if !eventAlreadyUpvoted {
            firebaseDatabaseRef.child("events").child(event.id).observeSingleEvent(of: .value, with: {
                (snapshot) in
                guard let dict = snapshot.value as? NSDictionary else { return }
                guard let upvoteCountString = dict["upvotes"] as? String else { return }
                guard var upvoteCount = Int(upvoteCountString) else { return }
                upvoteCount += 1
                event.upvoted = true
                event.upvoteCount += 1
                firebaseDatabaseRef.child("events").child(event.id).updateChildValues(["upvotes": String(upvoteCount)])
            firebaseDatabaseRef.child("users").child(userID).child("upvoted").childByAutoId().setValue(event.id)
                
                    //Notify the tableview to reload
                    NotificationCenter.default.post(name: Notification.Name("UPDATED_EVENT_DATA"), object: nil)
                
            })
        }
    })
    
    
}

//Remove an upvote for event in Firebase
func removeUpvoteFromFirebaseEvent(event: Event){
    guard Auth.auth().currentUser != nil else { return }
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
            firebaseDatabaseRef.child("events").child(event.id).observeSingleEvent(of: .value, with: {
                (snapshot) in
                guard let dict = snapshot.value as? NSDictionary else { return }
                guard let upvoteCountString = dict["upvotes"] as? String else { return }
                guard var upvoteCount = Int(upvoteCountString) else { return }
                upvoteCount -= 1
                event.upvoted = false
                event.upvoteCount -= 1
                firebaseDatabaseRef.child("events").child(event.id).updateChildValues(["upvotes": String(upvoteCount)])
                
                firebaseDatabaseRef.child("users").child(userID).child("upvoted").queryOrderedByValue().queryEqual(toValue: event.id).observeSingleEvent(of: .value) { (querySnapshot) in
                    for result in querySnapshot.children {
                        let resultSnapshot = result as! DataSnapshot
                        let eventKey = resultSnapshot.key
                        firebaseDatabaseRef.child("users").child(userID).child("upvoted").child(eventKey).removeValue()
                    }
                }
                
                //Notify the tableview to reload
                NotificationCenter.default.post(name: Notification.Name("UPDATED_EVENT_DATA"), object: nil)
                
            })
        }
        
    })
    
    
}

//Mark a particular event in Firebase as a "favorite"
func favoriteFirebaseEvent(event: Event){
    guard Auth.auth().currentUser != nil else { return }
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    //Check if event has already been favorited
    firebaseDatabaseRef.child("favorited").child(userID).observeSingleEvent(of: .value, with: {
        (snapshot) in
        guard let dict = snapshot.value as? NSDictionary else { return }
        let eventAlreadyFavorited = dict.allValues.contains { element in
            if case element as! String = event.id { return true } else { return false }
        }
        
        //Mark the event as "favorite" in Firebase
        if !eventAlreadyFavorited {
            firebaseDatabaseRef.child("favorited").child(userID).childByAutoId().setValue(event.id)
        }
        
    })
    
}

//Unmark an event as "favorite" in Firebase
func unfavoriteFirebaseEvent(event: Event){
    guard Auth.auth().currentUser != nil else { return }
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    //Check if event has already been favorited
    firebaseDatabaseRef.child("favorited").child(userID).observeSingleEvent(of: .value, with: {
        (snapshot) in
        guard let dict = snapshot.value as? NSDictionary else { return }
        let eventAlreadyFavorited = dict.allValues.contains { element in
            if case element as! String = event.id { return true } else { return false }
        }
        
        //Unmark the event as "favorite" in firebase
        if eventAlreadyFavorited {
            firebaseDatabaseRef.child("favorited").child(userID).queryOrderedByValue().queryEqual(toValue: event.id).observeSingleEvent(of: .value) { (querySnapshot) in
                for result in querySnapshot.children {
                    let resultSnapshot = result as! DataSnapshot
                    let eventKey = resultSnapshot.key
                    firebaseDatabaseRef.child("favorited").child(userID).child(eventKey).removeValue()
                    
                    event.favorite = false
                    
                    //Notify the tableview to reload
                    NotificationCenter.default.post(name: Notification.Name("UPDATED_EVENT_DATA"), object: nil)
                }
            }
        }
        
    })
    
}


//Query a firebase event to determine if it was favorited
func queryIfFirebaseEventIsFavorited(event: Event){
    guard Auth.auth().currentUser != nil else { return }
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
            NotificationCenter.default.post(name: Notification.Name("UPDATED_EVENT_DATA"), object: nil)
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


