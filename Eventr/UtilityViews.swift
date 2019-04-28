//
//  UtilityViews.swift
//  Eventr
//
//  Created by Patrick Doyle on 4/25/19.
//  Copyright © 2019 Patrick Doyle. All rights reserved.
//

import Foundation
import UIKit


class HairlineView: UIView {
    override func awakeFromNib() {
        guard let backgroundColor = self.backgroundColor?.cgColor else { return }
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = (1.0 / UIScreen.main.scale) / 2;
        self.backgroundColor = UIColor.clear
    }
}

class CustomEventCell: UITableViewCell {
    
    //Custom cell for event table view
    
    @IBOutlet weak var paidEvent: UIImageView!
    @IBOutlet weak var upvoteArrow: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    
    
}
