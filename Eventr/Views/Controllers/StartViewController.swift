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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        GIDSignIn.sharedInstance()?.uiDelegate = self
        
        configureMainLogo()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    //If user is already logged in then go straight to the home activity
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "homeSegue", sender: nil)
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
        mainLogoImage.layer.cornerRadius = 40
        configureStandardViewDesignWithShadow(view: mainLogoImage, xOffset: 0, yOffset: 0, opacity: 1)
        
    }
    
}
