//
//  UserPreferences.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/26/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation

enum eventCategory {
    case all
    case sports
    case music
    case business
}

var userEventCategories: [eventCategory] = [eventCategory.all, eventCategory.sports, eventCategory.music, eventCategory.business]
