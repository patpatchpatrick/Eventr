//
//  ViewControllerDataHandlerExtension.swift
//  Eventr
//
//  Created by Patrick Doyle on 5/29/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import DropDown
import Firebase
import FirebaseAuth
import GoogleSignIn


//This Extension primarily deals with data-handling (location, Firebase queries, etc...)
extension ViewController{
    
    func getCurrentLocation(){
        if currentLocation == nil {
            //Get user's current location
            DispatchQueue.global(qos: .userInteractive).async {
                if CLLocationManager.locationServicesEnabled() {
                    self.locationManager.delegate = self
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    self.locationManager.startUpdatingLocation()
                }
            }
        } else {
            currentLocationRetrieved()
        }
    }
    
    //User's location returned
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        currentLocation = manager.location
        
        DispatchQueue.main.async {
            self.currentLocationRetrieved()
        }
    }
    
    func currentLocationRetrieved(){
        print("Location Retrieved!")
        locationEntryField.text = "Current Location"
        locationEntryField.endEditing(true)
        self.locationManager.stopUpdatingLocation()
        
    }
    
    func loadInitialListOfEvents(){
        
        queryFirebaseEvents(city: "NYC", firstPage: true)
        
    }
    
    //The primary query function used by the app.  This method determines which query to run depending on which button the user pushed (i.e. firebaseQueryType)
    func queryFirebaseEvents(city: String, firstPage: Bool){
        
        switch firebaseQueryType{
            
        case .popular: //User querying "Popular/Hot" events, add events to tableView in upvote count order.  No date range used.
            sortByPreference = .popularity
            queryPopularEvents(city: city, queryingFirstPage: firstPage)
            
        case .nearby:  //User querying "Nearby" events, use Geofire to search for and add events near user and sort them by popularity
            sortByPreference = .popularity
            
            if firstPage {
                
                //If the first page is being loaded, reset the variables that track the "Nearby" events that have been loaded
                nearbyEventPageCountLoaded = false
                nearbyEventPageCount = paginationFirstPageCount
                incrementingSearchRadius = defaultSearchIncrement
                clearEventTableView()
                
                determineLocationAndQueryFirstPage()
                
            } else if nearbyEventPageCountLoaded{
                //If you aren't loading the first page and the pageCount has been loaded, increase the page count and load more data if it exists
                nearbyEventPageCount += paginationAddlPageCount
                nearbyEventPageCountLoaded = false
                checkIfNearbyQueryIsComplete()
                
            }
            
        case .upcoming: //For upcoming events, add events to tableView in dateAscending order within user selected date range
            sortByPreference = .dateasc
            queryUpcomingEvents(city: city, queryingFirstPage: firstPage)
        }
    }
    
    func determineLocationAndQueryFirstPage(){
        
        guard let addressText = locationEntryField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        //If user-entered address text is empty or is "Current Location", search for events using the current user's location, if not, search by address that they entered
        if addressText == "Current Location" || addressText.isEmpty || addressText == "" {
            mostRecentlyQueriedLocation = currentLocation
            queryNearbyEvents(centerLocation: mostRecentlyQueriedLocation, radius: incrementingSearchRadius)
        } else {
            getCoordinates(forAddress: addressText) {
                (location) in
                guard let location = location else {return} //Handle geolocation error here if necessary
                let addressLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                mostRecentlyQueriedLocation = addressLocation
                queryNearbyEvents(centerLocation: mostRecentlyQueriedLocation, radius: incrementingSearchRadius)
            }
        }
        
    }
    
    func loadFavoriteEvents(){
        if Auth.auth().currentUser == nil {
            displayAlertWithOKButton(text: "Must Be Logged In To Access Your Favorite Events")
        } else {
            hideSideMenu()
            showListDescriptor(type: .favorited)
            queryFirebaseFavoriteEvents()
        }
        
    }
    
    func loadMyEvents(){
        if Auth.auth().currentUser == nil {
            displayAlertWithOKButton(text: "Must Be Logged In To Access Your Events")
        } else {
            hideSideMenu()
            showListDescriptor(type: .created)
            queryFirebaseCreatedEvents()
        }
    }
    
    func loadAttendingEvents(){
        if Auth.auth().currentUser == nil {
            displayAlertWithOKButton(text: "Must Be Logged In To Access Your Favorite Events")
        } else {
            hideSideMenu()
            showListDescriptor(type: .attending)
            queryFirebaseAttendingEvents()
        }
        
    }
    
    
}
