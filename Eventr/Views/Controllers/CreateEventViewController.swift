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

class CreateEventViewController: UIViewController {
    
    
    var ref: DatabaseReference!
    let categoryDropDown = DropDown()
    let formatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCalendarView()
    }
    
    @IBOutlet weak var eventName: UITextView!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var eventLocation: UITextView!
    @IBOutlet weak var eventTicketURL: UITextView!
    @IBOutlet weak var eventURL: UITextView!
    @IBOutlet weak var eventContactInfo: UITextView!
    @IBOutlet weak var eventTag1: UITextView!
    @IBOutlet weak var eventTag2: UITextView!
    @IBOutlet weak var eventTag3: UITextView!
    @IBOutlet weak var selectCategoryButton: UIButton!
    @IBOutlet weak var paidSwitch: UISwitch!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    
    @IBAction func selectCategory(_ sender: UIButton) {
      
    
        
        //Set up category selection dropdown menu
        categoryDropDown.anchorView = selectCategoryButton
        categoryDropDown.dataSource = allEventCategories.strings()
        categoryDropDown.cellConfiguration = { (index, item) in return "\(item)" }
        
        categoryDropDown.selectionAction = { (index: Int, item: String) in
            self.selectCategoryButton.titleLabel?.text = item
        }
        categoryDropDown.width = 140
        categoryDropDown.bottomOffset = CGPoint(x: 0, y:(categoryDropDown.anchorView?.plainView.bounds.height)!)
        categoryDropDown.show()
        
       
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
        
        let categoryString = selectCategoryButton.titleLabel?.text
        let category = stringToEventCategory(string: categoryString!)
        
        let newEvent = Event(name: eventName.text.trimmingCharacters(in: .whitespacesAndNewlines), category: category, address: eventLocation.text.trimmingCharacters(in: .whitespacesAndNewlines), details: eventDescription.text.trimmingCharacters(in: .whitespacesAndNewlines), contact: eventContactInfo.text.trimmingCharacters(in: .whitespacesAndNewlines), ticketURL: eventTicketURL.text.trimmingCharacters(in: .whitespacesAndNewlines), eventURL: eventURL.text.trimmingCharacters(in: .whitespacesAndNewlines), tag1: eventTag1.text.trimmingCharacters(in: .whitespacesAndNewlines), tag2: eventTag2.text.trimmingCharacters(in: .whitespacesAndNewlines), tag3: eventTag3.text.trimmingCharacters(in: .whitespacesAndNewlines), paid: paidSwitch.isOn)
        
        createFirebaseEvent(event: newEvent, callback: {
            bool in
            if bool {
                print("EVENT CREATED SUCCESSFULLY")
                self.performSegueToReturnBack()
            } else {
                let createEventFailAlert = UIAlertController(title: "Event unable to be created. Ensure network connection is established or retry later", message: nil, preferredStyle: .alert)
                createEventFailAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                }))
                self.present(createEventFailAlert, animated: true)
            }})
        
        

    }
    
    
}
