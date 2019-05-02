//
//  AppDelegate.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/25/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    

    var window: UIWindow?
    let userDefaults = UserDefaults()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        //Initialize google sign in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        setUpEventCategories()
        
        return true
    }
    
    //Google sign-in method
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("SIGN IN CALLED")
        if let error = error {
            //Sign-in error occurred
            print(error.localizedDescription)
            return
        } else {
            //Authenticate user in google
            googleUser = user
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            //Authenticate the user in Firebase
            Auth.auth().signInAndRetrieveData(with: credential, completion: {(result, error) in
                if error == nil {
                    self.window?.rootViewController?.performSegue(withIdentifier: "homeSegue", sender: nil)
                } else {
                    print(error?.localizedDescription)
                }
            })
            
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: [:])
    }
    
    func setUpEventCategories(){
        
        allEventCategories.add(eventCategory: EventCategory(category: .business))
        allEventCategories.add(eventCategory: EventCategory(category: .sports))
        allEventCategories.add(eventCategory: EventCategory(category: .food))
        allEventCategories.add(eventCategory: EventCategory(category: .art))
        allEventCategories.add(eventCategory: EventCategory(category: .friends))
        allEventCategories.add(eventCategory: EventCategory(category: .music))
        allEventCategories.add(eventCategory: EventCategory(category: .misc))
        
        
        userSelectedEventCategories.add(eventCategory: EventCategory(category: .all))
        userSelectedEventCategories.add(eventCategory: EventCategory(category: .business))
        userSelectedEventCategories.add(eventCategory: EventCategory(category: .sports))
        userSelectedEventCategories.add(eventCategory: EventCategory(category: .misc))
        userUnselectedEventCategories.add(eventCategory: EventCategory(category: .food))
        userUnselectedEventCategories.add(eventCategory: EventCategory(category: .art))
        userUnselectedEventCategories.add(eventCategory: EventCategory(category: .friends))
        userUnselectedEventCategories.add(eventCategory: EventCategory(category: .music))
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

