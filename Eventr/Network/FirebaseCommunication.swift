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
                let value = snapshot.value as? NSDictionary
                if value != nil {
                    //Check if event has already been upvoted by user
                    let event = Event(dict: value!, idKey: eventID)
                    checkIfUpvoted: if Auth.auth().currentUser != nil {
                        guard let userID = Auth.auth().currentUser?.uid else {
                            break checkIfUpvoted
                        }
                        firebaseDatabaseRef.child("users").child(userID).child("upvoted").observeSingleEvent(of: .value, with: {
                            (snapshot) in
                            guard let dict = snapshot.value as? NSDictionary else {
                                return
                            }
                            
                            _ = dict.allValues.contains { element in
                                if case element as! String = eventID {
                                    event.upvoted = true
                                    //Notify the tableview to relaod
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
                    //Add event to table view events list and update table
                    events.append(event)
                    //Notify the tableview to relaod
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
//First it will create an event in the Events child of firebase
//Then, it will create an event in the GeoFire child of firebase so it can be searched by location
func createFirebaseEvent(event: Event, callback: ((Bool) -> Void)?){
    if Auth.auth().currentUser != nil {
        let paidString = (event.paid) ? "1" : "0"
        let eventData = [
            "name":  event.name,
            "category": event.category.text(),
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
        let firebaseEvent = firebaseDatabaseRef.child("events").childByAutoId()
        let eventKey = firebaseEvent.key
        if eventKey != nil {
            event.id = eventKey!
        }
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
                    if eventKey != nil {
                        insertGeofireEvent(location: initialLocation, eventID: eventKey!, callback: callback)
                    }
                }
            }
        })
        
    }
}

//Increase number of upvotes for a particular event in Firebase
func upvoteFirebaseEvent(event: Event){
    if Auth.auth().currentUser != nil {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        firebaseDatabaseRef.child("users").child(userID).child("upvoted").observeSingleEvent(of: .value, with: {
            (snapshot) in
            let dict = snapshot.value as? NSDictionary
            //Check if event has already been upvoted
            let eventAlreadyUpvoted = dict?.allValues.contains { element in
                if case element as! String = event.id {
                    return true
                } else {
                    return false
                }
            }
            //Event was not yet upvoted, so upvote the event
            if eventAlreadyUpvoted == nil || !eventAlreadyUpvoted! {
                //Increment the overall upvote count of the event in the events section of firebase
                //Also add the event to the users section of firebase so it can't be upvoted again
                firebaseDatabaseRef.child("events").child(event.id).observeSingleEvent(of: .value, with: {
                    (snapshot) in
                    let dict = snapshot.value as? NSDictionary
                    if dict!["upvotes"] != nil {
                        let upvoteCountString = dict!["upvotes"] as! String
                        var upvoteCount = Int(upvoteCountString)!
                        upvoteCount += 1
                        firebaseDatabaseRef.child("events").child(event.id).updateChildValues(["upvotes": String(upvoteCount)])
                        firebaseDatabaseRef.child("users").child(userID).child("upvoted").childByAutoId().setValue(event.id)
                        
                        event.upvoted = true
                        event.upvoteCount += 1
                        //Notify the tableview to relaod
                        NotificationCenter.default.post(name: Notification.Name("UPDATED_EVENT_DATA"), object: nil)
                    }
                    
                })
                
            } else {
                //Event was already upvoted so return
                return
            }
    
            
        })
        
    }
}

//Remove an upvote for a particular event in Firebase
//This method is called if an event has already been upvoted by a user and they want to remove their upvote
func downvoteFirebaseEvent(event: Event){
    if Auth.auth().currentUser != nil {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        firebaseDatabaseRef.child("users").child(userID).child("upvoted").observeSingleEvent(of: .value, with: {
            (snapshot) in
            let dict = snapshot.value as? NSDictionary
            //Check if event has already been upvoted
            let eventAlreadyUpvoted = dict?.allValues.contains { element in
                if case element as! String = event.id {
                    return true
                } else {
                    return false
                }
            }
            //Ensure that event was already upvoted by user, and if so, lower the upvote cuont by 1
            if eventAlreadyUpvoted != nil && eventAlreadyUpvoted! {
                //Decrement the overall upvote count of the event in the events section of firebase
                //Also remove the event from the users section of firebase so it can't be upvoted again
                firebaseDatabaseRef.child("events").child(event.id).observeSingleEvent(of: .value, with: {
                    (snapshot) in
                    let dict = snapshot.value as? NSDictionary
                    if dict!["upvotes"] != nil {
                        let upvoteCountString = dict!["upvotes"] as! String
                        var upvoteCount = Int(upvoteCountString)!
                        upvoteCount -= 1
                        firebaseDatabaseRef.child("events").child(event.id).updateChildValues(["upvotes": String(upvoteCount)])
                       
                        firebaseDatabaseRef.child("users").child(userID).child("upvoted").queryOrderedByValue().queryEqual(toValue: event.id).observeSingleEvent(of: .value) { (querySnapshot) in
                            for result in querySnapshot.children {
                                let resultSnapshot = result as! DataSnapshot
                                let eventKey = resultSnapshot.key
                            firebaseDatabaseRef.child("users").child(userID).child("upvoted").child(eventKey).removeValue()
                            }
                        }
                        
                    
                        
                        event.upvoted = false
                        event.upvoteCount -= 1
                        //Notify the tableview to reload
                        NotificationCenter.default.post(name: Notification.Name("UPDATED_EVENT_DATA"), object: nil)
                    }
                    
                })
                
            } else {
                //Event was already upvoted so return
                return
            }
            
            
        })
        
    }
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


