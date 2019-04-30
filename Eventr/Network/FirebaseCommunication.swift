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
//Return list of events
func queryFirebaseEventsInRadius(centerLocation: CLLocation, radius: Double, callback: ((Bool) -> Void)?){
    events.removeAll()
    _ = geoFire.query(at: centerLocation, withRadius: radius).observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
        print("KEY" + key)
        firebaseDatabaseRef.child("Events").child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get dictionary of event data
            let value = snapshot.value as? NSDictionary
            print("DICT: " + value!.description)
            if value != nil {
                events.append(Event(dict: value!))
                callback!(true)
            }
        }) { (error) in
            print("TESTERROR" + error.localizedDescription)
        }
    })
    
}

//Create a firebase event
//This method will write all necessary data to firebase for an event when a new event is created
//First it will create an event in the Events child of firebase
//Then, it will create an event in the GeoFire child of firebase so it can be searched by location
func createFirebaseEvent(event: Event, callback: ((Bool) -> Void)?){
    if Auth.auth().currentUser != nil {
        let eventData = [
            "name":  event.name,
            "description": event.details,
            "location":   event.address,
            "ticketURL":   event.ticketURL,
            "eventURL":   event.eventURL,
            "contact":   event.contact,
            "tags":   event.tags
        ]
        let firebaseEvent = firebaseDatabaseRef.child("Events").childByAutoId()
        let eventKey = firebaseEvent.key
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


