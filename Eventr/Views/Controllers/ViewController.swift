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

//TABLEVIEW VARIABLES
var selectedCategory: Int = 0 //Int to represent which category was selected in the category stackview.  Events will be filtered using this category.  This category is based on the event's Index.
//Variable to represent which event was selected in TableView
var selectedEvent: Event = Event(name: "", category: EventCategory(category: .misc), date: Date(), city: selectedCity, address: "",venue: "", details: "", contact: "", phoneNumber: "", ticketURL: "", eventURL: "", tag1: "", tag2: "", tag3: "", paid: false, price: "")
var selectedEventIndex = 0
enum eventAction {
    case creating
    case editing
}
var selectedEventAction: eventAction = .creating //variable to track if creating or editing an event
var tableEvents: [Event] = [] //List of events in tableview
var allEvents: [Event] = [] //List of all queried events.  This list may be filtered/shortened based on search criteria when events are displayed in the table (tableEvents) array.  This list of events is maintained so that events don't need to be re-queried from Firebase
//Date range to query events
enum sortBy {
    case popularity
    case dateasc
    case datedesc
}
var sortByPreference : sortBy = .popularity //Variable to track user's sorting preferences


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    let addCategoryDropDown = DropDown()
    let subtractCategoryDropDown = DropDown()
    let sortDropDown = DropDown()
    let citySelectDropDown = DropDown() //dropdown menu to choose specific city to search within
    @IBOutlet weak var plusButtonStackView: UIStackView!
    let locationManager = CLLocationManager()
    
    enum listDescriptorType {
        case favorited
        case created
        case attending
    }
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    var blurEffectView: UIVisualEffectView?
    
    @IBOutlet weak var headerButtonCreateEventContainer: RoundUIView!
    
    @IBOutlet weak var headerButtonAccountContainer: RoundUIView!
    
    @IBOutlet weak var headerButtonFriendsContainer: RoundUIView!
    
    
    @IBOutlet weak var sideMenu: UIView!
    @IBOutlet weak var sideMenuShade: UIButton!
    @IBOutlet weak var sideMenuBackground: UIView!
    @IBOutlet weak var sideMenuAccountButton: UIButton!
    
    @IBOutlet weak var sideMenuMyEventsContainer: UIView!
    @IBOutlet weak var sideMenuMyEventsButton: UIButton!
    @IBOutlet weak var sideMenuMyEventsButtonLabel: UIButton!
    
    @IBOutlet weak var sideMenuAttendingContainer: UIView!
    @IBOutlet weak var sideMenuAttendingButton: UIButton!
    @IBOutlet weak var sideMenuAttendingButtonLabel: UIButton!
    
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
    
    @IBOutlet weak var dateAndLocationBackground: UIView!
    
    @IBOutlet weak var mainDateButton: RoundedButton!
    @IBOutlet weak var mainCitySelectionButton: RoundedButton!
    
    @IBOutlet weak var hotButton: RoundedButton!
    
    @IBOutlet weak var upcomingButton: RoundedButton!
    
    @IBOutlet weak var nearbyButton: RoundedButton!
    
    @IBOutlet weak var dateButtonContainer: UIView!
    
    @IBOutlet weak var distanceRadiusSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchSelectionContainer: UIView!
    
    @IBOutlet weak var locationEntryField: UITextField!
    
    @IBOutlet weak var locationSearchButton: RoundedButton!
    
    
    @IBOutlet weak var tableViewSettingsContainer: UIView!
    @IBOutlet weak var eventTableView: UITableView!
    @IBOutlet weak var calendarAndTableViewContainer: RoundUIView!
    @IBOutlet weak var calendarInnerContainer: UIView!
    @IBOutlet weak var calendarContainer: UIView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var calendarAndTableStackView: UIStackView!
    
    
    @IBOutlet weak var sortButton: RoundedButton!
    
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
        
        //Add notification on view to listen for when the initial data is loaded
        addDefaultNotifications()
        configureListDiscriptor()
        configureSideMenu()
        configureHeaderButtons()
        setUpCategoryStackView()
        setUpMainButtonsAndLocationBar()
        setUpSortButton()
        getCurrentLocation()
        hideViews()
        configureCalendarView()
        updateSelectedQueryButtonStyle()
        loadInitialListOfEvents()
        
        //addTestStandardDataToFirebase(vc: self)
  
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Add notification observer to reload tableview whenever event data is changed
        eventTableView.reloadData()
        setCitySelectionIfSetInPrefs()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updated_event_data),
                                               name:Notification.Name("UPDATED_EVENT_DATA"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clear_table_view),
                                               name:Notification.Name("CLEAR_TABLE_VIEW"),
                                               object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func addDefaultNotifications(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updated_event_data),
                                               name:Notification.Name("UPDATED_EVENT_DATA"),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(clear_table_view),
                                               name:Notification.Name("CLEAR_TABLE_VIEW"),
                                               object: nil)

    }
    
    @objc func updated_event_data(notification:Notification) -> Void{
      
        eventTableView.restore()
        eventTableView.reloadData()
        if tableEvents.count > 0 {
            showTableViewSettingsContainer()
        } else {
            hideTableViewSettingsContainer()
        }
        
    }
    
    @objc func clear_table_view(notification:Notification) -> Void{
        
        eventTableView.setEmptyMessage("Sorry, no events meet your search criteria. You should create one!")
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
            displayAlertWithOKButton(text: "Must Be Logged In To Create Event")
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
    @IBAction func getCurrentLocationButtonTapped(_ sender: UIButton) {

       getCurrentLocation()
        
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
        queryFirebaseEvents(city: selectedCity, firstPage: true) //Search for new events when new date is chosen
    }
    
    
    @IBAction func discardDate(_ sender: UIButton) {
        
        hideCalendarView()
        calendarView.deselectAllDates(triggerSelectionDelegate: false)
        resetCalendarFromDate()
        resetCalendarToDate()
        calendarView.reloadData()
        updateMainDateButtonDateLabels()
    }
    
    
    @IBAction func sortButtonTapped(_ sender: Any) {
        sortButtonTapped()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableEvents.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Set up the cells in the table view using the event data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Determine if more data needs to be loaded in the tableview (user has scrolled to the bottom of the page and another page needs to be loaded)
        if indexPath.row == tableEvents.count - 1 {
            //If the last cell has been loaded and pagination is not currently in progress, load another page
            //Do not load more data if the list descriptor is in use.  List descriptor shows events that don't require pagination
            print("Pagination In Progress")
            print(paginationInProgress)
            if !paginationInProgress && !listDescriptorInUse {
                paginationInProgress = true
                queryFirebaseEvents(city: selectedCity, firstPage: false)
            }
        }
        
        let cell = eventTableView.dequeueReusableCell(withIdentifier: "cellEvent", for: indexPath) as! CustomEventCell
        
        //Handle paid event
        if tableEvents.isEmpty {return cell}
        let event = tableEvents[indexPath.row]
        cell.eventName?.text = event.name
        if event.paid {
            cell.paidEvent?.image = UIImage(named: "eventIconDollar")
        } else {
            cell.paidEvent?.image = nil
        }
        
        cell.eventPrice.text = event.getPriceLabel()
        
        cell.eventDescription.text = event.details
        
        //Set the date and time of the event
        if let eventDate = event.getDateCurrentTimeZone() {
            let df = DateFormatter()
            df.amSymbol = "AM"
            df.pmSymbol = "PM"
            df.dateFormat = "MMM dd YYYY ' - ' h:mm a"
            let dateString = df.string(from: eventDate)
            cell.eventDateAndTime.text = dateString
        }
        
        if event.duration != 0 {
            let df = DateFormatter()
            df.amSymbol = "AM"
            df.pmSymbol = "PM"
            df.dateFormat = "h:mm a"
            let endTimeString = df.string(from: event.getDateWithDurationCurrentTimeZone())
            cell.eventDateAndTime.text?.append(" -> " + endTimeString)
        }
        
        //Set the count of users attending the event
        if event.userCount > 0 {
            cell.eventUserCount.isHidden = false
            cell.eventUserCountIcon.isHidden = false
            cell.eventUserCount.text = String(event.userCount)
        } else {
            cell.eventUserCount.isHidden = true
            cell.eventUserCountIcon.isHidden = true
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
        cell.upvoteCount?.tag = indexPath.row
        if event.upvoted {
            cell.upvoteArrow.tintColor = themeAccentGreen
        } else {
            cell.upvoteArrow.tintColor = themeDark
        }
        cell.upvoteCount?.setTitle(String(event.upvoteCount), for: .normal)
        
        //Configure design for the primary view
        configurePrimaryTableViewCellDesign(view: cell.primaryView)
        
        return cell
    }
 
    //Favorite icon (star) is tapped for a table row
    @IBAction func eventFavorited(_ sender: UIButton) {
        tableEvents[sender.tag].markFavorite()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableEvents.isEmpty && indexPath.row < tableEvents.count {
            selectedEvent = tableEvents[indexPath.row]
            selectedEventIndex = indexPath.row
            performSegue(withIdentifier: "eventSegue", sender: self)
        }
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
    
    
    @IBAction func sideMenuAttendingButtonTapped(_ sender: UIButton) {
        loadAttendingEvents()
    }
    
    
    @IBAction func sideMenuAttendingLabelTapped(_ sender: UIButton) {
        loadAttendingEvents()
    }
    
    
    
    @IBAction func listDescriptorReturnButtonTapped(_ sender: Any) {
        
        hideListDescriptor()
        setCitySelectionIfSetInPrefs()
        
    }
    
    
    @IBAction func mainDateSelectionButtonTapped(_ sender: Any) {
        hideDate = Date().addingTimeInterval(-ONE_DAY)
        calendarView.selectDates(from: fromDate, to: toDate, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        calendarView.reloadData()
        calendarView.scrollToDate(fromDate)
        showCalendarView()
    }
    
    
    
    @IBAction func sideMenuSettingsButtonTapped(_ sender: UIButton) {
        settingsButtonTapped()
    }
    
    @IBAction func sideMenuSettingsButtonLabelTapped(_ sender: UIButton) {
        settingsButtonTapped()
    }
    
    
    @IBAction func upvoteLabelTapped(_ sender: UIButton) {
        
        //If the upvote label was clicked, upvote the event
        tableEvents[sender.tag].upvote()
        eventTableView.reloadData()
        
        
    }
    
    
    @IBAction func mainCitySelectButtonTapped(_ sender: UIButton) {
        
        citySelectDropDown.selectionAction = { (index: Int, item: String) in
            let fullCityName = item
            let cityAbbreviation = getCityAbbreviation(fullCityName: fullCityName)
            self.mainCitySelectionButton.setTitle(cityAbbreviation, for: .normal)
            var cityChanged = false
            if cityAbbreviation != selectedCity {cityChanged = true}
            selectedCity = cityAbbreviation
            //Set the user defaults so the selected city is saved and used as the default the next time the app is launched
            UserDefaults.standard.set(selectedCity, forKey: selectedCityPrefKey)
            
            if cityChanged {
                clearEventTableView()  //New city was selected, so clear the tableview
                self.queryFirebaseEvents(city: selectedCity, firstPage: true)
            }
            
        }
        citySelectDropDown.backgroundColor = themeMedium
        citySelectDropDown.textColor = themeAccentPrimary
        if let dropDownFont = UIFont(name: "Raleway-Regular",
                                     size: 14.0) {
            citySelectDropDown.textFont = dropDownFont
        }
        citySelectDropDown.width = 140
        citySelectDropDown.bottomOffset = CGPoint(x: 0, y:(citySelectDropDown.anchorView?.plainView.bounds.height)!)
        citySelectDropDown.show()
        
    }
    
    
    @IBAction func hotButtonTapped(_ sender: UIButton) {
        firebaseQueryType = .popular
        updateSelectedQueryButtonStyle()
        showAndHideViewsBasedOnQueryType()
        queryFirebaseEvents(city: selectedCity, firstPage: true)
    }
    
    
    @IBAction func upcomingButtonTapped(_ sender: UIButton) {
        clearTableView()
        firebaseQueryType = .upcoming
        updateSelectedQueryButtonStyle()
        showAndHideViewsBasedOnQueryType()
        queryFirebaseEvents(city: selectedCity, firstPage: true)
    }
    
    
    @IBAction func nearMeButtonTapped(_ sender: UIButton) {
        clearTableView()
        firebaseQueryType = .nearby
        showAndHideViewsBasedOnQueryType()
        updateSelectedQueryButtonStyle()
        queryFirebaseEvents(city: selectedCity, firstPage: true)
    }
    
    //If the user changes the location and taps the search button, the "Nearby" query will be retriggered
    @IBAction func locationSearchButtonTapped(_ sender: RoundedButton) {
        clearTableView()
        firebaseQueryType = .nearby
        showAndHideViewsBasedOnQueryType()
        updateSelectedQueryButtonStyle()
        queryFirebaseEvents(city: selectedCity, firstPage: true)
        
    }
    
    
    @IBAction func friendsButtonTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "friendsSegue", sender: self)
        
    }
    
}

