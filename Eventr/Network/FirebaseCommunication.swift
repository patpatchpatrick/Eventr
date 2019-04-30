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
func queryFirebaseEventsInRadius(centerLocation: CLLocation, radius: Double){
    var circleQuery = geoFire.query(at: centerLocation, withRadius: radius).observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
        print("Key '\(key)' entered the search area and is at location '\(location)'")
    })
    
}

//Create a firebase event
//This method will write all necessary data to firebase for an event when a new event is created
//First it will create an event in the Events child of firebase
//Then, it will create an event in the GeoFire child of firebase so it can be searched by location
func createFirebaseEvent(event: Event){
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
                        insertGeofireEvent(location: initialLocation, eventID: eventKey!)
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
func insertGeofireEvent(location: CLLocation, eventID: String){
    geoFire.setLocation(location, forKey: eventID) { (error) in
        if (error != nil) {
            print("An error occured: \(error)")
        } else {
            print("Saved location successfully: " + eventID)
        }
    }
}


