//
//  EventViewController.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/26/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import UIKit
import MapKit

class EventViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet weak var headerBackButtonContainer: RoundUIView!
    @IBOutlet weak var headerFavoriteIconContainer: UIView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDetails: UITextView!
    @IBOutlet weak var locationDetails: UILabel!
    @IBOutlet weak var contactDetails: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var linksStackView: UIStackView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var ticketLinkButton: UIButton!
    @IBOutlet weak var eventLinkButton: UIButton!
    @IBOutlet weak var tagLabel: CustomLabel!
    @IBOutlet weak var editButtonContainer: RoundUIView!
    
    
    override func viewDidAppear(_ animated: Bool) {
        setStackViewWidth()
        initializeMapKitView()
        configureFloatingSideButtonDesign(view: headerBackButtonContainer)
        configureFloatingSideButtonDesign(view: headerFavoriteIconContainer)
        setUpURLButtons()
        configureEditButton()
        eventName.text = selectedEvent.name
        eventDetails.text = selectedEvent.details
        locationDetails.text = selectedEvent.address
        contactDetails.text = selectedEvent.contact
        tagLabel.text = "#" + selectedEvent.tag1 + " #" + selectedEvent.tag2 + " #" + selectedEvent.tag3
        updateFavoriteIcon()
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
        
        getMapCoordinates(forAddress: selectedEvent.address) {
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
        if selectedEvent.myEvent {
            editButtonContainer.isHidden = false
            configureFloatingSideButtonDesign(view: editButtonContainer)
        } else {
            editButtonContainer.isHidden = true
        }
    }

}
