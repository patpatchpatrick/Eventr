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
                    sideMenuAccountButton.setImage(image, for: .normal)
       
                }
            }
        }
        
        accountSettingsIcon.layer.cornerRadius = 20.0
        accountSettingsIcon.layer.borderWidth = 2.0
        accountSettingsIcon.layer.borderColor = themeAccentSecondary.cgColor
        accountSettingsIcon.clipsToBounds = true
        sideMenuAccountButton.clipsToBounds = true
        sideMenuAccountButton.layer.cornerRadius = 20.0
        sideMenuAccountButton.clipsToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(accountSettingsIconTapped(tapGestureRecognizer:)))
        
        accountSettingsIcon.isUserInteractionEnabled = true
        accountSettingsIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setUpLogOutIcon(){
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(logOutIconTapped(tapGestureRecognizer:)))
        
        sideMenuLogOutIcon.isUserInteractionEnabled = true
        sideMenuLogOutIcon.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    func setUpLocationEntryField(){
        locationEntryField.attributedPlaceholder = NSAttributedString(string: "Enter Location",
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func setUpAddCategoryImage(){
        
        //Set up category selection dropdown menu
        addCategoryDropDown.anchorView = addCategoryImage
        addCategoryDropDown.dataSource = userUnselectedEventCategories.strings()
        addCategoryDropDown.cellConfiguration = { (index, item) in return "\(item)" }
        
        addCategoryImage.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addCategoryToToolbar))
        tapGestureRecognizer.numberOfTapsRequired = 1
        addCategoryImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setUpSubtractCategoryImage(){
        
        //Set up category selection dropdown menu
        subtractCategoryDropDown.anchorView = subtractCategoryImage
        subtractCategoryDropDown.dataSource = userSelectedEventCategories.strings()
        subtractCategoryDropDown.cellConfiguration = { (index, item) in return "\(item)" }
        
        subtractCategoryImage.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(removeCategoryFromToolbar))
        tapGestureRecognizer.numberOfTapsRequired = 1
        subtractCategoryImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setUpCategoryStackView(){
        
        //Add action to all categories button (permanent button)
         allCategoriesButton.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
        
        //Add all user selected categories to the stackview of category buttons that can be selected
        for eventCategory in userSelectedEventCategories.set {
          addButtonToStackView(for: eventCategory)
        }
        
        
    }
    
    func hideSideMenu(){
        //Animated side menu
        //All icons move horizontally out of the menu in curved fashion
        //The outer icons move more quickly than the inner icons
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.backgroundView.transform = .identity
            self.backgroundViewSideBorder.transform = .identity
        })
        
        UIView.animate(withDuration: 0.4, animations: {
            self.sideMenuShade.alpha = 0
            
        })
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.sideMenuAccountButton.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
            self.sideMenuAccountButtonLabel.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
            self.sideMenuLogOutIcon.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
            self.sideMenuLogOutIconLabel.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
        })
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.sideMenuMyEventsButton.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
            self.sideMenuMyEventsButtonLabel.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
            self.sideMenuSettingsButton.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
            self.sideMenuSettingsButtonLabel.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
        })
        UIView.animate(withDuration: 0.4, delay: 0.2, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.sideMenuFavoritedButton.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
            self.sideMenuFavoritedButtonLabel.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
        })
        UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseOut, animations: {
            self.sideMenuCurveImage.transform = CGAffineTransform(translationX: -self.sideMenuCurveImage.frame.width, y: 0)
        }) { success in
            self.sideMenu.isHidden = true
        }
    }
    
    //Set up user details in the side menu
    func setUpUser(){
        guard let userEmail = Auth.auth().currentUser?.email else {
            return
        }
        sideMenuAccountButtonLabel.text = userEmail
    }
    
    func showSideMenu(){
        //Animated side menu
        //All icons move horizontally into the menu in curved fashion
        //The outer icons move more slowly than the inner icons
        sideMenu.isHidden = false
        
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.backgroundView.transform = CGAffineTransform(translationX: self.sideMenu.frame.width + 5, y: 0)
             self.backgroundViewSideBorder.transform = CGAffineTransform(translationX: self.sideMenu.frame.width + 5, y: 0)
        })
        
        
        UIView.animate(withDuration: 0.4, animations: {
            self.sideMenuShade.alpha = 0.1
            
        })
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            self.sideMenuCurveImage.transform = .identity
        })
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.sideMenuFavoritedButton.transform = .identity
            self.sideMenuFavoritedButtonLabel.transform = .identity
        })

        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.sideMenuMyEventsButton.transform = .identity
            self.sideMenuMyEventsButtonLabel.transform = .identity
            self.sideMenuSettingsButton.transform = .identity
            self.sideMenuSettingsButtonLabel.transform = .identity
        })

        UIView.animate(withDuration: 0.4, delay: 0.2, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.sideMenuAccountButton.transform = .identity
            self.sideMenuAccountButtonLabel.transform = .identity
            self.sideMenuLogOutIcon.transform = .identity
            self.sideMenuLogOutIconLabel.transform = .identity
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
    
    func addButtonToStackView(for eventCategory: EventCategory){
        
        let button = UIButton()
        button.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        button.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        button.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .right
        button.tintColor = UIColor.white
        button.alpha = 0.25
        let imageView = UIImageView()
        imageView.image = eventCategory.image()
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 30.0, height: 30.0 )
        button.addSubview(imageView)
        button.bringSubviewToFront(button.imageView!)
        button.tag = eventCategory.index()
        
        button.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
        
        categoriesStackView.addArrangedSubview(button)
        categoryViewsInStackView[eventCategory.index()] = button //Map of category indices and views that is used when removing views from stackview
        
    }
    
    @objc func addCategoryToToolbar(_ sender: UITapGestureRecognizer) {
        //When the 'Add Category' image is tapped, show dropDown menu for user to select categories
        // to add to categories stackview
        // Add the user selected category to the StackView
        
        addCategoryDropDown.selectionAction = { (index: Int, item: String) in
            addImageToCategoriesStackView(for: item)
        }
        addCategoryDropDown.backgroundColor = themeMedium
        addCategoryDropDown.textColor = UIColor.white
        if let dropDownFont = UIFont(name: "Raleway-Regular",
                                     size: 14.0) {
            addCategoryDropDown.textFont = dropDownFont
        }
        addCategoryDropDown.width = 140
        addCategoryDropDown.bottomOffset = CGPoint(x: 0, y:(addCategoryDropDown.anchorView?.plainView.bounds.height)!)
        addCategoryDropDown.show()
        
        
        func addImageToCategoriesStackView(for categoryName: String){
            
            //If a category is selected from the dropdown menu, add the category to the categories stack view
            //Only add the category if it isn't already in the stackview (i.e. userSelectedEventCategories)
            //After adding the category, remove it from the userUnselectedEventCategories
            //Update the dropDown list data to include the changes
            
            let eventCat = stringToEventCategory(string: categoryName)
            
            if(!userSelectedEventCategories.containsCategory(eventCategory: eventCat)){
                
                addButtonToStackView(for: eventCat)
                UIView.animate(withDuration: 0.5){
                    //button.layoutIfNeeded()
                    //button.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
                }
                
                
                userSelectedEventCategories.add(eventCategory: eventCat)
                userUnselectedEventCategories.remove(eventCategory: eventCat)
                let preferences = UserDefaults.standard
                preferences.set(true, forKey: eventCat.text())
                preferences.synchronize()//Add category to prefs so it stays in the user's toolbar when app is reloaded
                addCategoryDropDown.dataSource = userUnselectedEventCategories.strings()
                subtractCategoryDropDown.dataSource = userSelectedEventCategories.strings()
            }
            
        }
        
    }
    
    @objc func removeCategoryFromToolbar(_ sender: UITapGestureRecognizer) {
        //When the 'Remove Category' image is tapped, show dropDown menu for user to select category to remove from toolbar
        
        subtractCategoryDropDown.selectionAction = { (index: Int, item: String) in
            removeImageFromCategoriesStackView(for: item)
        }
        subtractCategoryDropDown.backgroundColor = themeMedium
        subtractCategoryDropDown.textColor = UIColor.white
        if let dropDownFont = UIFont(name: "Raleway-Regular",
                                     size: 14.0) {
            subtractCategoryDropDown.textFont = dropDownFont
        }
        subtractCategoryDropDown.width = 140
        subtractCategoryDropDown.bottomOffset = CGPoint(x: 0, y:(addCategoryDropDown.anchorView?.plainView.bounds.height)!)
        subtractCategoryDropDown.show()
        
        
        func removeImageFromCategoriesStackView(for categoryName: String){
            
            //If a category is selected from the dropdown menu, add the category to the categories stack view
            //Only add the category if it isn't already in the stackview (i.e. userSelectedEventCategories)
            //After adding the category, remove it from the userUnselectedEventCategories
            //Update the dropDown list data to include the changes
            
            let eventCat = stringToEventCategory(string: categoryName)
            
            if(!userUnselectedEventCategories.containsCategory(eventCategory: eventCat)){
                
                guard let categoryView = categoryViewsInStackView[eventCat.index()] else {
                    return
                }
                
                
                categoryView.removeFromSuperview()
                
                
                userUnselectedEventCategories.add(eventCategory: eventCat)
                userSelectedEventCategories.remove(eventCategory: eventCat)
                let preferences = UserDefaults.standard
                preferences.set(false, forKey: eventCat.text())
                preferences.synchronize()//Remove category from prefs so it stays out of the user's toolbar when app is reloaded
                addCategoryDropDown.dataSource = userUnselectedEventCategories.strings()
                subtractCategoryDropDown.dataSource = userSelectedEventCategories.strings()
            }
            
        }
        
    }
    
    @objc func selectCategory(sender: UIButton!) {
        //Select category from category toolbar and make all other categories have 50% opacity so that the selected category stands out
        for subview in categoriesStackView.arrangedSubviews{
            subview.tintColor = UIColor.white
            subview.alpha = 0.25
        }
        UIView.animate(withDuration: 0.5){
            sender.tintColor = UIColor.white
            sender.alpha = 0.75
        }
        selectedCategory = sender.tag //The tag of the sending button matches the index of whichever category was selected 
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
    
    func loadFavoriteEvents(){
        hideSideMenu()
        showListDescriptor()
        queryFirebaseFavoriteEvents()
    }
    
    //Show the list descriptor which describes the type of events being shown
    func showListDescriptor(){
        listDescriptorLabel.text = "Favorited"
        listDescriptorIcon.image = UIImage(named: "catIconFavorite")
        listDescriptorCover.isHidden = false
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.listDescriptor.transform = .identity
            self.listDescriptorReturnButton.transform = .identity
        })
    }
    
     //Hide the list descriptor which describes the type of events being shown
    func hideListDescriptor(){
        events.removeAll()
        reloadEventTableView()
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.listDescriptor.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width - self.listDescriptor.frame.width, y: 0)
            self.listDescriptorReturnButton.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width - self.listDescriptor.frame.width, y: 0)
        })
            listDescriptorCover.isHidden = true
    }
    
    func setUpMainButtons(){
        configureMainButtonDesign(button: mainDateButton)
        configureMainButtonDesign(button: mainLocationButton)
        configureMainButtonDesign(button: mainSearchButton)
    }
    
    func configureMainButtonDesign(button: RoundedButton){
        let shadowSize : CGFloat = 0.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: button.frame.size.width + shadowSize,
                                                   height: button.frame.size.height + shadowSize))
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowOpacity = 0.45
        button.layer.shadowRadius = 10.0
        button.layer.masksToBounds = false
        button.layer.shadowPath = shadowPath.cgPath
    }
    
    func configureDateAndSearchContainers(){
        hideSearchCollectionContainer()
        hideDateSelectionContainer()
    }
    
    func showSearchSelectionContainer(){
        searchSelectionContainer.isHidden = false
    }
    
    func hideSearchCollectionContainer(){
        searchSelectionContainer.isHidden = true
    }
    
    func showDateSelectionContainer(){
        dateSelectionContainer.isHidden = false
    }
    
    func hideDateSelectionContainer(){
        dateSelectionContainer.isHidden = true
    }
    
}
