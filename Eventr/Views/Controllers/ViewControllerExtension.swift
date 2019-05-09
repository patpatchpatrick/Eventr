//
//  ViewControllerExtension.swift
//  Eventr
//
//  Created by Patrick Doyle on 5/7/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import DropDown
import Firebase
import FirebaseAuth
import GoogleSignIn

extension ViewController{
    
    func setUpAccountSettingsImage(){
        
        //Set the profile photo of the logged in user if they have one
        if Auth.auth().currentUser?.photoURL != nil {
            let pic = Auth.auth().currentUser?.photoURL
            if pic != nil {
                let data = try? Data(contentsOf: pic!)
                
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    accountSettingsIcon.image = image
                    accountSettingsIcon.layer.cornerRadius = 20.0
                    accountSettingsIcon.clipsToBounds = true
                    sideMenuAccountButton.clipsToBounds = true
                    sideMenuAccountButton.setImage(image, for: .normal)
                    sideMenuAccountButton.layer.cornerRadius = 20.0
                    sideMenuAccountButton.clipsToBounds = true
                }
            }
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(accountSettingsIconTapped(tapGestureRecognizer:)))
        
        accountSettingsIcon.isUserInteractionEnabled = true
        accountSettingsIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setUpLogOutIcon(){
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(logOutIconTapped(tapGestureRecognizer:)))
        
        logOutIcon.isUserInteractionEnabled = true
        logOutIcon.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    func setUpAddCategoryImage(){
        
        //Set up category selection dropdown menu
        categoryDropDown.anchorView = addCategoryImage
        categoryDropDown.dataSource = userUnselectedEventCategories.strings()
        categoryDropDown.cellConfiguration = { (index, item) in return "\(item)" }
        
        addCategoryImage.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(categoryImageTapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        addCategoryImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setUpCategoryStackView(){
        
        //Add action to all categories button (permanent button)
         allCategoriesButton.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
        
        //Add all user selected categories to the stackview of category images that can be selected
        for eventCategory in userSelectedEventCategories.set {
            let imageView = UIImageView()
            imageView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
            imageView.alpha = 0.5
            imageView.image = eventCategory.image()
            categoriesStackView.addArrangedSubview(imageView)
        }
        
        
    }
    
    func hideSideMenu(){
        UIView.animate(withDuration: 0.4, animations: {
            self.sideMenu.alpha = 0
            self.sideMenuShade.alpha = 0
            
        })
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            self.sideMenuCurveImage.transform = CGAffineTransform(translationX: -self.sideMenuCurveImage.frame.width, y: 0)
        })
    }
    
    //Set up user details in the side menu
    func setUpUser(){
        guard let userEmail = Auth.auth().currentUser?.email else {
            return
        }
        sideMenuUserName.text = userEmail
    }
    
    func showSideMenu(){
        UIView.animate(withDuration: 0.4, animations: {
            self.sideMenu.alpha = 1
            self.sideMenuShade.alpha = 0.75
            
        })
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            self.sideMenuCurveImage.transform = .identity
        })
        
    }
    
    func logOut(){
        
        do {
            try Auth.auth().signOut()
            try GIDSignIn.sharedInstance()?.signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
        
    }
    
    @objc func categoryImageTapped(_ sender: UITapGestureRecognizer) {
        //When the 'Add Category' image is tapped, show dropDown menu for user to select categories
        // to add to categories stackview
        // Add the user selected category to the StackView
        
        categoryDropDown.selectionAction = { (index: Int, item: String) in
            addImageToCategoriesStackView(for: item)
        }
        categoryDropDown.backgroundColor = UIColor(red: 106/255.0, green: 138/255.0, blue: 244/255.0, alpha: 1.00)
        categoryDropDown.textColor = UIColor.white
        categoryDropDown.width = 140
        categoryDropDown.bottomOffset = CGPoint(x: 0, y:(categoryDropDown.anchorView?.plainView.bounds.height)!)
        categoryDropDown.show()
        
        
        func addImageToCategoriesStackView(for categoryName: String){
            
            //If a category is selected from the dropdown menu, add the category to the categories stack view
            //Only add the category if it isn't already in the stackview (i.e. userSelectedEventCategories)
            //After adding the category, remove it from the userUnselectedEventCategories
            //Update the dropDown list data to include the changes
            
            let eventCat = stringToEventCategory(string: categoryName)
            
            if(!userSelectedEventCategories.containsCategory(eventCategory: eventCat)){
                
                let button = UIButton()
                button.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
                button.widthAnchor.constraint(equalToConstant: 500.0).isActive = true
                button.contentMode = .scaleAspectFit
                button.contentHorizontalAlignment = .right
                button.alpha = 0.5
                let imageView = UIImageView()
                imageView.image = eventCat.image()
                imageView.contentMode = .scaleAspectFit
                imageView.frame = CGRect(x: 0, y: 0, width: 30.0, height: 30.0 )
                button.addSubview(imageView)
                button.bringSubviewToFront(button.imageView!)
                
                //button.setImage(eventCat.image(), for: .normal)
                button.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
                
                categoriesStackView.addArrangedSubview(button)
                UIView.animate(withDuration: 0.5){
                    button.layoutIfNeeded()
                    button.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
                }
                
                
                userSelectedEventCategories.add(eventCategory: eventCat)
                userUnselectedEventCategories.remove(eventCategory: eventCat)
                categoryDropDown.dataSource = userUnselectedEventCategories.strings()
            }
            
        }
        
    }
    
    @objc func selectCategory(sender: UIButton!) {
        //Select category from category toolbar and make all other categories have 50% opacity so that the selected category stands out
        for subview in categoriesStackView.arrangedSubviews{
            subview.alpha = 0.5
        }
        UIView.animate(withDuration: 0.5){
            sender.alpha = 1.0
        }
    }
    
    //User's location returned
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        currentLocation = manager.location
        
        DispatchQueue.main.async {
            self.currentLocationRetrieved()
        }
    }
    
    func currentLocationRetrieved(){
        locationEntryField.text = "Current Location"
        locationEntryField.endEditing(true)
    }
    
    // Method to run when upvote imageview is tapped
    @objc func upvoteTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        guard let upvoteImage = tapGestureRecognizer.view as? UIImageView else {return}
        //If an upvote arrow was clicked, upvote the event
        events[upvoteImage.tag].upvote()
        eventTableView.reloadData()
        print(events[upvoteImage.tag].name)
        if (upvoteImage.tag == 0) //Give your image View tag
        {
            //navigate to next view
        }
        else{
            
        }
    }
    
    
}
