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

let firebaseDatabaseRef = Database.database().reference()
let geoFireDatabase = firebaseDatabaseRef.child("geofire")
let geoFire = GeoFire(firebaseRef: geoFireDatabase)

//Insert an event into Firebase database using Event location and ID
func insertFirebaseEvent(location: CLLocation, eventID: String){
    geoFire.setLocation(location, forKey: eventID) { (error) in
        if (error != nil) {
            print("An error occured: \(error)")
        } else {
            print("Saved location successfully: " + eventID)
        }
    }
}

//Query list of events within a certain radius (km) of a location
func queryFirebaseEventsInRadius(centerLocation: CLLocation, radius: Double){
    var circleQuery = geoFire.query(at: centerLocation, withRadius: radius).observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
        print("Key '\(key)' entered the search area and is at location '\(location)'")
    })
    
}


