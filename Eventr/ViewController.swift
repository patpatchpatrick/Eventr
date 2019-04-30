//
//  ViewController.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/25/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import UIKit
import MapKit
import DropDown
import Firebase
import FirebaseAuth

//Variable to represent which event was selected in TableView
var selectedEvent: Event = Event(name: "", address: "", details: "", contact: "")
var events: [Event]!
var currentLocation: CLLocation!



class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    //List of events to display in tableView
    let categoryDropDown = DropDown()
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Request location authorizations
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        setUpAccountSettingsImage()
        setUpLogOutIcon()
        setUpCategoryStackView()
        setUpAddCategoryImage()
        hideSideMenu()
        setUpUser()
        
  
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Reload tableview whenever view appears
        eventTableView.reloadData()
    }
    
    //Views for the side menu    //Side menu shows account/settings info
    @IBOutlet weak var sideMenu: UIView!
    @IBOutlet weak var sideMenuShade: UIButton!
    @IBOutlet weak var sideMenuCurveImage: UIImageView!
    
    func showSideMenu(){
        UIView.animate(withDuration: 0.4, animations: {
            self.sideMenu.alpha = 1
            self.sideMenuShade.alpha = 0.75
            
        })
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            self.sideMenuCurveImage.transform = .identity
        })
        
    }
    
    func hideSideMenu(){
        UIView.animate(withDuration: 0.4, animations: {
            self.sideMenu.alpha = 0
            self.sideMenuShade.alpha = 0
            
        })
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            self.sideMenuCurveImage.transform = CGAffineTransform(translationX: -self.sideMenuCurveImage.frame.width, y: 0)
        })
    }
    
    
    @IBAction func sideMenuShadeTouched(_ sender: UIButton) {
        
        hideSideMenu()
    }
    
    
    @IBOutlet weak var sideMenuUserName: UILabel!
    
    //Set up user details in the side menu
    func setUpUser(){
        let userEmail = Auth.auth().currentUser?.email
        if userEmail != nil {
            sideMenuUserName.text = userEmail
        }
    }
    
    
    @IBOutlet weak var logOutIcon: UIImageView!
    
    func setUpLogOutIcon(){
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(logOutIconTapped(tapGestureRecognizer:)))
        
        logOutIcon.isUserInteractionEnabled = true
        logOutIcon.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    @objc func logOutIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //Show the side menu with the account/settings button is tapped
        logOut()
    }
    
    func logOut(){
        
        do {
            try Auth.auth().signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
        
    }
    
    @IBOutlet weak var accountSettingsIcon: UIImageView!
    
    func setUpAccountSettingsImage(){
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(accountSettingsIconTapped(tapGestureRecognizer:)))
        
        accountSettingsIcon.isUserInteractionEnabled = true
        accountSettingsIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func accountSettingsIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
       //Show the side menu with the account/settings button is tapped
       showSideMenu()
    }
    
    //Create Event Icon was tapped
    //If user is not logged in, display alert, otherwise segue to createEvent screen
    @IBAction func createEvent(_ sender: UIButton) {
        let latitude: CLLocationDegrees = 47.6219
        let longitude: CLLocationDegrees = 122.3517
        if Auth.auth().currentUser == nil {
            let alert = UIAlertController(title: "Must Be Logged In to Create Event", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
            self.present(alert, animated: true)
        } else {
            performSegue(withIdentifier: "createEventSegue", sender: self)
        }
        
        //queryFirebaseEventsInRadius(centerLocation: CLLocation(latitude: latitude, longitude: longitude), radius: 2.0)
        
        /*
        let latitude: CLLocationDegrees = 1.287063
        let longitude: CLLocationDegrees = 103.85455
        insertFirebaseEvent(location: CLLocation(latitude: latitude, longitude: longitude), eventID: "Singapore Merlion")
 */
    }
    
    func setUpAddCategoryImage(){
        
        //Set up category selection dropdown menu
        categoryDropDown.anchorView = addCategoryImage
        categoryDropDown.dataSource = userUnselectedEventCategories.strings()
        categoryDropDown.cellConfiguration = { (index, item) in return "\(item)" }
        
        addCategoryImage.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(categoryImageTapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        addCategoryImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func categoryImageTapped(_ sender: UITapGestureRecognizer) {
        //When the 'Add Category' image is tapped, show dropDown menu for user to select categories
        // to add to categories stackview
        // Add the user selected category to the StackView
        
        categoryDropDown.selectionAction = { (index: Int, item: String) in
            addImageToCategoriesStackView(for: item)
        }
        categoryDropDown.width = 140
        categoryDropDown.bottomOffset = CGPoint(x: 0, y:(categoryDropDown.anchorView?.plainView.bounds.height)!)
        categoryDropDown.show()
        
        
        func addImageToCategoriesStackView(for categoryName: String){
            
            //If a category is selected from the dropdown menu, add the category to the categories stack view
            //Only add the category if it isn't already in the stackview (i.e. userSelectedEventCategories)
            //After adding the category, remove it from the userUnselectedEventCategories
            //Update the dropDown list data to include the changes
            
            let eventCat = stringToEventCategory(string: categoryName)
            
            if(!userSelectedEventCategories.containsCategory(eventCategory: eventCat)){
                
                let imageView = UIImageView()
                imageView.backgroundColor = UIColor.blue
                imageView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
                imageView.image = eventCat.image()
                categoriesStackView.addArrangedSubview(imageView)
                userSelectedEventCategories.add(eventCategory: eventCat)
                userUnselectedEventCategories.remove(eventCategory: eventCat)
                categoryDropDown.dataSource = userUnselectedEventCategories.strings()
            }
            
        }
  
    }

    @IBOutlet weak var addCategoryImage: UIImageView!
    
    @IBOutlet weak var categoriesStackView: UIStackView!
    
    func setUpCategoryStackView(){
        
        //Add all user selected categories to the stackview of category images that can be selected
        for eventCategory in userSelectedEventCategories.set {
            let imageView = UIImageView()
            imageView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
            imageView.image = eventCategory.image()
            categoriesStackView.addArrangedSubview(imageView)
        }
        
        
    }
    
    //Get current location button tapped
    //Get the user's location.  The locationManager function will be called after retrieved
    @IBAction func getCurrentLocation(_ sender: UIButton) {
        
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
            useCurrentLocation()
        }
        
        
    }
    
    //User's location returned
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        currentLocation = manager.location
        
        DispatchQueue.main.async {
            self.useCurrentLocation()
        }
    }
    
    func useCurrentLocation(){
        locationEntryField.text = "Current Location"
        locationEntryField.endEditing(true)
    }
    
    
    @IBOutlet weak var locationEntryField: UITextField!
    
    @IBOutlet weak var eventTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = eventTableView.dequeueReusableCell(withIdentifier: "cellEvent", for: indexPath) as! CustomEventCell
        
        let event = events[indexPath.row]
        cell.eventName?.text = event.name
        if event.paid {
            cell.paidEvent?.image = UIImage(named: "eventIconDollar")
        } else {
            cell.paidEvent?.image = nil
        }
        
        
        if event.favorite {
            cell.favoriteIcon?.setImage(UIImage(named: "iconSelectedStar"), for: .normal)
        } else {
            cell.favoriteIcon?.setImage(UIImage(named: "iconUnselectedStar"), for: .normal)
        }
        //Add tap gesture recognizer for upvote arrow
        //When upvote arrow is tapped, run the upvoteTapped method
        //to update event upvotes
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(upvoteTapped(tapGestureRecognizer:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        cell.upvoteArrow?.isUserInteractionEnabled = true
        cell.upvoteArrow?.addGestureRecognizer(tapGestureRecognizer)
        cell.favoriteIcon?.tag = indexPath.row
        cell.upvoteArrow?.tag = indexPath.row
        cell.upvoteCount?.text = String(event.upvoteCount)
        return cell
    }
    
    // Method to run when upvote imageview is tapped
    @objc func upvoteTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let upvoteImage = tapGestureRecognizer.view as! UIImageView
        //If an upvote arrow was clicked, upvote the event
        events[upvoteImage.tag].upvote()
        eventTableView.reloadData()
        print(events[upvoteImage.tag].name)
        if (upvoteImage.tag == 0) //Give your image View tag
        {
            //navigate to next view
        }
        else{
            
        }
    }
    
    
    @IBAction func eventFavorited(_ sender: UIButton) {
        //Favorite icon (star) is tapped for a table row
        //Mark the event as a favorite and reload the data
        events[sender.tag].markFavorite()
        eventTableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEvent = events[indexPath.row]
        performSegue(withIdentifier: "eventSegue", sender: self)
    }
    
    
}

