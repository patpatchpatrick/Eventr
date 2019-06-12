//
//  FriendsViewController.swift
//  Eventr
//
//  Created by Patrick Doyle on 6/11/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import UIKit

var tableFriends: [Friend] = []

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var friendsSearchButton: RoundedButton!
    
    @IBOutlet weak var returnButtonContainer: RoundUIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFloatingSideButtonDesign(view: returnButtonContainer)
         friendsTableView.setEmptyMessage("You do not appear to have any friends currently. Add some!")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = friendsTableView.dequeueReusableCell(withIdentifier: "cellFriend", for: indexPath) as! CustomFriendCell
        
        let friend = tableFriends[indexPath.row]
        
        cell.friendNameLabel.text = friend.name
        
        return cell
        
    }
    
    @IBAction func friendsSearchButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func returnButtonTapped(_ sender: Any) {
        
        self.performSegueToReturnBack()
        
    }
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    

}
