//
//  StartViewController.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/28/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class StartViewController: UIViewController, GIDSignInUIDelegate {
    
    
    @IBOutlet weak var mainLogoImage: UIImageView!
    @IBOutlet weak var popUpMessageView: RoundUIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        GIDSignIn.sharedInstance()?.uiDelegate = self
        
        configureMainLogo()
        
        checkIfInitialPopUpMessageShouldAppear()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    //If user is already logged in then go straight to the home activity
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "homeSegue", sender: nil)
        }
    }
    
    func checkIfInitialPopUpMessageShouldAppear(){
        
        let preferences = UserDefaults.standard
        
        let initialPopUpKey = "initpop1"
        
        if preferences.object(forKey: initialPopUpKey) == nil {
              configureStandardViewDesignWithShadow(view: popUpMessageView, xOffset: 0, yOffset: 0, opacity: 1.0)
            popUpMessageView.layer.borderColor = themeTextColor.cgColor
            popUpMessageView.layer.borderWidth = 1.0
            popUpMessageView.isHidden = false
        } else {
            let userDismissedPopUp = preferences.bool(forKey: initialPopUpKey)
            if userDismissedPopUp {
                popUpMessageView.isHidden = true
            }
        }
        
        
    }
    
    
    @IBAction func continueAsGuest(_ sender: UIButton) {
        
        performSegue(withIdentifier: "homeSegue", sender: self)
        
    }
    
    
    @IBAction func logIn(_ sender: UIButton) {
        
        performSegue(withIdentifier: "loginSegue", sender: self)
    }
    
    
    @IBAction func signUp(_ sender: UIButton) {
        
        performSegue(withIdentifier: "signupSegue", sender: self)
    }
    
    func configureMainLogo(){
        
    }
    
    
    @IBAction func dismissMessage(_ sender: UIButton) {
        popUpMessageView.isHidden = true
        
        //Set the user preference so the pop up doesn't show again in the future
        let preferences = UserDefaults.standard
        let initialPopUpKey = "initpop1"
        preferences.set(true, forKey: initialPopUpKey)
        preferences.synchronize()
        
    }
    
}
