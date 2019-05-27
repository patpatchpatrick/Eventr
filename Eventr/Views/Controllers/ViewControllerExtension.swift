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
        if let pic = Auth.auth().currentUser?.photoURL {
            let data = try? Data(contentsOf: pic)
            if let imageData = data {
                let image = UIImage(data: imageData)
                accountSettingsIcon.image = image
                sideMenuAccountButton.setImage(image, for: .normal)
                
            }
            
        }
    
        accountSettingsIcon.clipsToBounds = true
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
       

    distanceRadiusSegmentedControl.selectedSegmentIndex = 1 //Set the default segment to (20 miles)
        locationEntryField.attributedPlaceholder = NSAttributedString(string: "Enter Location",
                                                                      attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func setUpSubtractCategoryButton(){
        
        //Set up category selection dropdown menu
        subtractCategoryDropDown.anchorView = subtractCategoryButton
        subtractCategoryDropDown.dataSource = userSelectedEventCategories.strings()
        subtractCategoryDropDown.cellConfiguration = { (index, item) in return "\(item)" }
        
    }
    
    func setUpSortButton(){
        
        configureFloatingSideButtonDesign(view: sortButton)
        sortDropDown.anchorView = sortButton
        sortDropDown.dataSource = ["Popularity", "Date (Asc)", "Date (Desc)"]
        sortDropDown.cellConfiguration = { (index, item) in return "\(item)" }
    }
    
    func sortButtonTapped(){
        
        sortDropDown.selectionAction = { (index: Int, item: String) in
            sortBy(sortMethod: item)
        }
        sortDropDown.backgroundColor = themeMedium
        sortDropDown.textColor = themeAccentPrimary
        if let dropDownFont = UIFont(name: "Raleway-Regular",
                                     size: 14.0) {
            sortDropDown.textFont = dropDownFont
        }
        sortDropDown.width = 140
        sortDropDown.bottomOffset = CGPoint(x: 0, y:(sortDropDown.anchorView?.plainView.bounds.height)!)
        sortDropDown.show()
        
        func sortBy(sortMethod: String){
            let sortBySelected : sortBy = sortByPreference
            if sortMethod == "Date (Desc)" {
                sortByPreference = .datedesc
            } else if sortMethod == "Date (Asc)" {
                sortByPreference = .dateasc
            } else {
                sortByPreference = .popularity
            }
            if sortBySelected != sortByPreference {
                //If user's sort preference changed, re-sort the events
                switch sortByPreference {
                case .popularity: tableEvents.sort(by: >)
                case .datedesc: tableEvents.sort(by: >)
                case .dateasc: tableEvents.sort(by: <)
                }
                reloadEventTableView()
            }
        }
        
    }
    
    func showTableViewSettingsContainer(){
        //Show the table view settings container if the table view is not empty
        
        tableViewSettingsContainer.isHidden = false
        sortButton.isHidden = false
    }
    
    func hideTableViewSettingsContainer(){
        tableViewSettingsContainer.isHidden = true
        sortButton.isHidden = true
    }
    
    func setUpCategoryStackView(){
        
        //Add action to all categories button (permanent button)
         allCategoriesButton.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
        
        //Add all user selected categories to the stackview of category buttons that can be selected
        for eventCategory in userSelectedEventCategories.set {
          addButtonToStackView(for: eventCategory)
        }
        
        //For all unselected categories, add a plus button to the category stackview so the user knows that categories can be added
        for _ in userUnselectedEventCategories.set {
            addPlusButtonToStackView()
        }
        
    }
    
    func hideSideMenu(){
        //Animated side menu
        //All icons move horizontally out of the menu in curved fashion
        //The outer icons move more quickly than the inner icons
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.backgroundView.transform = .identity
            if let blurView = self.blurEffectView {
                blurView.alpha = 0
            }
        })
        
        UIView.animate(withDuration: 0.4, animations: {
            self.sideMenuShade.alpha = 0
            
        })
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.sideMenuAccountButton.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
            self.sideMenuLogOutIcon.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
            self.sideMenuLogOutIconLabel.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
        })
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.sideMenuMyEventsButton.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
            self.sideMenuMyEventsButtonLabel.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
            self.sideMenuSettingsButton.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
            self.sideMenuSettingsButtonLabel.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
        })
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.sideMenuFavoritedButton.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
            self.sideMenuFavoritedButtonLabel.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
        })
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
            self.sideMenu.transform = CGAffineTransform(translationX: -self.sideMenu.frame.width, y: 0)
        }) { success in
            self.sideMenu.isHidden = true
        }
    }
    
    func showSideMenu(){
        //Animated side menu
        //All icons move horizontally into the menu in curved fashion
        //The outer icons move more slowly than the inner icons
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.backgroundView.transform = CGAffineTransform(translationX: self.sideMenu.frame.width, y: 0)
            if let blurView = self.blurEffectView {
                blurView.alpha = 0.7
            }
        })
        
        
        UIView.animate(withDuration: 0.4, animations: {
            self.sideMenuShade.alpha = 0.1
            
        })
        
        
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.sideMenuFavoritedButton.transform = .identity
            self.sideMenuFavoritedButtonLabel.transform = .identity
            self.sideMenu.isHidden = false
            self.sideMenu.transform = .identity
        })

        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.sideMenuMyEventsButton.transform = .identity
            self.sideMenuMyEventsButtonLabel.transform = .identity
            self.sideMenuSettingsButton.transform = .identity
            self.sideMenuSettingsButtonLabel.transform = .identity
        })

        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.sideMenuAccountButton.transform = .identity

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
        
        let button = RoundedButton()
        button.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        button.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
        button.cornerRadius = 30
        button.borderWidth = 2
        button.borderColor = themeAccentPrimary
        button.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .right
        button.tintColor = themeAccentPrimary
        button.alpha = 0.25
        button.setImage(eventCategory.image(), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        button.tag = eventCategory.index()
        
        button.addTarget(self, action: #selector(selectCategory), for: .touchUpInside)
        
        categoriesStackView.addArrangedSubview(button)
        categoryViewsInStackView[eventCategory.index()] = button //Map of category indices and views that is used when removing views from stackview
        
    }
    
    //Adds a basic "plus icon" button to stackview
    //This button populates the stackview to show the user that categories can be added
    //When this button is tapped, user can add new categories to stackview
    func addPlusButtonToStackView(){
        
        let button = RoundedButton()
        button.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        button.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
        button.cornerRadius = 30
        button.borderWidth = 2
        button.borderColor = themeAccentPrimary
        button.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .right
        button.tintColor = themeAccentPrimary
        button.alpha = 0.25
        button.setImage(UIImage(named: "plusIcon"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        button.tag = 1000
        
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        
        plusButtonStackView.addArrangedSubview(button)
        
        //Add buttons to map which keeps track of views for addition/removal purposes
        if plusButtonsInStackView.isEmpty {
            plusButtonsInStackView[0] = button
        } else {
            plusButtonsInStackView[plusButtonsInStackView.count] = button
        }
        
    }
    
    func removePlusButtonFromCategoriesStackView(){
        
        if !plusButtonsInStackView.isEmpty {
            
            guard let plusButton = plusButtonsInStackView[plusButtonsInStackView.count-1] else {
                return
            }
            
            plusButton.removeFromSuperview()
            plusButtonsInStackView.removeValue(forKey: plusButtonsInStackView.count - 1)
            
        }
    
    }
    
    @objc func addCategoryToToolbar(_ sender: UITapGestureRecognizer) {
        
    }
    
    func removeCategoryFromToolbar() {
        //When the 'Remove Category' image is tapped, show dropDown menu for user to select category to remove from toolbar
        
        subtractCategoryDropDown.selectionAction = { (index: Int, item: String) in
            removeImageFromCategoriesStackView(for: item)
        }
        subtractCategoryDropDown.backgroundColor = themeMedium
        subtractCategoryDropDown.textColor = themeTextColor
        if let dropDownFont = UIFont(name: "Raleway-Regular",
                                     size: 14.0) {
            subtractCategoryDropDown.textFont = dropDownFont
        }
        subtractCategoryDropDown.width = 140
        subtractCategoryDropDown.bottomOffset = CGPoint(x: 0, y:subtractCategoryButton.plainView.bounds.height)
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
                addPlusButtonToStackView()
                
                
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
            subview.tintColor = themeAccentPrimary
            subview.alpha = 0.25
        }
        UIView.animate(withDuration: 0.5){
            sender.tintColor = themeAccentPrimary
            sender.alpha = 1
        }
        
        print("TEST ALL CATEGORIES" + String(sender.tag))
        //If the category changed, update the category and refilter the tableView
        if sender.tag != selectedCategory {
                   selectedCategory = sender.tag //The tag of the sending button matches the index of whichever category was selected
            refilterTableViewByCategory()
        }
        
    }
    
    @objc func plusButtonTapped(sender: UIButton!) {
       
        //When the 'Plus Button / Add Category' image is tapped, show dropDown menu for user to select categories
        // to add to categories stackview
        // Add the user selected category to the StackView
        addCategoryDropDown.dataSource = userUnselectedEventCategories.strings()
        addCategoryDropDown.cellConfiguration = { (index, item) in return "\(item)" }
        addCategoryDropDown.selectionAction = { (index: Int, item: String) in
            addImageToCategoriesStackView(for: item)
        }
        addCategoryDropDown.backgroundColor = themeMedium
        addCategoryDropDown.textColor = themeAccentPrimary
        addCategoryDropDown.anchorView = sender
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
                self.removePlusButtonFromCategoriesStackView()
                
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
    
    func getCurrentLocationAndLoadTableView(){
        if currentLocation == nil {
            //Get user's current location
            DispatchQueue.global(qos: .userInteractive).async {
                if CLLocationManager.locationServicesEnabled() {
                    self.locationManager.delegate = self
                    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    self.locationManager.startUpdatingLocation()
                }
            }
        } else {
            currentLocationRetrieved()
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
        print("Location Retrieved!")
        locationEntryField.text = "Current Location"
        locationEntryField.endEditing(true)
        self.locationManager.stopUpdatingLocation()
        
        //If app is starting up for the first time, load the list of events to display
        if !initialListLoaded {
            print("QUERYING INITIAL SEARCH")
            initialListLoaded = true
            searchForEvents()
        }
    }
    
    // Method to run when upvote imageview is tapped
    @objc func upvoteTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        guard let upvoteImage = tapGestureRecognizer.view as? UIImageView else {return}
        //If an upvote arrow was clicked, upvote the event
        tableEvents[upvoteImage.tag].upvote()
        eventTableView.reloadData()
    }
    
    func loadFavoriteEvents(){
        if Auth.auth().currentUser == nil {
            displayAlertWithOKButton(text: "Must Be Logged In To Access Your Favorite Events")
        } else {
            hideSideMenu()
            showListDescriptor(type: .favorited)
            queryFirebaseFavoriteEvents()
        }
    
    }
    
    func loadMyEvents(){
        if Auth.auth().currentUser == nil {
            displayAlertWithOKButton(text: "Must Be Logged In To Access Your Events")
        } else {
            hideSideMenu()
            showListDescriptor(type: .created)
            queryFirebaseCreatedEvents()
        }
    }
    
    //Show the list descriptor which describes the type of events being shown
    func showListDescriptor(type: listDescriptorType){
        switch type {
        case .favorited: listDescriptorLabel.text = "Favorited"
        listDescriptorIcon.image = UIImage(named: "catIconFavorite")
        listDescriptorIcon.tintColor = themeAccentYellow
        case .created: listDescriptorLabel.text = "My Events"
         listDescriptorIcon.image = UIImage(named: "iconMyEvents")
            listDescriptorIcon.tintColor = themeDarkGray
        }
        listDescriptorCover.isHidden = false
        dateAndSearchButtonStackView.isHidden = true
        categorySelectionStackViewContainer.isHidden = true
        mainButtonsStackViewContainer.isHidden = true
        hideCalendarView()
        //Move the event tableview up to account for extra space created when search and date settings are hidden
        self.calendarAndTableViewContainer.transform = CGAffineTransform(translationX: 0, y: -50)
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.listDescriptor.transform = .identity
            self.listDescriptorReturnButton.transform = .identity
        })
    }
    
     //Hide the list descriptor which describes the type of events being shown
    func hideListDescriptor(){
        tableEvents.removeAll()
        refilterTableViewByCategory() //If tableView has events already loaded, add them back to the tableView
        reloadEventTableView()
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.listDescriptor.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width - self.listDescriptor.frame.width, y: 0)
            self.listDescriptorReturnButton.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width - self.listDescriptor.frame.width, y: 0)
        })
           self.calendarAndTableViewContainer.transform = .identity
            listDescriptorCover.isHidden = true
        dateAndSearchButtonStackView.isHidden = false
        categorySelectionStackViewContainer.isHidden = false
        mainButtonsStackViewContainer.isHidden = false
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
    
    func configurePrimaryTableViewCellDesign(view: UIView) {
        let shadowSize : CGFloat = 0.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: view.frame.size.width + shadowSize,
                                                   height: view.frame.size.height + shadowSize))
        view.layer.shadowColor = themeAccentPrimary.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowOpacity = 0.15
        view.layer.shadowRadius = 10.0
        view.layer.masksToBounds = false
        view.layer.shadowPath = shadowPath.cgPath
        
        
    }
    
    
    func configureStandardViewDesignWithShadow(view: UIView, shadowSize: CGFloat, widthAdj: CGFloat, heightAdj: CGFloat, xOffset: CGFloat, yOffset: CGFloat) {
        
            let shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                       y: 0,
                                                       width: view.frame.size.width + widthAdj + shadowSize,
                                                       height: view.frame.size.height + heightAdj + shadowSize))
            view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
            view.layer.shadowOffset = CGSize(width: xOffset, height: yOffset)
            view.layer.shadowOpacity = 0.7
            view.layer.shadowRadius = 5.0
            view.layer.masksToBounds = false
            view.layer.shadowPath = shadowPath.cgPath

        
    }
    
    func configureHeaderButtons(){
        configureFloatingSideButtonDesign(view: headerButtonAccountContainer)
        configureFloatingSideButtonDesign(view: headerButtonCreateEventContainer)
    }
    
    func showSearchSelectionContainer(){
        self.searchSelectionContainer.isHidden = false
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.searchSelectionContainer.transform = .identity
        })
    }
    
    func hideSearchCollectionContainer(){
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.searchSelectionContainer.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
            if let locationText = self.locationEntryField.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                if locationText.isEmpty || locationText == "" {
                    self.mainLocationButton.setTitle("Current Location", for: .normal)
                } else {
                    self.mainLocationButton.setTitle(locationText, for: .normal)
                }
            }
        }){ success in
            self.searchSelectionContainer.isHidden = true
        }
    }
    
    func configureSideMenu(){
        configureSideMenuContainers()
        configureBackgroundViewBlur()
        if Auth.auth().currentUser == nil {
            sideMenuLogOutIconLabel.setTitle("Log In", for: .normal)
        } else {
            sideMenuLogOutIconLabel.setTitle("Log Out", for: .normal)
        }
        
    }
    
    func configureSideMenuContainers(){
        sideMenuMyEventsContainer.addBottomBorderWithColor(color: UIColor.black, width: 0.5)
        sideMenuFavoritedContainer.addBottomBorderWithColor(color: UIColor.black, width: 0.5)
        sideMenuLogOutContainer.addTopBorderWithColor(color: UIColor.black, width: 0.5)
    }
    
    func configureBackgroundViewBlur(){
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        guard blurEffectView != nil else {
            return
        }
        blurEffectView!.frame = view.bounds
        blurEffectView!.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.addSubview(blurEffectView!)
        
    }
    
    func configureListDiscriptor(){
        hideListDescriptor()
        configureFloatingSideButtonDesign(view: listDescriptorReturnButton)
        configureFloatingSideButtonDesign(view: listDescriptor)
    }
    
    func displayAlertWithOKButton(text: String){
        let alert = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        }))
        self.present(alert, animated: true)
    }
    
    func settingsButtonTapped(){
         performSegue(withIdentifier: "settingsSegue", sender: self)
    }
    
    func searchForEvents(){
        hideCalendarView()
        hideSearchCollectionContainer()
        let searchDistanceKm = searchDistanceMiles * 1.60934
        
        guard let addressText = locationEntryField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        if addressText == "Current Location" || addressText.isEmpty || addressText == "" {
            guard let location = currentLocation else {
                return
            }
            queryFirebaseEventsInRadius(centerLocation: location, radius: searchDistanceKm)
        } else {
            getCoordinates(forAddress: addressText) {
                (location) in
                guard let location = location else {
                    //Handle geolocation error
                    return
                }
                let addressLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                queryFirebaseEventsInRadius(centerLocation: addressLocation, radius: searchDistanceKm)
            }
        }
    }
    
    func refilterTableViewByCategory(){
        //This method will re-filter the tableview if the selected category was changed by the user
        //It goes through the "AllEvents" list, and adds selected categories to the tableEvents list
        if allEvents.count <= 0 {
            return
        }
        tableEvents.removeAll()
        for event in allEvents {
            if selectedCategory == event.category.index() || selectedCategory == categoryAll {
                addEventToEventsListInOrder(event: event, eventList: &tableEvents)
            }
        }
        reloadEventTableView()
        
    }
    
    
    
}
