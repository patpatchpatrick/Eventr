//
//  Notifications.swift
//  Eventr
//
//  Created by Patrick Doyle on 5/14/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

//Class to track notifications
import Foundation

func reloadEventTableView(){
       NotificationCenter.default.post(name: Notification.Name("UPDATED_EVENT_DATA"), object: nil)
}

func reloadEventViewController(){
    NotificationCenter.default.post(name: Notification.Name("RELOAD_EVENT_VC"), object: nil)
}
