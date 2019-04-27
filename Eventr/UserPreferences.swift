//
//  UserPreferences.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/26/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import UIKit

enum eventCategory {
    case all
    case sports
    case music
    case business
    case art
    case friends
    case food
}

public struct EventCategory {
    
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

var userEventCategories: [EventCategory] = [EventCategory(category: .all), EventCategory(category: .sports), EventCategory(category: .music), EventCategory(category: .business)]
var userUnselectedEventCategories: [EventCategory] = [EventCategory(category: .art), EventCategory(category: .friends), EventCategory(category: .food)]

func userUnselectedEventCategoriesString() -> [String] {
    var catList : [String] = []
    for category in userUnselectedEventCategories {
        catList.append(category.text())
    }
    return catList
}
