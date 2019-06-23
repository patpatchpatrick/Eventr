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
        
        let userSurpassedMaxDailyAccountCreationNumber = checkIfUserDefaultsDailySignUpMaximumReached()
        
        if userSurpassedMaxDailyAccountCreationNumber {
            displayAlertWithOKButton(text: "You May Only Create One Account Per Day. This is to Prevent Bots from Signing Up.")
            return
        }
        
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
                     self.incrementUserDefaultsDailySignUpCount()
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
    
    //Increment user daily allotted accounts user can create
    func incrementUserDefaultsDailySignUpCount(){
        
        let prefs = UserDefaults.standard
        if let date = prefs.object(forKey: dailyMaximumSignUpDateKey) as? Date {
            if  Double(date.timeIntervalSinceNow) < -ONE_DAY {
                prefs.set(Date(), forKey: dailyMaximumSignUpDateKey)
                prefs.set(1, forKey: dailyMaximumSignUpNumberKey)
            } else {
                var dailySignUpCount = prefs.object(forKey: dailyMaximumSignUpNumberKey) as? Int
                if dailySignUpCount != nil {
                    dailySignUpCount! += 1
                    prefs.set(dailySignUpCount, forKey: dailyMaximumSignUpNumberKey)
                }
            }
            
        } else {
            prefs.set(Date(), forKey: dailyMaximumSignUpDateKey)
            prefs.set(1, forKey: dailyMaximumSignUpNumberKey)
        }
        
    }
    
    //Check if user surpassed daily allotted max # of sign ups
    func checkIfUserDefaultsDailySignUpMaximumReached() -> Bool {
        let prefs = UserDefaults.standard
        guard let date = prefs.object(forKey: dailyMaximumSignUpDateKey) as? Date else {
            return false
        }
        
        if Double(date.timeIntervalSinceNow) > -ONE_DAY {
            let dailyCount = prefs.object(forKey: dailyMaximumSignUpNumberKey) as? Int
            if dailyCount != nil && dailyCount! >= 1 {
                return true
            }
        }
        return false
    }
    
    func displayAlertWithOKButton(text: String){
        let emptyFieldsAlert = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        emptyFieldsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        }))
        self.present(emptyFieldsAlert, animated: true)
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
