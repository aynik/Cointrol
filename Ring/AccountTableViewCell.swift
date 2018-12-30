//
//  MealTableViewCell.swift
//  FoodTracker
//
//  Created by Pablo on 27/12/2018.
//  Copyright © 2018 Pablo. All rights reserved.
//

import UIKit

class AccountTableViewCell: UITableViewCell {
    // MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
