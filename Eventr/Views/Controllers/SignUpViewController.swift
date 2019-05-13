//
//  SignUpViewController.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/28/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
    }
    
    
    @IBOutlet weak var email: UITextField!
    
    
    @IBOutlet weak var password: UITextField!
    
    
    @IBOutlet weak var passwordConfirm: UITextField!
    

    @IBAction func signUp(_ sender: UIButton) {
        
        if password.text != passwordConfirm.text {
            print("PASSWORD INCORRECT")
            let alertController = UIAlertController(title: "Password Incorrect", message: "Please re-type password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            print("PASSWORD WORKS!")
            Auth.auth().createUser(withEmail: email.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: password.text!){ (user, error) in
                if error == nil {
                    self.performSegue(withIdentifier: "signupToHomeSegue", sender: self)
                }
                else{
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        
    }
    
    
    @IBAction func previousScreen(_ sender: UIButton) {
        
        performSegueToReturnBack()
        
    }
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

}
