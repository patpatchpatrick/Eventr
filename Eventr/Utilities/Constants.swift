//
//  Constants.swift
//  Eventr
//
//  Created by Patrick Doyle on 5/14/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import UIKit

//Time intervals used for date calculations
let ONE_DAY: Double = 86400
let ONE_WEEK : Double = 604800

//Default Colors
let themeMedium: UIColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.00)
let themeDark: UIColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.00)
let themeAccentSecondary: UIColor = UIColor(red: 236/255.0, green: 77/255.0, blue: 105/255.0, alpha: 1.00)
let themeAccentPrimary: UIColor = UIColor(red: 13/255.0, green: 137/255.0, blue: 190/255.0, alpha: 1.00)
let themeAccentYellow: UIColor = UIColor(red: 233/255.0, green: 194/255.0, blue: 36/255.0, alpha: 1.00)
let themeAccentGreen: UIColor = UIColor(red: 16/255.0, green: 209/255.0, blue: 120/255.0, alpha: 1.00)
let themeAccentLightBlue: UIColor = UIColor(red: 0/255.0, green: 204/255.0, blue: 255/255.0, alpha: 1.00)
let themeAccentRed: UIColor = UIColor(red: 255/255.0, green: 42/255.0, blue: 42/255.0, alpha: 1.00)
let themeDarkGray: UIColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.70)
let themeTextColor: UIColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)

//Variable to keep track of categories.  Used for filtering the tableview based on whatever category was selected
let categoryAll = 0

//CITIES
let selectedCityPrefKey = "selcity"
let NYC = "NYC"
let SF = "SF"
let LA = "LA"
let NEW_YORK_CITY = "New York City"
let SAN_FRANCISCO = "San Francisco"
let LOS_ANGELES = "Los Angeles"
let citySelectButtonArray : [String] = [NEW_YORK_CITY, SAN_FRANCISCO, LOS_ANGELES]
var selectedCity : String = NYC
func getFullCityName(city: String) -> String {
    
    switch city{
    case NYC: return NEW_YORK_CITY
    case SF: return SAN_FRANCISCO
    case LA: return LOS_ANGELES
    default: return NEW_YORK_CITY
    }
    
}

func getCityAbbreviation(fullCityName: String) -> String {
    switch fullCityName{
    case NEW_YORK_CITY: return NYC
    case SAN_FRANCISCO: return SF
    case LOS_ANGELES: return LA
    default: return NYC
    }
}
