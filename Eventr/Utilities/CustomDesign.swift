//
//  CustomDesign.swift
//  Eventr
//
//  Created by Patrick Doyle on 5/19/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import UIKit

//Class for common shared designs used throughout the app

//Floating side buttons are rounded buttons that are cut off by the main view
func configureFloatingSideButtonDesign(view: UIView){
    
    let shadowSize : CGFloat = 0.0
    let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                               y: -shadowSize / 2,
                                               width: view.frame.size.width + shadowSize,
                                               height: view.frame.size.height + shadowSize))
    view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
    view.layer.shadowOffset = CGSize(width: 0, height: 0)
    view.layer.shadowOpacity = 0.7
    view.layer.shadowRadius = 10.0
    view.layer.masksToBounds = false
    view.layer.shadowPath = shadowPath.cgPath
    
}
