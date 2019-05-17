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
import GoogleSignIn
import JTAppleCalendar

var selectedCategory: Int = 0
//Variable to represent which event was selected in TableView
var selectedEvent: Event = Event(name: "", category: EventCategory(category: .misc), date: Date(), address: "", details: "", contact: "", ticketURL: "", eventURL: "", tag1: "", tag2: "", tag3: "", paid: false)
var events: [Event] = [] //List of events in tableview
var currentLocation: CLLocation!
var searchDistanceMiles: Double = 5.0 //search distance in miles
var googleUser: GIDGoogleUser?
//Date range to query events
var hideDate: Date = Date().addingTimeInterval(-ONE_DAY) //date before which to hide calendar cells.  This date is equal to yesterday
var toDate: Date = Date().addingTimeInterval(ONE_WEEK)//toDate is 1 week from now by default
var fromDate: Date = Date()




class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    var fromDateWasSelected: Bool = false //Bool to know which calendar button was selected (from or to)
    let addCategoryDropDown = DropDown()
    let subtractCategoryDropDown = DropDown()
    let locationManager = CLLocationManager()
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundViewSideBorder: UIView!
    
    @IBOutlet weak var headerButtonCreateEventContainer: RoundUIView!
    
    @IBOutlet weak var headerButtonAccountContainer: RoundUIView!
    
    @IBOutlet weak var sideMenu: UIView!
    @IBOutlet weak var sideMenuShade: UIButton!
    @IBOutlet weak var sideMenuCurveImage: UIImageView!
    @IBOutlet weak var sideMenuAccountButton: UIButton!
    @IBOutlet weak var sideMenuAccountButtonLabel: UILabel!
    @IBOutlet weak var sideMenuMyEventsButton: UIButton!
    @IBOutlet weak var sideMenuMyEventsButtonLabel: UILabel!
    @IBOutlet weak var sideMenuFavoritedButton: UIButton!
    @IBOutlet weak var sideMenuFavoritedButtonLabel: UILabel!
    @IBOutlet weak var sideMenuSettingsButton: UIButton!
    @IBOutlet weak var sideMenuSettingsButtonLabel: UILabel!
    @IBOutlet weak var sideMenuLogOutIcon: UIImageView!
    @IBOutlet weak var sideMenuLogOutIconLabel: UILabel!
    @IBOutlet weak var accountSettingsIcon: UIImageView!
    @IBOutlet weak var addCategoryImage: UIImageView!
    @IBOutlet weak var subtractCategoryImage: UIImageView!
    @IBOutlet weak var allCategoriesButton: UIButton!
    @IBOutlet weak var categoriesStackView: UIStackView!
    
    @IBOutlet weak var mainDateButton: RoundedButton!
    @IBOutlet weak var mainLocationButton: RoundedButton!
    @IBOutlet weak var mainSearchButton: RoundedButton!
    @IBOutlet weak var searchSelectionContainer: UIView!
    @IBOutlet weak var dateSelectionContainer: UIView!
    
    @IBOutlet weak var locationEntryField: UITextField!
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var calendarContainer: UIView!
    @IBOutlet weak var selectFromDate: UIButton!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var selectToDate: UIButton!
    @IBOutlet weak var listDescriptor: RoundUIView!
    @IBOutlet weak var listDescriptorCover: UIView!//Covers up all the search options when list descriptor is out
    @IBOutlet weak var listDescriptorIcon: UIImageView!
    @IBOutlet weak var listDescriptorLabel: UILabel!
    @IBOutlet weak var listDescriptorReturnButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        // Request location authorizations
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        hideListDescriptor()
        configureHeaderButtons()
        setUpAccountSettingsImage()
        setUpLogOutIcon()
        setUpCategoryStackView()
        setUpAddCategoryImage()
        setUpMainButtons()
        configureDateAndSearchContainers()
        setUpSubtractCategoryImage()
        setUpLocationEntryField()
        hideSideMenu()
        setUpUser()
        configureCalendarView()
  
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Add notfication observer to reload tableview whenever event data is changed
        eventTableView.reloadData()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updated_event_data),
                                               name:Notification.Name("UPDATED_EVENT_DATA"),
                                               object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updated_event_data(notification:Notification) -> Void{
        eventTableView.reloadData()
    }
    
    @IBAction func sideMenuShadeTouched(_ sender: UIButton) {
        hideSideMenu()
    }
    
    @objc func accountSettingsIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        showSideMenu()
    }
    
    @objc func logOutIconTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        logOut()
    }
    
    //Create Event Icon was tapped
    //If user is not logged in, display alert, otherwise segue to createEvent screen
    @IBAction func createEvent(_ sender: UIButton) {
        if Auth.auth().currentUser == nil {
            let alert = UIAlertController(title: "Must Be Logged In to Create Event", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
            self.present(alert, animated: true)
        } else {
            performSegue(withIdentifier: "createEventSegue", sender: self)
        }
        
    }
    
    //"Get current location" button tapped
    //Get the user's location. The locationManager function in VCExtension class will be called after location is retrieved
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
            currentLocationRetrieved()
        }
        
        
    }
    
    //Start date button pushed in the main UI
    @IBAction func selectFromDate(_ sender: UIButton) {
        
        fromDateWasSelected = true
        hideDate = Date().addingTimeInterval(-ONE_DAY)
        calendarView.reloadData()
        calendarView.deselectAllDates()
        calendarView.selectDates([fromDate])
        calendarView.scrollToDate(fromDate)
        selectToDate.isEnabled = false //ensure both from and to buttons aren't pressed at same time
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.calendarContainer.isHidden = false
        })
        
    }
    
    @IBAction func previousMonth(_ sender: UIButton) {
        calendarView.scrollToSegment(.previous)
    }
    
    
    @IBAction func nextMonth(_ sender: UIButton) {
        calendarView.scrollToSegment(.next)
    }
    
    //Start date selecton confirmed in the calendarView
    @IBAction func confirmDate(_ sender: UIButton) {
        
        selectToDate.isEnabled = true
        selectFromDate.isEnabled = true
        if fromDate > toDate {
            resetCalendarToDate()
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.calendarContainer.isHidden = true
        })
    }
    
    
    @IBAction func discardDate(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.calendarContainer.isHidden = true
        })
        
        //self.calendarContainer.isHidden = true
        if fromDateWasSelected{
            resetCalendarFromDate()
        } else {
            resetCalendarToDate()
        }
        selectToDate.isEnabled = true
        selectFromDate.isEnabled = true
    }
    
    //End date button pushed in the main UI
    @IBAction func selectToDate(_ sender: UIButton) {
        
        fromDateWasSelected = false
        hideDate = fromDate
        calendarView.reloadData()
        calendarView.deselectAllDates()
        calendarView.selectDates([toDate])
        calendarView.scrollToDate(toDate)
        selectFromDate.isEnabled = false //ensure both from and to buttons aren't pressed at same time
        
        UIView.animate(withDuration: 0.7, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.calendarContainer.isHidden = false
        })

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    //Set up the cells in the table view using the event data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = eventTableView.dequeueReusableCell(withIdentifier: "cellEvent", for: indexPath) as! CustomEventCell
        
        //Handle paid event
        let event = events[indexPath.row]
        cell.eventName?.text = event.name
        if event.paid {
            cell.paidEvent?.image = UIImage(named: "eventIconDollar")
        } else {
            cell.paidEvent?.image = nil
        }
        
        //Handle event favorited
        if event.favorite {
            cell.favoriteIcon?.tintColor = themeAccentYellow
        } else {
            cell.favoriteIcon?.tintColor = themeDark
        }
        
        cell.categoryIcon.image = event.category.image()
        
        //Handle upvote
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(upvoteTapped(tapGestureRecognizer:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        cell.upvoteArrow?.isUserInteractionEnabled = true
        cell.upvoteArrow?.addGestureRecognizer(tapGestureRecognizer)
        cell.favoriteIcon?.tag = indexPath.row
        cell.upvoteArrow?.tag = indexPath.row
        if event.upvoted {
            cell.upvoteArrow.tintColor = themeAccentGreen
        } else {
            cell.upvoteArrow.tintColor = themeDark
        }
        cell.upvoteCount?.text = String(event.upvoteCount)
        
        //Configure design for the primary view
        configurePrimaryTableViewCellDesign(view: cell.primaryView)
        
        return cell
    }
    
    //Favorite icon (star) is tapped for a table row
    @IBAction func eventFavorited(_ sender: UIButton) {
        events[sender.tag].markFavorite()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEvent = events[indexPath.row]
        performSegue(withIdentifier: "eventSegue", sender: self)
    }
    
    
    //When search distance segmented control is clicked, change the search distance value
    @IBAction func distanceRadius(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            searchDistanceMiles = 5.0
        case 1:
            searchDistanceMiles = 20.0
        case 2:
            searchDistanceMiles = 100.0
        default:
            break;
        }
    }
    
    //Search button is tapped.  Query events within radius(km) of the location
    @IBAction func search(_ sender: UIButton) {

        let searchDistanceKm = searchDistanceMiles * 1.60934
        
        let addressText = locationEntryField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        if addressText == "Current Location" {
            queryFirebaseEventsInRadius(centerLocation: currentLocation!, radius: searchDistanceKm)
        } else {
            getCoordinates(forAddress: addressText!) {
                (location) in
                guard let location = location else {
                    //Handle geolocation error
                    return
                }
                let addressLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                queryFirebaseEventsInRadius(centerLocation: addressLocation, radius: searchDistanceKm)
            }
        }
        
    }
    
    
    @IBAction func sideMenuFavoriteButtonTapped(_ sender: UIButton) {
        loadFavoriteEvents()
    }
    
    
    @IBAction func listDescriptorReturnButtonTapped(_ sender: Any) {
        
        print("RETURN BUTTON TAPPED")
        hideListDescriptor()
        
    }
    
    
    @IBAction func mainDateSelectionButtonTapped(_ sender: Any) {
        showDateSelectionContainer()
    }
    
    
    @IBAction func mainSearchSelectionButtonTapped(_ sender: Any) {
        showSearchSelectionContainer()
    }
    
    
    @IBAction func mainSearchButtonTapped(_ sender: Any) {
    }
    
}

