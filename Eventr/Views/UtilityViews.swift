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
        guard let backgroundColor = self.backgroundColor?.cgColor else { return }
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = (1.0 / UIScreen.main.scale) / 2;
        self.backgroundColor = UIColor.clear
    }
}

//Custom cell for event table view
class CustomEventCell: UITableViewCell {
    
    @IBOutlet weak var favoriteIcon: UIButton!
    @IBOutlet weak var categoryIcon: UIImageView!
    @IBOutlet weak var paidEvent: UIImageView!
    @IBOutlet weak var upvoteArrow: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var upvoteCount: UILabel!
    
    
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
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}

//Custom calendar cell
class CalendarCell: JTAppleCell {
    
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
}

class CalendarSectionHeaderView: JTAppleCollectionReusableView {
    
    @IBOutlet weak var title: UILabel!
    
}

