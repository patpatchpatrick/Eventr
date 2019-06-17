//
//  FirebaseQueries.swift
//  Eventr
//
//  Created by Patrick Doyle on 5/28/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import Firebase
import GeoFire
import MapKit
import GoogleSignIn

//Class to track types of queries that can be performed in Firebase

//QUERY AND DATABASE REFS
var gQuery : GFCircleQuery? //The Geoquery used for all "Nearby" Queries
let firebaseDatabaseRef = Database.database().reference()
let geoFireDatabase = firebaseDatabaseRef.child("geofire")
let geoFire = GeoFire(firebaseRef: geoFireDatabase)
var googleUser: GIDGoogleUser?

enum fbQueryType {
    case popular
    case upcoming
    case nearby
}
var firebaseQueryType : fbQueryType = .popular //Query type - is popular by default

//PAGINATION VARIABLES
var paginationInProgress: Bool = true //Bool to represent if events are currently being paginated.  Variable starts at "TRUE" and will change to "FALSE" after first page has finished loading
var listDescriptorInUse: Bool = false
var mostRecentlyQueriedDate: Date?
var mostRecentlyQueriedUpvoteCount: Int?
let paginationFirstPageCount: UInt = 7
let paginationAddlPageCount: UInt = 10


//NEARBY EVENT QUERY VARIABLES
var nearbyEventPageCount: UInt = 0
var incrementingSearchRadius:Double = 0 //search radius (in miles) that increments until it reaches the user selected search radius.  This is used for pagination purposes (the search radius is slowly increased to ensure large queries aren't performed)
var searchDistanceMiles: Double = 5.0 //user selected search distance (miles)
var defaultSearchIncrement:Double = 0.5 //default search increment amount (in miles)
var nearbyEventPageCountLoaded: Bool = false //Bool to represent if the full count of nearby events has loaded.  This is used for Geofire pagination
var mostRecentlyQueriedLocation: CLLocation?
var currentLocation: CLLocation? //User's current location

//Query all upcoming events using the dates input by the user
func queryUpcomingEvents(city: String, queryingFirstPage: Bool){
    
    let beforeDate = Double((Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: fromDate)?.convertToTimeZone(initTimeZone: Calendar.current.timeZone, timeZone: TimeZone(secondsFromGMT: 0)!).timeIntervalSince1970)!)
    let afterDate = ((Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: toDate)?.convertToTimeZone(initTimeZone: Calendar.current.timeZone, timeZone: TimeZone(secondsFromGMT: 0)!).timeIntervalSince1970)!)
    let specificCategoryWasQueried = selectedCategory != categoryAll
    let firstPageFinishedQuerying = allEvents.count >= paginationFirstPageCount
    
    if queryingFirstPage{
        //First page query
        //Reset query variables and clear tableview when a new search has begun
        tableEvents.removeAll()
        allEvents.removeAll()
        clearEventTableView()
        mostRecentlyQueriedDate = nil
        paginationInProgress = false
        
       queryUpcomingEventsFirstPage(specificCategory: specificCategoryWasQueried, city: city, beforeDate: beforeDate, afterDate: afterDate)
        
    } else if firstPageFinishedQuerying {
             //Query an additional page
                    queryUpcomingEventsAdditionalPage(specificCategory: specificCategoryWasQueried, city: city, afterDate: afterDate)
            
        }}
    

//Query all events by popularity (upvote count)
func queryPopularEvents(city: String, queryingFirstPage: Bool){
    
    let specificCategoryWasQueried = selectedCategory != categoryAll
    let firstPageFinishedQuerying = allEvents.count >= paginationFirstPageCount
    
    if queryingFirstPage{
        
        //Reset query variables and clear tableview when a new search has begun
        tableEvents.removeAll()
        allEvents.removeAll()
        clearEventTableView()
        mostRecentlyQueriedUpvoteCount = nil
        paginationInProgress = false
        
        
     queryPopularEventsFirstPage(specificCategory: specificCategoryWasQueried, city: city)
        
        
    } else if firstPageFinishedQuerying  {
        print("QUERY ADDL PAGE")
        print("SPECIFIC CATEGORY")
        print(specificCategoryWasQueried)
        //Query an additional page
        if let lastUpvoteCount = mostRecentlyQueriedUpvoteCount{
            
                     queryPopularEventsAdditionalPage(specificCategory: specificCategoryWasQueried, city: city, lastUpvoteCount: lastUpvoteCount)
            
        }
    }
}
    
func queryUpcomingEventsFirstPage(specificCategory: Bool, city: String, beforeDate: TimeInterval, afterDate: TimeInterval){
    
    //Query all events between the before and after date selected by the user
    //Events are sorted by date in ascending order using "dateSort", which is equal to "0 - date" since Firebase can only sort in descending order
        
        if specificCategory {
            
            //Query data from the "events-category" section of Firebase since we are querying a specific category
            firebaseDatabaseRef.child("events-category").child(city).child(String(selectedCategory)).queryOrdered(byChild: "dateSort").queryStarting(atValue: 0 - afterDate ).queryEnding(atValue: 0 - beforeDate).queryLimited(toLast: paginationFirstPageCount).observeSingleEvent(of: .value, with: {
                (snapshot) in
                guard let dict = snapshot.value as? NSDictionary else { return }
                for eventID in dict.allKeys {
                    
                    addEventsToTableViewByKey(eventIDMap: [eventID : "NYC"], isUserCreatedEvent: false, addToListsInSortedOrder: true, addToAllEventsList: true)
                }
                
            })
        
        } else {
            
            //Since data is being queried for all events, we can query directly from the "Events" section of Firebase
            firebaseDatabaseRef.child("events").child(city).queryOrdered(byChild: "dateSort").queryStarting(atValue: 0 - afterDate).queryEnding(atValue: 0 - beforeDate).queryLimited(toLast: paginationFirstPageCount).observeSingleEvent(of: .value, with: {
                (snapshot) in
                guard let dict = snapshot.value as? NSDictionary else { return }
                addQueriedEventsToTableViewByValue(eventsList: dict)
            })
        
        }
    }
    
func queryUpcomingEventsAdditionalPage(specificCategory: Bool, city: String, afterDate: TimeInterval){
    
    //Query all events between the last query date and the after date selected by the user
    //Events are sorted by date in ascending order using "dateSort", which is equal to "0 - date" since Firebase can only sort in descending order
    
    guard  let lastDateValue = mostRecentlyQueriedDate?.timeIntervalSince1970 else {
        return
    }
    
    //The queryStartValue is exactly 1 second more than the last queried value's date.  This is done so that no duplicates are added to the list of queried values
    let queryStartValue = 0 - lastDateValue - 1
        
        if specificCategory{
            
            //Query events for a specific category from the "events-category" section of Firebase
            firebaseDatabaseRef.child("events-category").child(city).child(String(selectedCategory)).queryOrdered(byChild: "dateSort").queryStarting(atValue: 0 - afterDate ).queryEnding(atValue: queryStartValue).queryLimited(toLast: paginationAddlPageCount).observeSingleEvent(of: .value, with: {
                (snapshot) in
                guard let dict = snapshot.value as? NSDictionary else { return }
                for eventID in dict.allKeys {
                    
                    print("SNAPSHOT")
                    print(eventID)
                    addEventsToTableViewByKey(eventIDMap: [eventID : "NYC"], isUserCreatedEvent: false, addToListsInSortedOrder: true, addToAllEventsList: true)
                }
                
            })
            
        } else {
            
               //Since data is being queried for all events, we can query directly from the "Events" section of Firebase
            firebaseDatabaseRef.child("events").child(city).queryOrdered(byChild: "dateSort").queryStarting(atValue: 0 - afterDate ).queryEnding(atValue: queryStartValue).queryLimited(toLast: paginationAddlPageCount).observeSingleEvent(of: .value, with: {
                (snapshot) in
                guard let dict = snapshot.value as? NSDictionary else { return }
                addQueriedEventsToTableViewByValue(eventsList: dict)
            })
            
        }
        
    }

func queryPopularEventsFirstPage(specificCategory: Bool, city: String){
    
    //Query events in Firebase by popularity (upvote count)
    
    if specificCategory {
        
        //Query events for a specific category from the "events-category" section of Firebase
        firebaseDatabaseRef.child("events-category").child(city).child(String(selectedCategory)).queryOrdered(byChild: "upvotes").queryLimited(toLast: paginationFirstPageCount).observeSingleEvent(of: .value, with: {
            (snapshot) in
            guard let dict = snapshot.value as? NSDictionary else { return }
            for eventID in dict.allKeys {
                
                print("SNAPSHOT")
                print(eventID)
                addEventsToTableViewByKey(eventIDMap: [eventID : city], isUserCreatedEvent: false, addToListsInSortedOrder: true, addToAllEventsList: true)
            }
            
        })
        
    } else {
     
        //Since data is being queried for all events, we can query directly from the "Events" section of Firebase
        firebaseDatabaseRef.child("events").child(city).queryOrdered(byChild: "upvotes").queryLimited(toLast: paginationFirstPageCount).observeSingleEvent(of: .value, with: {
            (snapshot) in
            guard let dict = snapshot.value as? NSDictionary else { return }
            addQueriedEventsToTableViewByValue(eventsList: dict)
        })
        
    }

}

func queryPopularEventsAdditionalPage(specificCategory: Bool, city: String, lastUpvoteCount: Int ){
    
        //Query events in Firebase by popularity (upvote count)
    
    if specificCategory{
         //Since data is being queried for all events, we can query directly from the "Events" section of Firebase
        firebaseDatabaseRef.child("events-category").child(city).child(String(selectedCategory)).queryOrdered(byChild: "upvotes").queryEnding(atValue: lastUpvoteCount - 1).queryLimited(toLast: paginationAddlPageCount).observeSingleEvent(of: .value, with: {
            (snapshot) in
            guard let dict = snapshot.value as? NSDictionary else { return }
            for eventID in dict.allKeys {
                
                print("SNAPSHOT")
                print(eventID)
                addEventsToTableViewByKey(eventIDMap: [eventID : "NYC"], isUserCreatedEvent: false, addToListsInSortedOrder: true, addToAllEventsList: true)
            }
            
        })
        
    } else {
        
       //Query events for a specific category from the "events-category" section of Firebase
        firebaseDatabaseRef.child("events").child(city).queryOrdered(byChild: "upvotes").queryEnding(atValue: lastUpvoteCount - 1).queryLimited(toLast: paginationAddlPageCount).observeSingleEvent(of: .value, with: {
            (snapshot) in
            guard let dict = snapshot.value as? NSDictionary else { return }
            addQueriedEventsToTableViewByValue(eventsList: dict)
        })
        
    }
    
    
}

//Query list of events within a certain radius of a location
func queryNearbyEvents(centerLocation: CLLocation?, radius: Double){
    
    guard let queryLocation = centerLocation else {return}
    let searchDistanceKm = radius * 1.60934 //Convert radius(miles) to km
    
    tableEvents.removeAll()
    allEvents.removeAll()
    
    //Query to find all keys(event IDs) within radius of location
    //When new events are found, they are added to the tableView
    gQuery = geoFire.query(at: queryLocation, withRadius: searchDistanceKm)
    guard let gQ = gQuery else {return}
    gQ.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
        addEventsToTableViewByKey(eventIDMap: [key as Any : "NYC"] as NSDictionary, isUserCreatedEvent: false, addToListsInSortedOrder: false, addToAllEventsList: false)
    })
    
    //Method called when the query is finished and all keys(event IDs) are loaded
    //After all events within a radius are loaded, check if the distance query is complete or if the radius needs to be increased
    gQ.observeReady {
        checkIfNearbyQueryIsComplete()
    }
    
}


//Query list of Firebase events that were favorited by the user and add them to the eventsTableView
func queryFirebaseFavoriteEvents(){
    
    guard let userID = Auth.auth().currentUser?.uid else { return }
    tableEvents.removeAll()
    reloadEventTableView()
    firebaseDatabaseRef.child("favorited").child(userID).observeSingleEvent(of: .value, with: {
        (snapshot) in
        guard let dict = snapshot.value as? NSDictionary else { return }
        addEventsToTableViewByKey(eventIDMap: dict, isUserCreatedEvent: false, addToListsInSortedOrder: true, addToAllEventsList: false)
    })
    
}

//Query list of Firebase events that the user is attending and add them to the eventsTableView
func queryFirebaseAttendingEvents(){
    
    guard let userID = Auth.auth().currentUser?.uid else { return }
    tableEvents.removeAll()
    reloadEventTableView()
    firebaseDatabaseRef.child("attendingUsers").child(userID).observeSingleEvent(of: .value, with: {
        (snapshot) in
        guard let dict = snapshot.value as? NSDictionary else { return }
        addEventsToTableViewByKey(eventIDMap: dict, isUserCreatedEvent: false, addToListsInSortedOrder: true, addToAllEventsList: false)
    })
    
}

//Query list of Firebase events that were created by the user and add them to the eventsTableView
func queryFirebaseCreatedEvents(){
    
    guard let userID = Auth.auth().currentUser?.uid else { return }
    tableEvents.removeAll()
    reloadEventTableView()
    firebaseDatabaseRef.child("created").child(userID).observeSingleEvent(of: .value, with: {
        (snapshot) in
        guard let dict = snapshot.value as? NSDictionary else { return }
        addEventsToTableViewByKey(eventIDMap: dict, isUserCreatedEvent: true, addToListsInSortedOrder: true, addToAllEventsList: false)
    })
    
}

//Check to see if the event is marked as upvoted in firebase and update the event data and tableview accordingly
func queryIfFirebaseEventIsUpvoted(event: Event){
    
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    firebaseDatabaseRef.child("upvotes").child(userID).observeSingleEvent(of: .value, with: {
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

func queryIfUserIsAttendingEvent(event: Event) {
    
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    print("QUERYING IF USER IS ATTENDING")
    
    //Check if event is being attended by user.  If so, reload the event view controller to reflect this
    firebaseDatabaseRef.child("attendingUsers").child(userID).observeSingleEvent(of: .value, with: {
        (snapshot) in
        var userIsAttendingEvent = false
        let dict = snapshot.value as? NSDictionary
        if dict != nil {
            userIsAttendingEvent = dict!.allKeys.contains { element in
                if case element as! String = event.id {
                    print("USERISATTENDINGINNER")
                    print(userIsAttendingEvent)
                    return true } else { return false }
            }
        }
        
        print("USERISATTENDING")
        print(userIsAttendingEvent)
        
        if userIsAttendingEvent {
            selectedEvent.loggedInUserAttendingTheEvent = true
            reloadEventViewController()
        }
        
    })
    
}


//Query a firebase event to determine if it was favorited
func queryIfFirebaseEventIsFavorited(event: Event){
    
    guard let userID = Auth.auth().currentUser?.uid else { return }
    
    //Check if event has already been favorited
    //An event has already been favorited if the "favorite/userID" section of firebase contains the eventID as a key
    firebaseDatabaseRef.child("favorited").child(userID).observeSingleEvent(of: .value, with: {
        (snapshot) in
        guard let dict = snapshot.value as? NSDictionary else { return }
        let eventAlreadyFavorited = dict.allKeys.contains { element in
            if case element as! String = event.id { return true } else { return false }
        }
        
        //If event was marked as favorite, set the event's favorited variable to true
        if eventAlreadyFavorited {
            event.favorite = true
            reloadEventTableView()
        }
        
    })
    
    
    
}

func queryIfUserHasUsername(callback: @escaping ((Bool,String) -> Void)) {
    
    guard let userID = Auth.auth().currentUser?.uid else { return}
    
    //Checking username existence
    firebaseDatabaseRef.child("users").child(userID).child("username").observeSingleEvent(of: .value, with: {(usernameSnap) in
        
        print("QUERYING USERNAME")
        print(usernameSnap)
        //If user has username, return true/username, otherwise return false
        if usernameSnap.exists(){
            guard let username = usernameSnap.value as? String else {return}
            print(username)
            callback(true, username)
        }else{
            callback(false, "")
        }
        
    })
    
}

func queryFriendsInFirebase(username: String, callback: @escaping ((Bool,String) -> Void)) {
    
    //Check if a particular friend (username) exists, if so, return true and the userID (via callback).
    //If it doesn't exist, return false (via callback)
    
    guard let userID = Auth.auth().currentUser?.uid else { return}
    
    //Checking username existence
    firebaseDatabaseRef.child("active_usernames").child(username).observeSingleEvent(of: .value, with: {(usernameSnap) in
        
        print("QUERYING USERNAME")
        print(usernameSnap)
        print(usernameSnap.exists())
        //If user has username, return true/username, otherwise return false
        if usernameSnap.exists(){
            guard let username = usernameSnap.value as? String else {return}
            print(username)
            callback(true, username)
        }else{
            callback(false, "")
        }
        
    })
    
}

func queryFriendRequestsInFirebase(){
    
     guard let userID = Auth.auth().currentUser?.uid else { return}
    
    tableFriendRequests.removeAll()
    firebaseDatabaseRef.child("follow-requests-rec").child(userID).observeSingleEvent(of: .value, with: {
        (snapshot) in
        guard let dict = snapshot.value as? NSDictionary else { return }
        for friendUserID in dict.allKeys {
            
            print("Friend User ID Key")
            print(friendUserID)
            guard let friendUserIDString = friendUserID as? String else {return}
            let friendRequest = Friend(name: friendUserIDString, userID: friendUserIDString)
            tableFriendRequests.append(friendRequest)
        }
        reloadFriendTableView()
    })
    
}

func queryIfAccountIsPrivate(userID: String, callback: @escaping ((Bool, Bool) -> Void)){
    
    //Query if an account is private
    //The callback will be of the form: callback(accountFound, accountIsPrivate)
    firebaseDatabaseRef.child("user-settings").child(userID).child("private").observeSingleEvent(of: .value, with: {(privateAccountSnap) in
        
        var accountFound = false
        var accountIsPrivate = false
        print("QUERYING PRIVATE ACCOUNT")
        print(privateAccountSnap)
        print(privateAccountSnap.exists())
        //If user has username, return true/username, otherwise return false
        if privateAccountSnap.exists(){
            guard let isPrivateInt = privateAccountSnap.value as? Int else {return}
            accountFound = true
            if isPrivateInt == 1 {
                accountIsPrivate = true
                callback(accountFound, accountIsPrivate)
            } else {
                callback(accountFound, accountIsPrivate)
            }
        }else{
            callback(accountFound, accountIsPrivate)
        }
        
    })
    
}

func queryIfFriendRequestSent(friend: Friend, callback: @escaping ((Bool, Bool) -> Void)){
    
    //Query if an a friend request was sent
    //The callback will be of the form: callback(accountFound, friendRequestSent)
    
     guard let userID = Auth.auth().currentUser?.uid else { return}
    firebaseDatabaseRef.child("follow-requests-sent").child(userID).child(friend.userID).observeSingleEvent(of: .value, with: {(friendRequestSnap) in
        
        var accountFound = false
        var friendRequestSent = false
        print("QUERYING Friend Request")
        print(friendRequestSnap)
        print(friendRequestSnap.exists())
        //If user has username, return true/username, otherwise return false
        if friendRequestSnap.exists(){
            guard let friendReqInt = friendRequestSnap.value as? Int else {return}
            accountFound = true
            if friendReqInt == 0 || friendReqInt == 1 {
                friendRequestSent = true
                callback(accountFound, friendRequestSent)
            }
        }else{
            callback(accountFound, friendRequestSent)
        }
        
    })
    
}

