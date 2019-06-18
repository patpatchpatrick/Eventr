//
//  CreateEventViewController.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/30/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import DropDown
import JTAppleCalendar
import PhoneNumberKit

class CreateEventViewController: UIViewController {
    
    
    var ref: DatabaseReference!
    var selectedCityForCreation = "" //the city selected by the user when creating an event
    let categoryDropDown = DropDown()
    let creationSelectCityDropDown = DropDown()
    let formatter = DateFormatter()
    var selectedCategoryString = "Misc"
    var eventDate = Date()
    var eventTime = Date()
    var previousEvent: Event?  //Variable to keep track of previous event so that it can be deleted when an event is changed

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        createEventStackView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 45).isActive = true //set max width on the main stackview container
        configureCalendarView()
        configureTimePicker()
        configureFloatingSideButtonDesign(view: headerBackButtonContainer)
        configureFloatingSideButtonDesign(view: createEventButtonContainer)
        configureTextEntryFieldsDesign()
        setCalendarButtonTitleToBeSelectedTime()
        
        //Configure the screen depending on whether user is creating or editing an event
        switch selectedEventAction {
        case .creating: configureCreateEventScreen()
        case .editing: configureEditEventScreen()
        }
    }
    
    
    @IBOutlet weak var headerBackButtonContainer: RoundUIView!
    
    @IBOutlet weak var createEventStackView: UIStackView!
    
    @IBOutlet weak var createEventButtonContainer: RoundUIView!
    @IBOutlet weak var eventName: UITextView!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventLocation: UITextView!
    @IBOutlet weak var selectCityButton: UIButton!
    @IBOutlet weak var eventVenueName: UITextView!
    @IBOutlet weak var eventTicketURL: UITextView!
    @IBOutlet weak var eventURL: UITextView!
    @IBOutlet weak var eventContactInfo: UITextView!
    @IBOutlet weak var eventPhoneNumberTextField: PhoneNumberTextField!
    @IBOutlet weak var eventTag1: UITextView!
    @IBOutlet weak var eventTag2: UITextView!
    @IBOutlet weak var eventTag3: UITextView!
    @IBOutlet weak var selectCategoryButton: UIButton!
    @IBOutlet weak var paidSwitch: UISwitch!
    @IBOutlet weak var eventPrice: UITextView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var calendarContainer: UIView!
    @IBOutlet weak var selectEventDateButton: UIButton!
    @IBOutlet weak var selectEventTimeButton: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var timePickerContainer: UIView!
    @IBOutlet weak var eventDuration: UITextView!
    
    @IBOutlet weak var createEventButton: RoundedButton!
    
    
    
    @IBAction func selectEventDate(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.calendarContainer.isHidden = false
        })
        calendarView.selectDates([eventDate])
        calendarView.scrollToDate(eventDate)
    }
    
    @IBAction func previousMonth(_ sender: UIButton) {
        calendarView.scrollToSegment(.previous)
    }
    
    
    @IBAction func nextMonth(_ sender: UIButton) {
        calendarView.scrollToSegment(.next)
    }
    
    //Calendar date selected checkmark tapped
    @IBAction func dateSelected(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.calendarContainer.isHidden = true
        })
    }
    
    //Calendar date discarded "X" tapped
    @IBAction func dateDiscarded(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.calendarContainer.isHidden = true
        })
        
        let df = DateFormatter()
        df.dateFormat = "MMM dd YYYY"
        let dateString = df.string(from: Date())
        selectEventDateButton.setTitle(dateString, for: .normal)
        calendarView.selectDates([Date()])
    }
    
    
    @IBAction func selectEventTime(_ sender: UIButton) {
        timePickerContainer.isHidden = false
    }
    
    @IBAction func timeChanged(_ sender: UIDatePicker) {
        eventTime = sender.date
        setCalendarButtonTitleToBeSelectedTime()
    }
    
     //Calendar time discarded "X" tapped
    @IBAction func timeDiscarded(_ sender: Any) {
        eventTime = Date() //Reset time to NOW
        setCalendarButtonTitleToBeSelectedTime()
        timePickerContainer.isHidden = true
        
    }
    
    
    //Calendar time selected checkmark tapped
    @IBAction func timeSelected(_ sender: UIButton) {
        setCalendarButtonTitleToBeSelectedTime()
        timePickerContainer.isHidden = true
    }    
    
    @IBAction func selectCategory(_ sender: UIButton) {
      
        //Set up category selection dropdown menu
        categoryDropDown.anchorView = selectCategoryButton
        categoryDropDown.dataSource = allEventCategories.strings()
        categoryDropDown.cellConfiguration = { (index, item) in return "\(item)" }
        
        categoryDropDown.selectionAction = { (index: Int, item: String) in
            self.selectedCategoryString = item
            self.selectCategoryButton.titleLabel?.text = item
        }
        categoryDropDown.width = 140
        categoryDropDown.backgroundColor = themeMedium
        categoryDropDown.textColor = themeDarkGray
        if let dropDownFont = UIFont(name: "Raleway-Regular",
                                     size: 14.0) {
         categoryDropDown.textFont = dropDownFont
        }
        categoryDropDown.bottomOffset = CGPoint(x: 0, y:(categoryDropDown.anchorView?.plainView.bounds.height)!)
        categoryDropDown.show()
        
       
    }
    
    
    @IBAction func selectCityButtonTapped(_ sender: Any) {
        
        //Set up category selection dropdown menu
        creationSelectCityDropDown.anchorView = selectCityButton
        creationSelectCityDropDown.dataSource = citySelectButtonArray
        creationSelectCityDropDown.cellConfiguration = { (index, item) in return "\(item)" }
        
        creationSelectCityDropDown.selectionAction = { (index: Int, item: String) in
            let fullCityName = item
            let cityAbbreviation = getCityAbbreviation(fullCityName: fullCityName)
            self.selectCityButton.setTitle("City: Greater " + fullCityName + " Area", for: .normal)
            self.selectedCityForCreation = cityAbbreviation
        }
        creationSelectCityDropDown.width = 140
        creationSelectCityDropDown.backgroundColor = themeMedium
        creationSelectCityDropDown.textColor = themeDarkGray
        if let dropDownFont = UIFont(name: "Raleway-Regular",
                                     size: 14.0) {
            categoryDropDown.textFont = dropDownFont
        }
        creationSelectCityDropDown.bottomOffset = CGPoint(x: 0, y:(creationSelectCityDropDown.anchorView?.plainView.bounds.height)!)
        creationSelectCityDropDown.show()
        
    }
    
    
    //If previous screen button is pushed, show discard data alert
    @IBAction func previousScreen(_ sender: UIButton) {
        
        let discardAlert = UIAlertController(title: "Discard Entered Data?", message: nil, preferredStyle: .alert)
        discardAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
        }))
        discardAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.performSegueToReturnBack()
        }))
        
        self.present(discardAlert, animated: true)
        
        
    }
    
    func performSegueToReturnBack()  {
        selectedEventAction = .creating //Reset the selectedEventAction back to default when exiting the screen
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //Create a new event and write to firebase
    //If created successfully, segue to previous screen will be run
    //If error occurs, alert will fire
    @IBAction func createEvent(_ sender: UIButton) {
        
        guard let eventDuration = getValidEventDuration() else {
            displayAlertWithOKButton(text: "Please Enter Valid Event Duration in Numeric Format")
            return
        }
        
        if selectedCityForCreation == "" {
            displayAlertWithOKButton(text: "Please Select a City")
        }
        
        if requiredFieldsAreMissingData() {
            displayAlertWithOKButton(text: "Please Enter All Required Fields")
            return
        }
        
        guard let eventPhoneNumber = getValidPhoneNumberOrDisplayAlert() else {
            return
        }
        
        //Selected Category String keeps track of which category was selected using the dropdown menu
        let category = stringToEventCategory(string: selectedCategoryString)
    
        guard let eventDate = getFirebaseGMTDate(date: eventDate, time: eventTime) else {
            displayDateErrorNotification()
            return
        }
        
        let newEvent = Event(name: eventName.text.trimmingCharacters(in: .whitespacesAndNewlines), category: category, date: eventDate, city: selectedCityForCreation, address: eventLocation.text.trimmingCharacters(in: .whitespacesAndNewlines), venue: eventVenueName.text.trimmingCharacters(in: .whitespacesAndNewlines), details: eventDescription.text.trimmingCharacters(in: .whitespacesAndNewlines), contact: eventContactInfo.text.trimmingCharacters(in: .whitespacesAndNewlines), phoneNumber: eventPhoneNumber.numberString, ticketURL: eventTicketURL.text.trimmingCharacters(in: .whitespacesAndNewlines), eventURL: eventURL.text.trimmingCharacters(in: .whitespacesAndNewlines), tag1: eventTag1.text.trimmingCharacters(in: .whitespacesAndNewlines), tag2: eventTag2.text.trimmingCharacters(in: .whitespacesAndNewlines), tag3: eventTag3.text.trimmingCharacters(in: .whitespacesAndNewlines), paid: paidSwitch.isOn, price: "")
        newEvent.duration = eventDuration
        newEvent.upvoteCount = selectedEvent.upvoteCount
        newEvent.userCount = selectedEvent.userCount
        newEvent.setUpDurationDate()
        newEvent.price = eventPrice.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let dailyMaxEventsReached = checkIfUserDefaultsDailyEventMaximumReached()
        if dailyMaxEventsReached {
            displayMaxDailyEventsReachedAlert()
            return
        }
        
        //If the event is being updated, delete the old event and create a new event.
        //Otherwise, create a new event.
        
        if selectedEventAction == .editing {
            guard let prevEvent = previousEvent else {return}
            deleteFirebaseEvent(event: prevEvent, callback: {
                eventDeletedSuccessfully in
                
                if eventDeletedSuccessfully {
                    
                    createOrUpdateFirebaseEvent(viewController: self, event: newEvent, createOrUpdate: selectedEventAction, callback: {
                        eventWasCreatedSuccessfully in
                        if eventWasCreatedSuccessfully {
                            switch selectedEventAction {
                            case .creating: print("EVENT CREATED SUCCESSFULLY")
                            case .editing: print("EVENT UPDATED SUCCESSFULLY")
                            selectedEvent = newEvent //Update the selected event to be the new event so that data reloads properly on the EventViewController screen
                            }
                            self.incrementUserDefaultsDailyEventCount()
                            self.performSegueToReturnBack()
                        } else {
                            self.displayCreateEventFailAlert()
                        }})
                    
                }
                
            })
            
        } else {
            
            createOrUpdateFirebaseEvent(viewController: self, event: newEvent, createOrUpdate: selectedEventAction, callback: {
                eventWasCreatedSuccessfully in
                if eventWasCreatedSuccessfully {
                    switch selectedEventAction {
                    case .creating: print("EVENT CREATED SUCCESSFULLY")
                    case .editing: print("EVENT UPDATED SUCCESSFULLY")
                    selectedEvent = newEvent //Update the selected event to be the new event so that data reloads properly on the EventViewController screen
                    }
                    self.incrementUserDefaultsDailyEventCount()
                    self.performSegueToReturnBack()
                } else {
                    self.displayCreateEventFailAlert()
                }})
            
        }
    
        
    }
    
    
}
