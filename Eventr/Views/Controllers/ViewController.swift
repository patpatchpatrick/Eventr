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
enum eventAction {
    case creating
    case editing
}
var selectedEventAction: eventAction = .creating //variable to track if creating or editing an event
var events: [Event] = [] //List of events in tableview
var currentLocation: CLLocation!
var searchDistanceMiles: Double = 5.0 //search distance in miles
var googleUser: GIDGoogleUser?
//Date range to query events
var hideDate: Date = Date().addingTimeInterval(-ONE_DAY) //date before which to hide calendar cells.  This date is equal to yesterday
var toDate: Date = Date().addingTimeInterval(ONE_WEEK)//toDate is 1 week from now by default
var fromDate: Date = Date()



class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    var locationSelectionExpanded: Bool = false
    let addCategoryDropDown = DropDown()
    let subtractCategoryDropDown = DropDown()
    @IBOutlet weak var plusButtonStackView: UIStackView!
    let locationManager = CLLocationManager()
    
    enum listDescriptorType {
        case favorited
        case created
    }
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    var blurEffectView: UIVisualEffectView?
    
    @IBOutlet weak var headerButtonCreateEventContainer: RoundUIView!
    
    @IBOutlet weak var headerButtonAccountContainer: RoundUIView!
    
    @IBOutlet weak var sideMenu: UIView!
    @IBOutlet weak var sideMenuShade: UIButton!
    @IBOutlet weak var sideMenuBackground: UIView!
    @IBOutlet weak var sideMenuAccountButton: UIButton!
    
    @IBOutlet weak var sideMenuMyEventsContainer: UIView!
    @IBOutlet weak var sideMenuMyEventsButton: UIButton!
    @IBOutlet weak var sideMenuMyEventsButtonLabel: UIButton!
    
    @IBOutlet weak var sideMenuFavoritedContainer: UIView!
    @IBOutlet weak var sideMenuFavoritedButton: UIButton!
    @IBOutlet weak var sideMenuFavoritedButtonLabel: UIButton!
    
    
    @IBOutlet weak var sideMenuSettingsContainer: UIView!
    @IBOutlet weak var sideMenuSettingsButton: UIButton!
    @IBOutlet weak var sideMenuSettingsButtonLabel: UIButton!
    
    @IBOutlet weak var sideMenuLogOutContainer: UIView!
    @IBOutlet weak var sideMenuLogOutIcon: UIImageView!
    @IBOutlet weak var sideMenuLogOutIconLabel: UIButton!
    
    @IBOutlet weak var categorySelectionStackViewContainer: UIStackView!
    @IBOutlet weak var mainButtonsStackViewContainer: UIStackView!
    @IBOutlet weak var accountSettingsIcon: UIImageView!
    
    @IBOutlet weak var allCategoriesButton: UIButton!
    @IBOutlet weak var categoriesStackView: UIStackView!
    @IBOutlet weak var subtractCategoryButton: RoundedButton!
    @IBOutlet weak var dateAndSearchButtonStackView: UIStackView!
    @IBOutlet weak var mainDateButton: RoundedButton!
    @IBOutlet weak var mainLocationButton: RoundedButton!
    @IBOutlet weak var mainSearchButton: RoundedButton!
    @IBOutlet weak var searchSelectionContainer: UIView!
    
    @IBOutlet weak var locationEntryField: UITextField!
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var calendarInnerContainer: UIView!
    @IBOutlet weak var calendarContainer: UIView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
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
        configureListDiscriptor()
        configureStandardViewDesignWithShadow(view: sideMenu, shadowSize: 1.0, widthAdj: 0, heightAdj: 200, xOffset: 0.0, yOffset: 100)
        configureSideMenu()
        configureHeaderButtons()
        setUpAccountSettingsImage()
        setUpLogOutIcon()
        setUpCategoryStackView()
        setUpSubtractCategoryButton()
        setUpLocationEntryField()
        setUpMainButtons()
        hideSearchCollectionContainer()
        hideSideMenu()
        hideCalendarView()
        configureCalendarView()
  
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Add notification observer to reload tableview whenever event data is changed
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
    
    
    @IBAction func logOutLabelTapped(_ sender: UIButton) {
        logOut()
    }
    
    //Create Event Icon was tapped
    //If user is not logged in, display alert, otherwise segue to createEvent screen
    @IBAction func createEvent(_ sender: UIButton) {
        selectedEventAction = .creating //Set action used to determine whether to show "creating" or "editing" screen
        if Auth.auth().currentUser == nil {
            let alert = UIAlertController(title: "Must Be Logged In to Create Event", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            }))
            self.present(alert, animated: true)
        } else {
            performSegue(withIdentifier: "createEventSegue", sender: self)
        }
        
    }
    
    //Remove category button in categories stackview was tapped
    @IBAction func removeCategoryButtonTapped(_ sender: RoundedButton) {
        removeCategoryFromToolbar()
    }
    
    //Add category button in categories stackview was tapped
    @IBAction func addCategoryButtonTapped(_ sender: RoundedButton) {
        plusButtonTapped(sender: sender)
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
        
        
    }
    
    @IBAction func previousMonth(_ sender: UIButton) {
        calendarView.scrollToSegment(.previous)
    }
    
    
    @IBAction func nextMonth(_ sender: UIButton) {
        calendarView.scrollToSegment(.next)
    }
    
    //Start date selecton confirmed in the calendarView
    @IBAction func confirmDate(_ sender: UIButton) {
        
        hideCalendarView()
        updateMainDateButtonDateLabels()
    }
    
    
    @IBAction func discardDate(_ sender: UIButton) {
        
        hideCalendarView()
        
        calendarView.deselectAllDates(triggerSelectionDelegate: false)
        resetCalendarFromDate()
        resetCalendarToDate()
        calendarView.reloadData()
        updateMainDateButtonDateLabels()
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
        
        cell.eventDescription.text = event.details
        
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
    
    @IBAction func sideMenuMyEventsButtonTapped(_ sender: UIButton) {
        loadMyEvents()
    }
    
    @IBAction func sideMenuMyEventsLabelTapped(_ sender: Any) {
        loadMyEvents()
    }
    
    
    @IBAction func sideMenuFavoriteButtonTapped(_ sender: UIButton) {
        loadFavoriteEvents()
    }
    
    
    @IBAction func sideMenuFavoriteLabelTapped(_ sender: UIButton) {
        loadFavoriteEvents()
    }
    
    
    @IBAction func listDescriptorReturnButtonTapped(_ sender: Any) {
        
        print("RETURN BUTTON TAPPED")
        hideListDescriptor()
        
    }
    
    
    @IBAction func mainDateSelectionButtonTapped(_ sender: Any) {
        hideDate = Date().addingTimeInterval(-ONE_DAY)
        calendarView.selectDates(from: fromDate, to: toDate, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        calendarView.reloadData()
        calendarView.scrollToDate(fromDate)
        showCalendarView()
    }
    
    
    @IBAction func mainSearchSelectionButtonTapped(_ sender: Any) {
        if !self.searchSelectionContainer.isHidden {
            hideSearchCollectionContainer()
        } else {
            showSearchSelectionContainer()
        }
    }
    
    
     //Search button is tapped.  Query events within radius(km) of the location
    @IBAction func mainSearchButtonTapped(_ sender: Any) {
        hideCalendarView()
        hideSearchCollectionContainer()
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
    
    
    
}

