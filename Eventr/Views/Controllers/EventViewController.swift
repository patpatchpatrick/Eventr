//
//  EventViewController.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/26/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import UIKit
import MapKit
import PhoneNumberKit

class EventViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet weak var headerBackButtonContainer: RoundUIView!
    @IBOutlet weak var headerFavoriteIconContainer: UIView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventDetails: UITextView!
    @IBOutlet weak var locationDetailsButton: UIButton!
    @IBOutlet weak var contactDetailsButton: UIButton!
    @IBOutlet weak var additionalContactInfo: UITextView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var linksStackView: UIStackView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var ticketLinkButton: UIButton!
    @IBOutlet weak var eventLinkButton: UIButton!
    @IBOutlet weak var tagLabel: CustomLabel!
    @IBOutlet weak var editButtonContainer: RoundUIView!
    @IBOutlet weak var deleteButtonContainer: RoundUIView!
    @IBOutlet weak var attendingEventButton: RoundedButton!
    @IBOutlet weak var eventUserAccountIcon: UIButton!
    @IBOutlet weak var eventUserCountLabel: UILabel!
    
    
    override func viewDidAppear(_ animated: Bool) {
        //Notification that event data has changed and should be reloaded
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reload_event_data),
                                               name:Notification.Name("RELOAD_EVENT_VC"),
                                               object: nil)

        queryIfUserIsAttendingEvent(event: selectedEvent)
        reloadAttendingUserData()
        setStackViewWidth()
        initializeMapKitView()
        configureFloatingSideButtonDesign(view: headerBackButtonContainer)
        configureFloatingSideButtonDesign(view: headerFavoriteIconContainer)
        setUpURLButtons()
        configureEditButton()
        configureDeleteButton()
        populateFieldsWithData()
        updateFavoriteIcon()
    }
    
    @objc func reload_event_data(notification:Notification) -> Void{
        reloadAttendingButton()
        reloadAttendingUserData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func populateFieldsWithData(){
        eventName.text = selectedEvent.name
        
        //Set the date and time of the event
        if let eventDate = selectedEvent.getDateCurrentTimeZone() {
            let df = DateFormatter()
            df.amSymbol = "AM"
            df.pmSymbol = "PM"
            df.dateFormat = "MMM dd YYYY ' - ' h:mm a"
            let dateString = df.string(from: eventDate)
            eventDateLabel.text = dateString
        }
        
        eventDetails.text = selectedEvent.details
        
        if selectedEvent.venue != "" && !selectedEvent.venue.isEmpty {
            locationDetailsButton.setTitle(selectedEvent.venue + " - " + selectedEvent.location, for: .normal)
        } else {
            locationDetailsButton.setTitle( selectedEvent.location, for: .normal)
            
        }

        contactDetailsButton.setTitle(selectedEvent.phoneNumber, for: .normal)
        let additionalContactInfoString = selectedEvent.contact
        if additionalContactInfoString.isEmpty || additionalContactInfoString == "" {
            additionalContactInfo.isHidden = true
        } else {
            additionalContactInfo.isHidden = false
            additionalContactInfo.text = "Additional Contact Info:\n" + additionalContactInfoString
        }
        tagLabel.text = ""
        if !selectedEvent.tag1.isEmpty && selectedEvent.tag1 != "" {
            tagLabel.text?.append("#" + selectedEvent.tag1)
        }
        if !selectedEvent.tag2.isEmpty && selectedEvent.tag2 != "" {
            tagLabel.text?.append(" #" + selectedEvent.tag2)
        }
        if !selectedEvent.tag3.isEmpty && selectedEvent.tag3 != "" {
            tagLabel.text?.append(" #" + selectedEvent.tag3)
        }
    }
    
    //Hide URL buttons if URLs are empty
    func setUpURLButtons(){
        if selectedEvent.ticketURL.isEmpty || selectedEvent.ticketURL == "" {
            ticketLinkButton.isHidden = true
        } else {
            ticketLinkButton.isHidden = false
        }
        if selectedEvent.eventURL.isEmpty || selectedEvent.eventURL == "" {
            eventLinkButton.isHidden = true
        } else {
            eventLinkButton.isHidden = false
        }
    }
    
    //Show favorite icon as a filled in star if event was favorited
    func updateFavoriteIcon(){
        if selectedEvent.favorite {
            favoriteButton.setImage(UIImage(named: "iconSelectedStar"), for: .normal)
            favoriteButton.tintColor = themeAccentYellow
        } else {
            favoriteButton.setImage(UIImage(named: "iconUnselectedStar"), for: .normal)
              favoriteButton.tintColor = themeDarkGray
        }
    }
    
    
    @IBAction func eventFavorited(_ sender: UIButton) {
        //Favorite button pushed
        selectedEvent.markFavorite()
        updateFavoriteIcon()
    }
    
    @IBAction func ticketLinkOpened(_ sender: UIButton) {
        
        //Ensure URL is properly formatted before opening
        if(!selectedEvent.ticketURL.hasPrefix("http://") && !selectedEvent.ticketURL.hasPrefix("https://")){
            selectedEvent.ticketURL = "http://" + selectedEvent.ticketURL
        }
        
        guard let url = URL(string: selectedEvent.ticketURL) else {
            return //Return if URL is no good
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }
    
    
    @IBAction func eventLinkOpened(_ sender: UIButton) {
        
        //Ensure URL is properly formatted before opening
        if(!selectedEvent.eventURL.hasPrefix("http://") && !selectedEvent.eventURL.hasPrefix("https://")){
            selectedEvent.eventURL = "http://" + selectedEvent.eventURL
        }
        
        guard let url = URL(string: selectedEvent.ticketURL) else {
            return //Return if URL is no good
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    
    func initializeMapKitView(){
        
        //Initialize map kit view to display location of event 
        
        getMapCoordinates(forAddress: selectedEvent.location) {
            (location) in
            guard let location = location else {
                //Handle geolocation error
                return
            }
            let initialLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let regionRadius: CLLocationDistance = 1000
            let coordinateRegion = MKCoordinateRegion(center: initialLocation.coordinate,
                                                      latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            // show marker on map
            let annotiation = MKPointAnnotation()
            annotiation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            self.mapView.addAnnotation(annotiation)
            self.mapView.setRegion(coordinateRegion, animated: false)
        }
        
    }
    
    func getMapCoordinates(forAddress address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
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
    
    
    @IBAction func returnButton(_ sender: UIButton) {
        
        performSegueToReturnBack()
        selectedEventAction = .creating //Reset the selected event action back to default
        
    }
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setStackViewWidth(){
        linksStackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 30).isActive = true
    }

    func configureEditButton(){
        if selectedEvent.loggedInUserCreatedTheEvent {
            editButtonContainer.isHidden = false
            configureFloatingSideButtonDesign(view: editButtonContainer)
        } else {
            editButtonContainer.isHidden = true
        }
    }
    
    func configureDeleteButton(){
        if selectedEvent.loggedInUserCreatedTheEvent {
            deleteButtonContainer.isHidden = false
            configureFloatingSideButtonDesign(view: deleteButtonContainer)
        } else {
            deleteButtonContainer.isHidden = true
        }
    }
    
    
    @IBAction func editEventButtonTapped(_ sender: UIButton) {
        selectedEventAction = .editing //Set the selected event action so that the createEventViewController opens in "editing" mode
        performSegue(withIdentifier: "editEventSegue", sender: self)
        
    }
    
    
    //Show alert confirming that user wants to delete the event, then delete the event
    @IBAction func deleteButtonTapped(_ sender: Any) {
        
        let deleteEventAlert = UIAlertController(title: "Delete Event?", message: "Deleting the Event Will Be Permanent ", preferredStyle: .alert)
        deleteEventAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
        }))
        deleteEventAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            deleteFirebaseEvent(event: selectedEvent, callback: {
                eventWasDeletedSuccessfully in
                if eventWasDeletedSuccessfully {
                    print("EVENT DELETED SUCCESSFULLY")
                    self.performSegueToReturnBack()
                } else {
                    print("EVENT UNABLE TO BE DELETED")
                    self.displayDeleteEventFailAlert()
                }
                
            })
        }))
        self.present(deleteEventAlert, animated: true)
        
    }
    
    func displayDeleteEventFailAlert(){
        let deleteEventFailAlert = UIAlertController(title: "Event unable to be deleted. Ensure network connection is established or retry later", message: nil, preferredStyle: .alert)
        deleteEventFailAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
        }))
        self.present(deleteEventFailAlert, animated: true)
    }
    
    
    @IBAction func eventLocationButtonTapped(_ sender: Any) {
        
        //If the location button is tapped, open the driving directions for the user using their default map application
        
        getMapCoordinates(forAddress: selectedEvent.location) {
            (location) in
            guard let location = location else {
                //Handle geolocation error
                return
            }
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), addressDictionary:nil))
            mapItem.name = selectedEvent.location
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
        
    }
    
    
    @IBAction func contactPhoneNumberButtonTapped(_ sender: Any) {
        
        //If contact phone number button is tapped, attempt to call the phone from the user's device
        
        let phoneNumberKit = PhoneNumberKit()
        do {
            let phoneNumber = try phoneNumberKit.parse(selectedEvent.phoneNumber)
            if !selectedEvent.phoneNumber.isEmpty && selectedEvent.phoneNumber != "" {
                callNumber(phoneNumber: String(phoneNumber.nationalNumber))
            }
        }
        catch {
            return
        }
        
        
    }
    
    //Function to call a phone # when the user clicks the contact info button
    func callNumber(phoneNumber:String) {
        
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    
    @IBAction func attendButtonTapped(_ sender: Any) {
        
    //If user is already attending the event, unattend the event
        //If user is not yet attending the event, attend the event
        
        if selectedEvent.loggedInUserAttendingTheEvent {
            selectedEvent.loggedInUserAttendingTheEvent = false
            unattendFirebaseEvent(event: selectedEvent)
        } else {
            selectedEvent.loggedInUserAttendingTheEvent = true
            attendFirebaseEvent(event: selectedEvent)
        }
        
           reloadAttendingButton()
        
    }
    
    func reloadAttendingButton(){
        
        if userIsNotLoggedIn(){
            attendingEventButton.isHidden = true
        } else {
            attendingEventButton.isHidden = false
        }
        
        if selectedEvent.loggedInUserAttendingTheEvent == false {
            attendingEventButton.setTitle("ATTEND", for: .normal)
            attendingEventButton.backgroundColor = themeAccentLightBlue
        } else {
            attendingEventButton.setTitle("UNATTEND", for: .normal)
            attendingEventButton.backgroundColor = themeAccentRed
        }
        
    }
    
    func reloadAttendingUserData(){
        
        if selectedEvent.userCount > 0 {
            eventUserCountLabel.isHidden = false
            eventUserAccountIcon.isHidden = false
            eventUserCountLabel.text = String(selectedEvent.userCount)
        } else {
            eventUserCountLabel.isHidden = true
            eventUserAccountIcon.isHidden = true
        }
        
    }
    
    
}
