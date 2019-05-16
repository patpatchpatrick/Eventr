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
    case social
    case food
    case outdoors
    case misc
}

func stringToEventCategory(string: String) -> EventCategory {
    switch string{
    case "All": return EventCategory(category: .all)
    case "Sports" : return EventCategory(category: .sports)
    case "Outdoors" : return EventCategory(category: .outdoors)
    case "Music" : return EventCategory(category: .music)
    case "Business" : return EventCategory(category: .business)
    case "Art" : return EventCategory(category: .art)
    case "Social" : return EventCategory(category: .social)
    case "Food" : return EventCategory(category: .food)
    case "Misc" : return EventCategory(category: .misc)
    default: return EventCategory(category: .misc)
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
        case .outdoors: return "Outdoors"
        case .music: return "Music"
        case .business: return "Business"
        case .art: return "Art"
        case .social: return "Social"
        case .food: return "Food"
        case .misc: return "Misc"
        }
    }
    
    func image() -> UIImage? {
        switch category {
        case .all:
            return UIImage(named: "catIconFavorite")
        case .business:
            return UIImage(named: "catIconBusiness")
        case .music:
            return UIImage(named: "catIconMusic")
        case .sports:
            return UIImage(named: "catIconSports")
        case .outdoors:
            return UIImage(named: "catIconOutdoors")
        case .art:
            return UIImage(named: "catIconArt")
        case .social:
            return UIImage(named: "catIconFriends")
        case .food:
            return UIImage(named: "catIconFood")
        case .misc:
            return UIImage(named: "catIconMisc")
        }
    }
    
    func index() -> Int {
        switch category {
        case .all:
            return 0
        case .social:
            return 1
        case .music:
            return 2
        case .sports:
            return 3
        case .outdoors:
            return 4
        case .business:
            return 5
        case .food:
            return 6
        case .art:
            return 7
        case .misc:
            return 8
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
var allEventCategories: EventCategorySet = EventCategorySet(set: [])
var categoryViewsInStackView: [Int : UIView] = [:] //Map the category toolbar views to the index int of the category that represents them