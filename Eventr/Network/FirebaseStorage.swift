//
//  FirebaseStorage.swift
//  Eventr
//
//  Created by Patrick Doyle on 6/20/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage

//Class to handle calls to Firebase Storage

func submitImageToFirebase(image: UIImage, callback: @escaping ((Bool) -> Void)){
    
    guard let userID = Auth.auth().currentUser?.uid else { return }
    guard let imageData = image.pngData() else {return}
    
    
    let storage = Storage.storage()
    let storageRef = storage.reference()
    let imageRef = storageRef.child(userID).child("account.png")
  
    let bytes = Double(imageData.count)
    let fileSize = Double(bytes / 1048576.0) //Convert in to MB
    print("File size in bytes: ", bytes)
    print("File size in MB: ", fileSize)
    
    //If image is more than 8MB then it's too large... return
    if fileSize > 8.0 {
        callback(false)
        return
    }
    
    
    // Upload the file to the path
    let uploadTask = imageRef.putData(imageData, metadata: nil) { (metadata, error) in
        guard let metadata = metadata else {
            callback(false)
            print("Metadata Error")
            return
        }
        
        callback(true)
       
    }
    
}

func loadUserImageFromFirebase(callback: @escaping ((UIImage?) -> Void)) {
    
     guard let userID = Auth.auth().currentUser?.uid else { return }
    // Reference to the user account image file to download
    let storage = Storage.storage()
    let storageRef = storage.reference()
    let imageRef = storageRef.child(userID).child("account.png")
    
    // Download in memory with a maximum allowed size of 8MB (1 * 1024 * 1024 bytes)
    imageRef.getData(maxSize: 8 * 1024 * 1024) { data, error in
        if let error = error {
            // Uh-oh, an error occurred!
            callback(nil)
        } else {
            // Data for "images/island.jpg" is returned
            let image = UIImage(data: data!)
            callback(image)
        }
    }
    
}

func loadFriendImageFromFirebase(friendID: String, callback: @escaping ((UIImage?) -> Void) ){
    
    // Reference to the user account image file to download
    let storage = Storage.storage()
    let storageRef = storage.reference()
    let imageRef = storageRef.child(friendID).child("account.png")
    
    // Download in memory with a maximum allowed size of 8MB (1 * 1024 * 1024 bytes)
    imageRef.getData(maxSize: 8 * 1024 * 1024) { data, error in
        if let error = error {
            // Uh-oh, an error occurred!
            callback(nil)
        } else {
            // Data for "images/island.jpg" is returned
            let image = UIImage(data: data!)
            callback(image)
        }
    }
    
}
