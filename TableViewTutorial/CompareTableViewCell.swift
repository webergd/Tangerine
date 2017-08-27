//
//  CompareTableViewCell.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/21/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//
//  This cell displays two images and which one has more votes has an arrow pointing toward it
//  There are also some assorted labels (added in interface builder)

import UIKit

class CompareTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var percentImage1Label: UILabel!
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var percentImage2Label: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var reviewsRequiredToUnlockLabel: UILabel!
    @IBOutlet weak var numVotesLabel: UILabel!
    
    
    // these are the squares that show up behind the winning pic. 1 for left, 2 for right.
    @IBOutlet weak var winnerOutline1: UIView!
    @IBOutlet weak var winnerOutline2: UIView!
    
    // Rating Bar Outlets
    @IBOutlet weak var rating100Bar1: UIView!
    @IBOutlet weak var ratingBar1: UIView!
    @IBOutlet weak var ratingStrongBar1: UIView!

    @IBOutlet weak var rating100Bar2: UIView!
    @IBOutlet weak var ratingBar2: UIView!
    @IBOutlet weak var ratingStrongBar2: UIView!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

