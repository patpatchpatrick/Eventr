//
//  FirebaseDeletions.swift
//  Eventr
//
//  Created by Patrick Doyle on 6/10/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import Firebase
import GeoFire
import MapKit

//Class to delete data from Firebase

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
    /**
     if event.loggedInUserCreatedTheEvent == false {
     print("LOGGEDINUSERCREATEERRROR")
     callback!(false)
     return}
     **/
    
    
    //Delete every reference to the event (events, created, date and geoFire)
    //User specific references to the event (upvotes, favorited, etc...) are not deleted when the event is deleted
    firebaseDatabaseRef.child("events").child(event.city).child(event.id).removeValue()
    firebaseDatabaseRef.child("events-category").child(event.city).child(String(event.category.index())).child(event.id).removeValue()
    firebaseDatabaseRef.child("event-city").child(event.id).child(event.city).removeValue()
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
    
    firebaseDatabaseRef.child("user-settings").child(userID).removeValue()
    
    //Delete username if it exists
    queryIfUserHasUsername(callback: {
        userHasUsername, username in
        if userHasUsername {
            firebaseDatabaseRef.child("users").child(userID).child("username").removeValue()
            firebaseDatabaseRef.child("active_usernames").child(username).removeValue()
        }
    })
    
    
    callback!(true) //Send callback viewController to let it know that event was deleted successfully
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



