//
//  ViewController.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/25/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import UIKit
import DropDown

//Variable to represent which event was selected in TableView
var selectedEvent: Event = Event(name: "", address: "", details: "")

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //List of events to display in tableView
    var events: [Event]!
    let categoryDropDown = DropDown()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCategoryStackView()
        setUpAddCategoryImage()
        // Do any additional setup after loading the view.
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
    
    @objc func categoryImageTapped(_ sender: UITapGestureRecognizer) {
        //When the 'Add Category' image is tapped, show dropDown menu for user to select categories
        // to add to categories stackview
        // Add the user selected category to the StackView
        
        categoryDropDown.selectionAction = { (index: Int, item: String) in
            addImageToCategoriesStackView(for: item)
        }
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
                
                let imageView = UIImageView()
                imageView.backgroundColor = UIColor.blue
                imageView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
                imageView.image = eventCat.image()
                categoriesStackView.addArrangedSubview(imageView)
                userSelectedEventCategories.add(eventCategory: eventCat)
                userUnselectedEventCategories.remove(eventCategory: eventCat)
                categoryDropDown.dataSource = userUnselectedEventCategories.strings()
            }
            
        }
  
    }

    @IBOutlet weak var addCategoryImage: UIImageView!
    
    @IBOutlet weak var categoriesStackView: UIStackView!
    
    func setUpCategoryStackView(){
        
        //Add all user selected categories to the stackview of category images that can be selected
        for eventCategory in userSelectedEventCategories.set {
            let imageView = UIImageView()
            imageView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
            imageView.image = eventCategory.image()
            categoriesStackView.addArrangedSubview(imageView)
        }
        
        
    }
    
    @IBOutlet weak var eventTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = eventTableView.dequeueReusableCell(withIdentifier: "cellEvent", for: indexPath) as! CustomEventCell
        
        let event = events[indexPath.row]
        cell.eventName?.text = event.name
        if event.paid {
            cell.paidEvent?.image = UIImage(named: "eventIconDollar")
        } else {
            cell.paidEvent?.image = nil
        }
        
        //Add tap gesture recognizer for upvote arrow
        //When upvote arrow is tapped, run the upvoteTapped method
        //to update event upvotes
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(upvoteTapped(tapGestureRecognizer:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        cell.upvoteArrow?.isUserInteractionEnabled = true
        cell.upvoteArrow?.addGestureRecognizer(tapGestureRecognizer)
        cell.upvoteArrow?.tag = indexPath.row
        return cell
    }
    
    // method to run when upvote imageview is tapped
    @objc func upvoteTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let imgView = tapGestureRecognizer.view as! UIImageView
        print("your taped image view tag is : \(imgView.tag)")
        if (imgView.tag == 0) //Give your image View tag
        {
            //navigate to next view
        }
        else{
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEvent = events[indexPath.row]
        performSegue(withIdentifier: "eventSegue", sender: self)
    }
    
    
}

