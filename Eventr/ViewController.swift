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
        categoryDropDown.dataSource = userUnselectedEventCategoriesString()
        categoryDropDown.cellConfiguration = { (index, item) in return "\(item)" }
        
        addCategoryImage.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(categoryImageTapped))
        tapGestureRecognizer.numberOfTapsRequired = 1
        addCategoryImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func categoryImageTapped(_ sender: UITapGestureRecognizer) {
        //When the 'Add Category' image is tapped, add selected category to the StackView
        //Image View
        
        categoryDropDown.selectionAction = { (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)") }
        categoryDropDown.width = 140
        categoryDropDown.bottomOffset = CGPoint(x: 0, y:(categoryDropDown.anchorView?.plainView.bounds.height)!)
        categoryDropDown.show()
        
        /*
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.blue
        imageView.heightAnchor.constraint(equalToConstant: 60.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 60.0).isActive = true
        imageView.image = UIImage(named: "plusIcon")
        categoriesStackView.addArrangedSubview(imageView)
 */
        
    }

    @IBOutlet weak var addCategoryImage: UIImageView!
    
    @IBOutlet weak var categoriesStackView: UIStackView!
    
    func setUpCategoryStackView(){
        
        //Add all user selected categories to the stackview of category images that can be selected
        for eventCategory in userEventCategories {
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
        let cell = eventTableView.dequeueReusableCell(withIdentifier: "cellEvent", for: indexPath)
        
        let event = events[indexPath.row]
        cell.textLabel?.text = event.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEvent = events[indexPath.row]
        performSegue(withIdentifier: "eventSegue", sender: self)
    }
    
    
}

