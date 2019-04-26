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
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    func initializeMapKitView(){
        
        getCoordinates(forAddress: selectedEvent.address) {
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
            self.mapView.setRegion(coordinateRegion, animated: true)
        }
        
    }
    
    func getCoordinates(forAddress address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
