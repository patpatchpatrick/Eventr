//
//  UtilityViews.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/25/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import UIKit
import JTAppleCalendar

//Class for custom views

//1 pixel colored line
class HairlineView: UIView {
    override func awakeFromNib() {
        guard (self.backgroundColor?.cgColor) != nil else { return }
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = (1.0 / UIScreen.main.scale) / 2;
        self.backgroundColor = UIColor.white
    }
}

//Custom cell for event table view
class CustomEventCell: UITableViewCell {
    
    @IBOutlet weak var favoriteIcon: UIButton!
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var paidEvent: UIImageView!
    @IBOutlet weak var upvoteArrow: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var upvoteCount: UIButton!
    @IBOutlet weak var primaryView: UIView!
    @IBOutlet weak var eventDateAndTime: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var eventUserCount: UILabel!
    @IBOutlet weak var eventUserCountIcon: UIImageView!
    @IBOutlet weak var eventPrice: UILabel!
    
}

//Custom cell for friends tableview
class CustomFriendCell: UITableViewCell {
    
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var primaryView: RoundUIView!
    
}

//Class used for event tags
@IBDesignable
class CustomLabel: UILabel {
    
    @IBInspectable var borderColor: UIColor = UIColor.black {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
}

//Class used for rounded corner buttons
@IBDesignable
class RoundedButton: UIButton {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}


//Custom calendar cell
class CalendarCell: JTAppleCell {
    
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedMiddleView: UIView!
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
 
    
}

class CalendarSectionHeaderView: JTAppleCollectionReusableView {
    
    @IBOutlet weak var title: UILabel!
    
}

@IBDesignable
class RoundUIView: UIView {
    
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
}

//Class used for rounded corner buttons
@IBDesignable
class RoundedImage: UIImageView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
}





