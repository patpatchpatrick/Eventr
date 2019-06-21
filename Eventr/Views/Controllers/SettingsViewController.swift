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

var accountNotConfigured = false

class SettingsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet weak var settingsScreenTitle: UILabel!
    
    @IBOutlet weak var userAccountImageButton: RoundedButton!
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var settingsButtonContainer: RoundUIView!
    @IBOutlet weak var deleteAccountButton: RoundedButton!
    
    @IBOutlet weak var createAccountButton: RoundedButton!
    
    @IBOutlet weak var acceptImageButton: RoundedButton!
    @IBOutlet weak var discardImageButton: RoundedButton!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameEntryContainer: UIView!
    @IBOutlet weak var usernameTextEntry: UITextField!
    @IBOutlet weak var usernameDiscardButton: UIButton!
    @IBOutlet weak var usernameAcceptButton: UIButton!
    
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var nameEntryContainer: UIView!
    @IBOutlet weak var nameEntryTextField: UITextField!
    @IBOutlet weak var nameDiscardButton: UIButton!
    @IBOutlet weak var nameAcceptButton: UIButton!
    
    @IBOutlet weak var privateAccountSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUserData()
        configureViewsBasedOnIfUserIsCreatingAccount()
        resetViews()
        configureViewDesign()
        configureUserNameEntryFields()
        configureNameEntryFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
         configureViewsBasedOnIfUserIsCreatingAccount()
    }
    
    func configureViewsBasedOnIfUserIsCreatingAccount(){
        if accountNotConfigured {
            settingsScreenTitle.text = "Create Account"
            deleteAccountButton.isHidden = true
            createAccountButton.isHidden = false
            settingsButtonContainer.isHidden = true
        } else {
            settingsScreenTitle.text = "Settings"
            deleteAccountButton.isHidden = false
            createAccountButton.isHidden = true
            settingsButtonContainer.isHidden = false
        }
    }
    
    func resetViews(){
        discardImageButton.isHidden = true
        acceptImageButton.isHidden = true
        
    }
    
    
    func loadUserData(){
        //Set the profile photo, name and email of the logged in user if they are logged in
        reloadUserImage()
        
        if let userEmail = Auth.auth().currentUser?.email {
            userEmailLabel.isHidden = false
            userEmailLabel.text = userEmail
        } else {
            userEmailLabel.isHidden = true
        }
        if let userName = Auth.auth().currentUser?.displayName {
            accountNameLabel.text = userName
        }
    }
    
    func reloadUserImage(){
        
        if let userImage = userAccountImage{
            userAccountImageButton.setImage(userImage, for: .normal)
        } else {
            userAccountImageButton.setImage(UIImage(named: "accountIcon"), for: .normal)}
            
        
    }
    
    func configureUserNameEntryFields(){
        
        if userIsNotLoggedIn(){
            usernameEntryContainer.isHidden = true
            usernameLabel.isHidden = false
        } else {
            //If user has a username, display the username in the username label
            //If user doesn't have username, display the username entry container so they can create one
            usernameEntryContainer.isHidden = true
            usernameLabel.isHidden = true
            queryIfUserHasUsername(callback: {
                hasUserName, userName in
                if hasUserName{
                    self.usernameEntryContainer.isHidden = true
                    self.usernameLabel.isHidden = false
                    self.usernameLabel.text = userName
                } else {
                    self.usernameEntryContainer.isHidden = false
                    self.usernameLabel.isHidden = true
                }
            })
            
        }
        
        
    }
    
    func configureNameEntryFields(){
        
        if userIsNotLoggedIn(){
            nameEntryContainer.isHidden = true
            accountNameLabel.isHidden = false
        } else {
            //If user has a name, display the name in the name label
            //If user doesn't have name, display the name entry container so they can create one
            nameEntryContainer.isHidden = true
            accountNameLabel.isHidden = true
            queryIfUserHasName(callback: {
                hasName, name in
                if hasName{
                    self.nameEntryContainer.isHidden = true
                    self.accountNameLabel.isHidden = false
                    self.accountNameLabel.text = name
                } else {
                    self.nameEntryContainer.isHidden = false
                    self.accountNameLabel.isHidden = true
                }
            })
            
        }
        
        
        
    }
    
    
    func configureViewDesign(){
        accountNameLabel.addBottomBorderWithColor(color: themeTextColor, width: 1, widthExtension: 0
        )
        userEmailLabel.addBottomBorderWithColor(color: themeTextColor, width: 1, widthExtension: 0)
        configureFloatingSideButtonDesign(view: settingsButtonContainer)
        configureFloatingSideButtonDesign(view: deleteAccountButton)
        configureFloatingSideButtonDesign(view: createAccountButton)
        usernameLabel.addBottomBorderWithColor(color: themeTextColor, width: 1, widthExtension: 0)
        
    }
    
    
    @IBAction func usernameDiscardButtonTapped(_ sender: UIButton) {
        //Clear the text in the username field
        usernameTextEntry.text = ""
    }
    
    
    @IBAction func usernameAcceptButtonTapped(_ sender: Any) {
        //
        guard let requestedUsernameText = usernameTextEntry.text else {return}
        let requestedUsername = requestedUsernameText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if requestedUsername.count < 4 {
            displayAlertWithOKButton(text: "Username must be at least 4 characters long")
            return
        }
        if requestedUsername.count > 27 {
            displayAlertWithOKButton(text: "Username exceeds maximum length")
            return
        }
        
        submitUserNameIfUnique(username: requestedUsername, callback: {
            userNameAccepted in
            
            if userNameAccepted {
                //If user name is accepted by Firebase, show the username label instead of the username entry container
                self.usernameLabel.text = requestedUsername
                self.usernameLabel.isHidden = false
                self.usernameEntryContainer.isHidden = true
                setPrivateAccountStatusInFirebase(accountIsPrivate: self.privateAccountSwitch.isOn) //The private status on the account is set when the username is created because the username is required, and we want to ensure that the user has their private status set
            } else {
                self.displayAlertWithOKButton(text: "Username taken. Please try another.")
            }
            
        })
        
        
    }
    
    
    @IBAction func nameDiscardButtonTapped(_ sender: UIButton) {
        //Clear the text in the name field
        nameEntryTextField.text = ""
    }
    
    
    @IBAction func nameAcceptButtonTapped(_ sender: UIButton) {
        
        guard let nameText = nameEntryTextField.text else {return}
        let selectedName = nameText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if selectedName.count < 2 {
            displayAlertWithOKButton(text: "Name must be at least 2 characters long")
            return
        }
        if selectedName.count > 27 {
            displayAlertWithOKButton(text: "Name exceeds maximum length")
            return
        }
        
        submitNameToFirebase(name: selectedName)
        self.accountNameLabel.text = selectedName
        self.accountNameLabel.isHidden = false
        self.nameEntryContainer.isHidden = true
        
    }
    
    
    @IBAction func privateAccountSwitchTapped(_ sender: UISwitch) {
        
        setPrivateAccountStatusInFirebase(accountIsPrivate: sender.isOn)
        
    }
    
    
    @IBAction func userImageButtonTapped(_ sender: RoundedButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    
    }
    
    
    @IBAction func acceptImageButtonTapped(_ sender: RoundedButton) {
        
        //If image is accepted, upload it to Firebase Storage for the user's profile image
        
        guard let accountImage = userAccountImageButton.image(for: .normal) else {return}
        
        submitImageToFirebase(image: accountImage, callback: {
            imageUploadedSuccessfully in
            
            if imageUploadedSuccessfully{
                
                self.acceptImageButton.isHidden = true
                self.discardImageButton.isHidden = true
                userAccountImage = accountImage
             
                
            } else {
                self.displayAlertWithOKButton(text: "Image Failed to Upload.  Max Image Size is 8MB.  Please try a different image.")
            }
            
        })
        
    }
    
    
    @IBAction func discardImageButtonTapped(_ sender: RoundedButton) {
        reloadUserImage()
        self.acceptImageButton.isHidden = true
        self.discardImageButton.isHidden = true
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
                    fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
                 }
        let size = CGSize(width: 200, height: 200)
        let croppedImage = image.crop(to: size)
        userAccountImageButton.setImage(croppedImage, for: .normal)
        
        //After new image is chosen, show the accept and discard buttons so the user can choose to set new image as their profile image if they wish
        acceptImageButton.isHidden = false
        discardImageButton.isHidden = false
    
    }
    
    
    @IBAction func createAccountButtonTapped(_ sender: RoundedButton) {
        
            accountNotConfigured = false
            self.performSegueToReturnBack()
    }
    
    
    
    @IBAction func deleteAccountButtonTapped(_ sender: UIButton) {
        
        let deleteAccountAlert = UIAlertController(title: "Are you sure you want to delete account?", message: "Account deletion is permanent.  All of your created events will be deleted.", preferredStyle: .alert)
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
