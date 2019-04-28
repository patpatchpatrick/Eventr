//
//  StartViewController.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/28/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
}
