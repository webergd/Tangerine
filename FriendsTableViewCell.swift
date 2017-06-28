//
//  FriendsTableViewCell.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 6/24/17.
//  Copyright © 2017 Freedom Electric. All rights reserved.
//

import UIKit

class FriendsTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var friendNameLabel: UILabel!
    @IBOutlet weak var friendRatingLabel: UILabel!
    @IBOutlet weak var friendAgeLabel: UILabel!
    @IBOutlet weak var cellBackgroundView: UIView!


    
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    
}





















