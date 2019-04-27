//
//  UserPreferences.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/26/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import UIKit

//Event Categories
// The Event Category struct is used to represent categories of events
// It uses the eventCategory enum as a set list of events

enum eventCategory {
    case all
    case sports
    case music
    case business
    case art
    case friends
    case food
}

func stringToEventCategory(string: String) -> EventCategory {
    switch string{
    case "All": return EventCategory(category: .all)
    case "Sports" : return EventCategory(category: .sports)
    case "Music" : return EventCategory(category: .music)
    case "Business" : return EventCategory(category: .business)
    case "Art" : return EventCategory(category: .art)
    case "Friends" : return EventCategory(category: .friends)
    case "Food" : return EventCategory(category: .food)
    default: return EventCategory(category: .all)
    }
}

public struct EventCategory : Hashable {
    
    var category : eventCategory
    
    init(category: eventCategory) {
        self.category = category
    }
    
    func text() -> String {
        switch category{
        case .all: return "All"
        case .sports: return "Sports"
        case .music: return "Music"
        case .business: return "Business"
        case .art: return "Art"
        case .friends: return "Friends"
        case .food: return "Food"
        }
    }
    
    func image() -> UIImage? {
        switch category {
        case .all:
            return UIImage(named: "catIconAll")
        case .business:
            return UIImage(named: "catIconBusiness")
        case .music:
            return UIImage(named: "catIconMusic")
        case .sports:
            return UIImage(named: "catIconSports")
        case .art:
            return UIImage(named: "catIconArt")
        case .friends:
            return UIImage(named: "catIconFriends")
        case .food:
            return UIImage(named: "catIconFood")
        }
    }
    
}

class EventCategorySet {
    
    var set : Set<EventCategory> = []
    
    init(set: Set<EventCategory>) {
        self.set = set
    }
    
    func add(eventCategory: EventCategory){
        set.update(with: eventCategory)
    }
    
    func remove(eventCategory: EventCategory){
        set.remove(eventCategory)
    }
    
    func strings() -> [String]{
        var catList : [String] = []
        for category in set{
            catList.append(category.text())
        }
        return catList
    }
    
    func containsCategory(eventCategory: EventCategory) -> Bool {
        return set.contains(eventCategory)
    }
    
}

//Lists representing which categories that user has selected to display (and which categories are still unselected)
var userSelectedEventCategories: EventCategorySet = EventCategorySet(set: [])
var userUnselectedEventCategories: EventCategorySet = EventCategorySet(set: [])
