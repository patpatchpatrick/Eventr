//
//  SettingsViewController.swift
//  Eventr
//
//  Created by Patrick Doyle on 5/22/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
    
    
    @IBOutlet weak var userAccountImage: RoundedImage!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var settingsButtonContainer: RoundUIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUserData()
        userNameLabel.addBottomBorderWithColor(color: themeTextColor, width: 1, widthExtension: 0
        )
        userEmailLabel.addBottomBorderWithColor(color: themeTextColor, width: 1, widthExtension: 0)
        configureFloatingSideButtonDesign(view: settingsButtonContainer)
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

}
