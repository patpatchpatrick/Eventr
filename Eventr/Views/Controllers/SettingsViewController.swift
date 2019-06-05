//
//  SettingsViewController.swift
//  Eventr
//
//  Created by Patrick Doyle on 5/22/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var userAccountImage: RoundedImage!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var settingsButtonContainer: RoundUIView!
    @IBOutlet weak var deleteAccountButton: RoundedButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUserData()
        userNameLabel.addBottomBorderWithColor(color: themeTextColor, width: 1, widthExtension: 0
        )
        userEmailLabel.addBottomBorderWithColor(color: themeTextColor, width: 1, widthExtension: 0)
        configureFloatingSideButtonDesign(view: settingsButtonContainer)
        configureFloatingSideButtonDesign(view: deleteAccountButton)
        if userIsNotLoggedIn() {
            deleteAccountButton.isHidden = true
        } else {
            deleteAccountButton.isHidden = false
        }
    }
    
    
    func loadUserData(){
        //Set the profile photo, name and email of the logged in user if they are logged in
        if let pic = Auth.auth().currentUser?.photoURL {
            let data = try? Data(contentsOf: pic)
            if let imageData = data {
                let image = UIImage(data: imageData)
                userAccountImage.image = image
                
            }
            
        }
        if let userEmail = Auth.auth().currentUser?.email {
            userEmailLabel.isHidden = false
            userEmailLabel.text = userEmail
        } else {
            userEmailLabel.isHidden = true
        }
        if let userName = Auth.auth().currentUser?.displayName {
            userNameLabel.text = userName
        }
    }
    
    
    @IBAction func deleteAccountButtonTapped(_ sender: UIButton) {
        
        let deleteAccountAlert = UIAlertController(title: "Are you sure you want to delete account?  Account deletion is permanent.  All of your created events will be deleted.", message: nil, preferredStyle: .alert)
        deleteAccountAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
        }))
        deleteAccountAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            self.deleteUserFirebaseDataAndAccount()
        }))
        self.present(deleteAccountAlert, animated: true)
        
    }
    
    func deleteUserFirebaseDataAndAccount(){
        //Attempt to delete all user Firebase data, if successful, then delete the user account and log them out
        deleteUserFirebaseData(callback: {
            eventsDeleted in
            if eventsDeleted {
                self.deleteAccount()
            } else {
                self.displayAlertWithOKButton(text: "Error Deleting User Account")
                print("Error Deleting User Events")
            }
        })
        
    }
    
    func deleteAccount(){
        
        //Delete the user account.
        //If deletion fails, attempt to reauth the user and try again
        
        let user = Auth.auth().currentUser
        
        user?.delete { error in
            if let error = error {
                print(error.localizedDescription)
                print("ATTEMPTING REAUTH")
                self.tryReauthenticatingUser()

            } else {
                print("ATTEMPTING LOGOUT")
                self.logOut()
            }
        }
    }
    
    func deleteAccountAfterReauthenticate(){
        
        //Attempt to delete the user after reauthentication has occurred
        
        let user = Auth.auth().currentUser
        
        user?.delete { error in
            if let error = error {
                print(error.localizedDescription)
                print("REAUTHFAILED")
                self.displayAlertWithOKButton(text: "Error Deleting Account")
                
            } else {
                print("ATTEMPTING LOGOUT")
                self.logOut()
            }
        }
        
    }
    
    func tryReauthenticatingUser() {
     
        //Reauthenticate the user, and if successful, attempt to delete their account
        //Query user for their password so reauth can be completed
        
        let alert = UIAlertController(title: "Enter Password To Delete Account", message: "", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            guard let password = textField?.text else {return}
            self.reauthenticateWithPassword(password: password)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func reauthenticateWithPassword(password: String){
        
        //Reauthenticate the user, and if successful, attempt to delete their account
        //Query user for their password so reauth can be completed
        
        let user = Auth.auth().currentUser
        guard let email = user?.email else {
            return
        }
        print("EMAIL PASSED")
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        user?.reauthenticateAndRetrieveData(with: credential, completion: {
              (result, error) in
            if let error = error {
                print(error)
                self.displayAlertWithOKButton(text: "Error Deleting Account")
            }else{
                print("TRY DELETE AFTER AUTHENITCATE")
                self.deleteAccountAfterReauthenticate()
            }
        
        })
        
    }
    
    func displayAlertWithOKButton(text: String){
        let emptyFieldsAlert = UIAlertController(title: text, message: nil, preferredStyle: .alert)
        emptyFieldsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        }))
        self.present(emptyFieldsAlert, animated: true)
    }
    
    
    @IBAction func returnButtonTapped(_ sender: Any) {
        
        self.performSegueToReturnBack()

    }
    
    func performSegueToReturnBack()  {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func logOut(){
        
        do {
            try Auth.auth().signOut()
            try GIDSignIn.sharedInstance()?.signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        //Clear event tables
        tableEvents.removeAll()
        allEvents.removeAll()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
        
    }

}
