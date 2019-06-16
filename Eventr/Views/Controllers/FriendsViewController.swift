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
    
    @IBOutlet weak var friendsSearchField: UITextField!
    @IBOutlet weak var friendsSearchButton: RoundedButton!
    
    @IBOutlet weak var returnButtonContainer: RoundUIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableFriends.removeAll()
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
        
        cell.addFriendButton?.tag = indexPath.row
        
        //Configure design for the primary view
        configurePrimaryTableViewCellDesign(view: cell.primaryView)
        
        return cell
        
    }
    
    @IBAction func friendsSearchButtonTapped(_ sender: Any) {
        
        //Search for a friend by username
        //If found, add the friend to the tableview so the user can add them if they wish
        
        guard let usernameToSearch = friendsSearchField.text else {return}
        
        queryFriends(username: usernameToSearch, callback: {
            usernameFound, userResult in
            
            if usernameFound {
                
                let friend = Friend(name: userResult, userID: userResult)
                tableFriends.append(friend)
                self.friendsTableView.restore()
                self.friendsTableView.reloadData()
            } else {
                self.friendsTableView.setEmptyMessage("Friend Not Found")
                tableFriends.removeAll()
                self.friendsTableView.reloadData()
            }
        })
        
        
    }
    
    
    @IBAction func addFriendButtonTapped(_ sender: UIButton) {
        
        if sender.tag <= tableFriends.count {
             addFriendToFirebaseFollowers(friend: tableFriends[sender.tag])
        }
        
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
