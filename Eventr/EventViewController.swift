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

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initializeMapKitView()
        eventName.text = selectedEvent.name
        eventDetails.text = selectedEvent.details
        locationDetails.text = selectedEvent.address
        contactDetails.text = selectedEvent.contact
        updateFavoriteIcon()
    }
    
    func updateFavoriteIcon(){
        if selectedEvent.favorite {
            favoriteButton.setImage(UIImage(named: "iconSelectedStar"), for: .normal)
        } else {
            favoriteButton.setImage(UIImage(named: "iconUnselectedStar"), for: .normal)
        }
    }
    
    
    @IBOutlet weak var eventName: UILabel!
    
    
    @IBOutlet weak var eventDetails: UITextView!
    
    
    @IBOutlet weak var locationDetails: UITextView!
    
    
    @IBOutlet weak var contactDetails: UITextView!
    
    
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBAction func eventFavorited(_ sender: UIButton) {
        //Favorite button pushed
        selectedEvent.markFavorite()
        updateFavoriteIcon()
    }
    
    
    
    @IBOutlet weak var linksStackView: UIStackView!
    
    @IBOutlet weak var mapView: MKMapView!
    
    
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


}
