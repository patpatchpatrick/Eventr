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

class CreateEventViewController: UIViewController {
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBOutlet weak var eventName: UITextView!
    
    @IBOutlet weak var eventDescription: UITextView!
    
    @IBOutlet weak var eventLocation: UITextView!
    
    @IBOutlet weak var eventTicketURL: UITextView!
    
    @IBOutlet weak var eventURL: UITextView!
    
    @IBOutlet weak var eventContactInfo: UITextView!
    
    @IBOutlet weak var eventTags: UITextView!
    

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
    
    
    @IBAction func createEvent(_ sender: UIButton) {
        
        let newEvent = Event(name: eventName.text.trimmingCharacters(in: .whitespacesAndNewlines), address: eventLocation.text.trimmingCharacters(in: .whitespacesAndNewlines), details: eventDescription.text.trimmingCharacters(in: .whitespacesAndNewlines), contact: eventContactInfo.text.trimmingCharacters(in: .whitespacesAndNewlines), ticketURL: eventTicketURL.text.trimmingCharacters(in: .whitespacesAndNewlines), eventURL: eventURL.text.trimmingCharacters(in: .whitespacesAndNewlines), tags: eventTags.text.trimmingCharacters(in: .whitespacesAndNewlines))
        
        createFirebaseEvent(event: newEvent)
        
        print("EVENT CREATED SUCCESSFULLY")
        
        

    }
    
    
}
