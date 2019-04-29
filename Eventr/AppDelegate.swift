//
//  AppDelegate.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/25/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        events = loadTestEvents()
        userSelectedEventCategories.add(eventCategory: EventCategory(category: .all))
        userSelectedEventCategories.add(eventCategory: EventCategory(category: .business))
        userSelectedEventCategories.add(eventCategory: EventCategory(category: .sports))
        userUnselectedEventCategories.add(eventCategory: EventCategory(category: .food))
        userUnselectedEventCategories.add(eventCategory: EventCategory(category: .art))
        userUnselectedEventCategories.add(eventCategory: EventCategory(category: .friends))
        userUnselectedEventCategories.add(eventCategory: EventCategory(category: .music))
        
        return true
    }
    
    func loadTestEvents() -> [Event] {
        var events : [Event] = []
        events.append( Event(name: "Alder", address: "220 10th Ave.  Seattle, WA.  98122", details: "Teresa decided to leave Iran. She lived in a convent in Rome for the rest of her life, devoting her time to charity and religion. As a pious Christian, and because of her love for her husband, Teresa had Shirley's remains transported to Rome from Isfahan and reburied; on the headstone of their mutual grave she mentions their travels and refers to her noble Circassian origins.", contact: "James Jones\n925-111-2222\n123 Fake Street") )
        events.append( Event(name: "AZ Home", address: "6231 E Vista Dr", details: "Teresa decided to leave Iran. She lived in a convent in Rome for the rest of her life, devoting her time to charity and religion. As a pious Christian, and because of her love for her husband, Teresa had Shirley's remains transported to Rome from Isfahan and reburied; on the headstone of their mutual grave she mentions their travels and refers to her noble Circassian origins.", contact: "James Jones\n925-111-2222\n123 Fake Street") )
        events.append( Event(name: "Ardmore Park", address: "Ardmore Park, Singapore", details: "Teresa decided to leave Iran. She lived in a convent in Rome for the rest of her life, devoting her time to charity and religion. As a pious Christian, and because of her love for her husband, Teresa had Shirley's remains transported to Rome from Isfahan and reburied; on the headstone of their mutual grave she mentions their travels and refers to her noble Circassian origins.", contact: "James Jones\n925-111-2222\n123 Fake Street") )
        events[0].paid = true
        return events
  
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

