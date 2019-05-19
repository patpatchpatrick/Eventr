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
    
    
    @IBOutlet weak var mainLogoImage: RoundedImage!
    
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
        let shadowSize : CGFloat = 0.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: mainLogoImage.frame.size.width + shadowSize,
                                                   height: mainLogoImage.frame.size.height + shadowSize))
        mainLogoImage.layer.shadowColor = themeAccentPrimary.cgColor
        mainLogoImage.layer.shadowOffset = CGSize(width: 0, height: 0)
        mainLogoImage.layer.shadowOpacity = 0.15
        mainLogoImage.layer.shadowRadius = 10.0
        mainLogoImage.layer.masksToBounds = false
        mainLogoImage.layer.shadowPath = shadowPath.cgPath
        
    }
    
}
