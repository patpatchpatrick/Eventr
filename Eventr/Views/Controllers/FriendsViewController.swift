//
//  FriendsViewController.swift
//  Eventr
//
//  Created by Patrick Doyle on 6/11/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import UIKit

var selectedFriend: Friend = Friend(name: "", userID: "")
var tableFriends: [Friend] = []
var tableFriendRequests: [Friend] = []

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Variables to keep track of indices for header segmented control
    let EVENTS_INDEX = 0
    let SEARCH_INDEX = 1
    let REQUESTS_INDEX = 2
    var headerSelectedIndex = 0 //Variable to keep track of which index is selected in the header
    
    @IBOutlet weak var friendsTableView: UITableView!
    
    @IBOutlet weak var friendsSearchField: UITextField!
    @IBOutlet weak var friendsSearchButton: RoundedButton!
    
    @IBOutlet weak var findFriendsSearchContainer: UIView!
    
    @IBOutlet weak var returnButtonContainer: RoundUIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updated_friend_data),
                                               name:Notification.Name("UPDATED_FRIEND_DATA"),
                                               object: nil)
        
        setUpViewsBasedOnSelectedHeaderSegment()
        tableFriends.removeAll()
        tableFriendRequests.removeAll()
        configureFloatingSideButtonDesign(view: returnButtonContainer)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
         NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updated_friend_data(notification:Notification) -> Void{
        
        friendsTableView.restore()
        friendsTableView.reloadData()
 
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch headerSelectedIndex {
        case SEARCH_INDEX:
            return tableFriends.count
        case REQUESTS_INDEX:
            return tableFriendRequests.count
        case EVENTS_INDEX:
            print("EVENTS TABLE")
        default:
            return tableFriends.count

        }
        return tableFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = friendsTableView.dequeueReusableCell(withIdentifier: "cellFriend", for: indexPath) as? CustomFriendCell{
        
        switch headerSelectedIndex{
        case SEARCH_INDEX:
            return populateSearchFriendCell(cell: cell, indexPath: indexPath)
        case REQUESTS_INDEX:
            return populateFriendRequestCell(cell: cell, indexPath: indexPath)
        case EVENTS_INDEX:
            return cell
        default:
            return cell
        }
        
        }
        return UITableViewCell()
    }
    
    func populateSearchFriendCell(cell: CustomFriendCell, indexPath: IndexPath) -> CustomFriendCell{
        
        let friend = tableFriends[indexPath.row]
        
        cell.friendNameLabel.text = friend.name
        
        cell.addFriendButton?.tag = indexPath.row
        
        //Set the appropriate "add friend icon".  This icon can either show the "Add Friend", "Friend Requested" or "Remove Friend" icon, depending on the current status of the friendship
        
        //Check status of the friend request and set up the cell accordingly
        queryIfFriendRequestSent(friend: friend, callback: {
            accountFound, friendRequestStatus in
            if accountFound {
                if friendRequestStatus == FRIEND_REQUEST_NOT_APPROVED {
                     friend.status = .requestSent
                     cell.addFriendButton.setImage(UIImage(named: "requestFriendIcon"), for: .normal)
                    cell.addFriendButtonLabel.text = "Requested"
                } else if friendRequestStatus == FRIEND_REQUEST_APPROVED {
                    friend.status = .connected
                    cell.addFriendButton.setImage(UIImage(named: "iconCheckMark"), for: .normal)
                    cell.addFriendButtonLabel.text = "Following"
                } else {
                    friend.status = .notconnected
                    cell.addFriendButton.setImage(UIImage(named: "addFriendIcon"), for: .normal)
                    cell.addFriendButtonLabel.text = "Follow"
                }
            } else {
                friend.status = .notconnected
                cell.addFriendButton.setImage(UIImage(named: "addFriendIcon"), for: .normal)
                 cell.addFriendButtonLabel.text = "Follow"
            }
        })
        
        
        //Configure design for the primary view
        configurePrimaryTableViewCellDesign(view: cell.primaryView)
        
        return cell
        
    }
    
    func populateFriendRequestCell(cell: CustomFriendCell, indexPath: IndexPath) -> CustomFriendCell{
        
        let friend = tableFriendRequests[indexPath.row]
        
        //Check status of the friend request and set up the cell accordingly
        queryFriendRequestStatusInFirebase(friend: friend, callback: {
            accountFound, friendRequestStatus in
            if accountFound {
                if friendRequestStatus == FRIEND_REQUEST_NOT_APPROVED {
                    friend.status = .requestReceived
                    cell.addFriendButton.setImage(UIImage(named: "iconCheckMark"), for: .normal)
                     cell.addFriendButtonLabel.text = "Approve"
                } else if friendRequestStatus == FRIEND_REQUEST_APPROVED {
                    queryIfFollowingFriendInFirebase(friend: friend, callback: {
                        userIsFollowingFriendStatus in
                        switch userIsFollowingFriendStatus{
                        case FRIEND_REQUEST_APPROVED:
                            friend.status = .connected
                            cell.addFriendButton.setImage(UIImage(named: "iconCheckMark"), for: .normal)
                            cell.addFriendButtonLabel.text = "Following"
                        case FRIEND_REQUEST_NOT_APPROVED:
                            friend.status = .requestSent
                            cell.addFriendButton.setImage(UIImage(named: "requestFriendIcon"), for: .normal)
                            cell.addFriendButtonLabel.text = "Requested"
                        case FRIEND_REQUEST_NOT_SENT:
                            friend.status = .notconnected
                            cell.addFriendButton.setImage(UIImage(named: "addFriendIcon"), for: .normal)
                            cell.addFriendButtonLabel.text = "Follow Back"
                        default:
                            print("DEFAULT")
                        }
                        
                    })
                   
                } else {
                    friend.status = .notconnected
                    cell.addFriendButton.setImage(UIImage(named: "addFriendIcon"), for: .normal)
                     cell.addFriendButtonLabel.text = ""
                }
            } else {
                friend.status = .notconnected
                cell.addFriendButton.setImage(UIImage(named: "addFriendIcon"), for: .normal)
                 cell.addFriendButtonLabel.text = ""
            }
        })
        
        cell.friendNameLabel.text = friend.name
        
        cell.addFriendButton?.tag = indexPath.row
        
        //Configure design for the primary view
        configurePrimaryTableViewCellDesign(view: cell.primaryView)
        
        return cell
        
    }
    
    
    @IBAction func headerSegmentChanged(_ sender: UISegmentedControl) {
        
        headerSelectedIndex = sender.selectedSegmentIndex
        
        setUpViewsBasedOnSelectedHeaderSegment()
        
        populateTableViewWithDataBasedOnHeader()
        
        reloadFriendTableView()
        
        
    }
    
    func populateTableViewWithDataBasedOnHeader(){
        
        switch headerSelectedIndex{
        case SEARCH_INDEX:
            print("POPULATE SEARCH DATA IN TABLE VIEW")
        case REQUESTS_INDEX:
            friendsTableView.setEmptyMessage("You do not have any new friend requests")
            queryFriendRequestsInFirebase()
        case EVENTS_INDEX:
            print("POPULATE EVENTS IN TABLE VIEW")
        default:
            print("Default")
        }
        
    }
    
    func setUpViewsBasedOnSelectedHeaderSegment(){
        
        switch headerSelectedIndex{
        case SEARCH_INDEX:
            findFriendsSearchContainer.isHidden = false
        case REQUESTS_INDEX:
            findFriendsSearchContainer.isHidden = true
        case EVENTS_INDEX:
            findFriendsSearchContainer.isHidden = true
        default:
            print("Default")
        }
        
        
    }
    
    
    @IBAction func friendsSearchButtonTapped(_ sender: Any) {
        
        //Search for a friend by username
        //If found, add the friend to the tableview so the user can add them if they wish
        
        guard let usernameToSearch = friendsSearchField.text else {return}
        
         friendsTableView.setEmptyMessage("You do not appear to have any friends currently. Add some!")
        
        tableFriends.removeAll()
        
        queryFriendsInFirebase(username: usernameToSearch, callback: {
            usernameFound, friendResult in
            
            if usernameFound {
                
                guard let friend = friendResult else {return}
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

        switch headerSelectedIndex{
        case REQUESTS_INDEX:
            handleFriendRequestAddButtonTapped(index: sender.tag)
        case SEARCH_INDEX:
            handleFriendSearchAddButtonTapped(index: sender.tag)
        default:
            print("DEFAULT")
        }
        
    }
    
    func handleFriendSearchAddButtonTapped(index: Int){
        
          //Check if the account you are adding is private, if so, send a friend request.  If not, follow the friend
        
        if index <= tableFriends.count && index >= 0 {
            selectedFriend = tableFriends[index]
            let friendshipStatus = selectedFriend.status
            switch friendshipStatus {
            case .requestReceived: print ("REQUEST RECEIVED")
            case .connected: print ("CONNECTED")
            case .notconnected: sendFriendRequest()
            case .requestSent:
                print("REQUEST SENT")
         
            }
            
        }
        
        
    }
    
    func handleFriendRequestAddButtonTapped(index: Int){
        
        //This method is called when user is viewing list of friend requests
        //If the add friend button is clicked from within this list, the friend request will be approved if the status of the friendship is ".requested"
        
        if index <= tableFriendRequests.count && index >= 0 {
            selectedFriend = tableFriendRequests[index]
            let friendshipStatus = selectedFriend.status
            switch friendshipStatus {
            case .requestReceived:
                approveFriendRequestInFirebase(friend: selectedFriend, callback: {
                    friendRequestApproved in
                    if friendRequestApproved {
                        queryIfFollowingFriendInFirebase(friend: selectedFriend, callback: {
                            followingFriendStatus in
                            switch followingFriendStatus {
                            case FRIEND_REQUEST_NOT_SENT:
                                selectedFriend.status = .notconnected
                                reloadFriendTableView()
                            case FRIEND_REQUEST_APPROVED:
                                selectedFriend.status = .connected
                                reloadFriendTableView()
                            case FRIEND_REQUEST_NOT_APPROVED:
                                selectedFriend.status = .requestSent
                            default:
                                selectedFriend.status = .notconnected
                            }
                        })
                    } else {
                        selectedFriend.status = .requestReceived
                        reloadFriendTableView()
                    }
                })
                
            case .connected: print ("CONNECTED")
            case .notconnected: sendFriendRequest()
            case .requestSent:
                print("REQUEST SENT")
            }
            
        }
        
    }
    
    func sendFriendRequest(){
        
        queryIfAccountIsPrivate(userID: selectedFriend.userID, callback: {
            accountFound, accountIsPrivate in
            
            if accountFound == false {
                return
            }
            
            if accountIsPrivate {
                print("SENDING PRIVATE FRIEND REQUEST")
                sendFriendRequestInFirebase(friend: selectedFriend)
            } else {
                print("ADDING FRIEND TO FOLLOWERS")
                addFriendToFirebaseFollowers(friend: selectedFriend)
            }
        })
        
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
