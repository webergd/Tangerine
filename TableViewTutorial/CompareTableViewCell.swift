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
    @IBOutlet weak var title2Label: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

