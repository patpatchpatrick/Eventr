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

//Class to handle creations and updates in Firebase and general methods related to Firebase communication

//Create a firebase event
//This method will write all necessary data to firebase for an event when a new event is created
//First it will create an event in the Events section of the database
//Then, it will create an event in the GeoFire section of the database so the event can be searched by location
//Then, it will create an event in the Dates section of the database so the event can be searched by date (and removed from database when the date has passed)
func createOrUpdateFirebaseEvent(viewController: UIViewController, event: Event, createOrUpdate: eventAction, callback: ((Bool) -> Void)?){
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
        let firebaseCategoryEvent : DatabaseReference = firebaseDatabaseRef.child("events-category").child(event.city).child(String(event.category.index())).child(event.id)
        
        firebaseCategoryEvent.setValue(eventCategoryData)
        
        //Map the firebase event to the appropriate date in the database
        let firebaseDate = getFirebaseDateFormatYYYYMDD(date: eventDate)
        
    firebaseDatabaseRef.child("date").child(firebaseDate).child(event.id).setValue(event.id)
        
        
        //Map the firebase event to the "created" events section of Firebase
        firebaseDatabaseRef.child("created").child(userID).child(event.id).setValue(event.city)
        
        //Add the event to the event-city section of firebase used to find events based on the city
        firebaseDatabaseRef.child("event-city").child(event.id).child(event.city).setValue(event.city)
       
    
    }
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

//Attend a particular event in Firebase
func attendFirebaseEvent(event: Event){
    
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    //Mark that the user is attending the event in Firebase
    //Add user to list of users attending the event and add event to the list of events that the user attended
    //Gather data that will be stored under the list of events the user is attending in firebase
    //This data is used when querying events that other users are attending in the "Friends" view controller
    guard let eventDate = event.GMTDate else {return}
    let eventDateDouble = Double(eventDate.timeIntervalSince1970)
    let paidString = (event.paid) ? "1" : "0"
    let eventAttendingData = [
        "name":  event.name,
        "category": event.category.index(),
        "date": eventDateDouble,
        "dateSort": 0 - eventDateDouble,
        "duration": event.duration,
        "city": event.city,
        "paid" : paidString,
        "price" : event.price,
        ] as [String : Any]
    
    firebaseDatabaseRef.child("attendingEvents").child(event.id).child(userID).setValue(userID)
    firebaseDatabaseRef.child("attendingUsers").child(userID).child(event.id).setValue(eventAttendingData)
    
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
    let alertController = UIAlertController(title: "Invalid Location Entered Or No Connection", message: "Please enter valid location/address and ensure phone has proper wireless connection and try again", preferredStyle: .alert)
    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    
    alertController.addAction(defaultAction)
    viewController.present(alertController, animated: true, completion: nil)
}

func submitUserNameIfUnique(username: String, callback: @escaping ((Bool) -> Void)){
    
    guard let userID = Auth.auth().currentUser?.uid else { return}
    
    //Submit a new username to Firebase if it doesn't exist
    //If it does exist, use a callback to let user know that they need to choose a new username
    
    //Check if username is taken already
    firebaseDatabaseRef.child("active_usernames").child(username).observeSingleEvent(of: .value, with: {(usernameSnap) in
        
        if usernameSnap.exists(){
            //Username taken
            callback(false)
            
        }else{
            //Username available
            //Set username as child in active usernames field of Firebase with the userID as the value
           firebaseDatabaseRef.child("active_usernames").child(username).setValue(userID)
            firebaseDatabaseRef.child("users").child(userID).child("username").setValue(username)
            callback(true)
        }
        
    })
    
}

func submitNameToFirebase(name: String){
    
    guard let userID = Auth.auth().currentUser?.uid else { return}
    
    firebaseDatabaseRef.child("user-settings").child(userID).child("name").setValue(name)
    
}

func addFriendToFirebaseFollowers(friend: Friend){
    
    //Follow the friend in Firebase
    //Add the userID of the follower and the followee to the respective sections in Firebase as the key
    //Also add both usernames to the same section as the value (used for displaying username in friendsEventTableView)
    //Increment the number of followers for the friend that is being followed
    //Add an already approved follow request to both the user and the friend.  
    
    guard let userID = Auth.auth().currentUser?.uid else { return}
    
    queryIfUserHasUsername(callback: {
        userHasUsername, username in
        if userHasUsername {
         
            firebaseDatabaseRef.child("following").child(userID).child(friend.userID).setValue(friend.name)
            
            firebaseDatabaseRef.child("followers").child(friend.userID).child(userID).setValue(username)
            
            firebaseDatabaseRef.child("follow-count").child(friend.userID).child("number").observeSingleEvent(of: .value, with: {(numberOfFollowersSnap) in
                
                if numberOfFollowersSnap.exists(){
                    guard var numberOfFollowers = numberOfFollowersSnap.value as? Int else {return}
                    numberOfFollowers += 1
                    firebaseDatabaseRef.child("follow-count").child(friend.userID).child("number").setValue(numberOfFollowers)
                }else{
                    firebaseDatabaseRef.child("follow-count").child(friend.userID).child("number").setValue(1)
                }
                
            })
            
            firebaseDatabaseRef.child("follow-requests-sent").child(userID).child(friend.userID).setValue(FRIEND_REQUEST_APPROVED)
            
            firebaseDatabaseRef.child("follow-requests-rec").child(friend.userID).child(userID).setValue(FRIEND_REQUEST_APPROVED)
            
            
            reloadFriendTableView()
            
            
        }
    })
    
}

func approveFriendRequestInFirebase(friend: Friend, callback: @escaping ((Bool) -> Void)){
    
    //Approve a friend request in Firebase
    //Add the userID of the follower and the followee to the respective sections in Firebase as the key
    //Also add both usernames to the same section as the value (used for displaying username in friendsEventTableView)
    //Increment the number of followers for the user that is being followed
    //Set the follow request status to "APPROVED"
    
    
    guard let userID = Auth.auth().currentUser?.uid else { return}
    
    queryIfUserHasUsername(callback: {
        userHasUsername, username in
        if userHasUsername {
            
            firebaseDatabaseRef.child("following").child(friend.userID).child(userID).setValue(username)
            
            firebaseDatabaseRef.child("followers").child(userID).child(friend.userID).setValue(friend.name)
            
            firebaseDatabaseRef.child("follow-count").child(userID).child("number").observeSingleEvent(of: .value, with: {(numberOfFollowersSnap) in
                
                if numberOfFollowersSnap.exists(){
                    guard var numberOfFollowers = numberOfFollowersSnap.value as? Int else {return}
                    numberOfFollowers += 1
                    firebaseDatabaseRef.child("follow-count").child(friend.userID).child("number").setValue(numberOfFollowers)
                }else{
                    firebaseDatabaseRef.child("follow-count").child(friend.userID).child("number").setValue(1)
                }
                
            })
            
            approveFollowRequestInFirebase(friend: friend, callback: callback)
            
            
        }
    })

}

func sendFriendRequestInFirebase(friend: Friend){
    
    guard let userID = Auth.auth().currentUser?.uid else { return}
    
    //Add a new friend request to both users (sending and receiving) and mark them as NOT_APPROVED by default
    //Friend request is sent if the user has a private account.. it needs to be approved by the user before they are followed
    firebaseDatabaseRef.child("follow-requests-sent").child(userID).child(friend.userID).setValue(FRIEND_REQUEST_NOT_APPROVED)
    
    firebaseDatabaseRef.child("follow-requests-rec").child(friend.userID).child(userID).setValue(FRIEND_REQUEST_NOT_APPROVED)
    
    firebaseDatabaseRef.child("request-count").child(friend.userID).child("number").observeSingleEvent(of: .value, with: {(numberOfRequestsSnap) in
        
        if numberOfRequestsSnap.exists(){
            guard var numberOfFollowRequests = numberOfRequestsSnap.value as? Int else {return}
            numberOfFollowRequests += 1
            firebaseDatabaseRef.child("request-count").child(friend.userID).child("number").setValue(numberOfFollowRequests)
        }else{
            firebaseDatabaseRef.child("request-count").child(friend.userID).child("number").setValue(1)
        }
        
    })
    
    reloadFriendTableView()
    
}

func setPrivateAccountStatusInFirebase(accountIsPrivate: Bool){
    
     guard let userID = Auth.auth().currentUser?.uid else { return}
    
    var accountIsPrivateInt = 0
    if accountIsPrivate {
        accountIsPrivateInt = 1
    }
    
    firebaseDatabaseRef.child("user-settings").child(userID).child("private").setValue(accountIsPrivateInt)
    
}

func approveFollowRequestInFirebase(friend: Friend, callback: @escaping ((Bool) -> Void)){
    
    guard let userID = Auth.auth().currentUser?.uid else { return }
    firebaseDatabaseRef.child("follow-requests-sent").child(friend.userID).child(userID).setValue(FRIEND_REQUEST_APPROVED)
    
    firebaseDatabaseRef.child("follow-requests-rec").child(userID).child(friend.userID).setValue(FRIEND_REQUEST_APPROVED)
    
    callback(true)
    
}


