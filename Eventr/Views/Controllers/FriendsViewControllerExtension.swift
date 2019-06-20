//
//  FriendsViewControllerExtension.swift
//  Eventr
//
//  Created by Patrick Doyle on 6/19/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation

import UIKit

extension FriendsViewController{
    
    func hideListDescriptor(){
        
        self.tableViewListDescriptorButton.isHidden = true
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.tableViewListDescriptorButton.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width - self.tableViewListDescriptorButton.frame.width, y: 0)
        })
    
    }
    
    func showListDescriptor(textToDisplay: String){
        
        self.tableViewListDescriptorButton.isHidden = false
        self.tableViewListDescriptorButton.setTitle(textToDisplay, for: .normal)
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.tableViewListDescriptorButton.transform = .identity
        })
        
    }
    
    func hideSearchContainer(){
        
        self.findFriendsSearchContainer.isHidden = true
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.findFriendsSearchContainer.transform = CGAffineTransform(translationX: -UIScreen.main.bounds.width - self.findFriendsSearchContainer.frame.width, y: 0)
        })
        
    }
    
    func showSearchContainer(){
        
        self.findFriendsSearchContainer.isHidden = false
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction], animations: {
            self.findFriendsSearchContainer.transform = .identity
        })
    }
    
    func configureButtons(){
        configureStandardViewDesignWithShadow(view: tableViewListDescriptorButton, xOffset: 0, yOffset: 0, radius: 7.0, opacity: 0.5)
        configureFloatingSideButtonDesign(view: returnButtonContainer)
    }
    
    func clearAllTables(){
        tableFriends.removeAll()
        tableFriendRequests.removeAll()
        tableFriendEvents.removeAll()
    }
    
}
