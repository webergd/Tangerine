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
    
    // Outlets for positioning triangle marker:
    @IBOutlet weak var triangleMarkerLabel: UILabel!
    @IBOutlet weak var triangleMarkerCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerDividerView: UIView!
    
    // Deleted:
    // these are the squares that show up behind the winning pic. 1 for left, 2 for right.
    //@IBOutlet weak var winnerOutline1: UIView!
    //@IBOutlet weak var winnerOutline2: UIView!
    
    // Rating Bar Outlets
    @IBOutlet weak var rating100Bar1: UIView!
    @IBOutlet weak var ratingBar1: UIView!
    @IBOutlet weak var ratingStrongBar1: UIView!
    @IBOutlet weak var ratingBar1LeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var ratingStrongBar1LeadingConstraint: NSLayoutConstraint!

    // The reason that the bar1 constraints are leading instead of 
    //  trailing like normal is because bar one faces the 
    //  oppopsite direction from the other bar display layouts
    
    @IBOutlet weak var rating100Bar2: UIView!
    @IBOutlet weak var ratingBar2: UIView!
    @IBOutlet weak var ratingStrongBar2: UIView!
    @IBOutlet weak var ratingBar2TrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var ratingStrongBar2TrailingConstraint: NSLayoutConstraint!
    
    func displayCellData(dataSet: ConsolidatedCompareDataSet){
        
        displayData(dataSet: dataSet,
                    numReviewsLabel: numVotesLabel,
                    votePercentageTopLabel: percentImage1Label,
                    votePercentageBottomLabel: percentImage2Label,
                    strongVotePercentageTopLabel: nil,
                    strongVotePercentageBottomLabel: nil,
                    hundredBarTopView: rating100Bar1,
                    hundredBarBottomView: rating100Bar2,
                    topBarTrailingConstraint: ratingBar1LeadingConstraint,
                    voteTopLabelLeadingConstraint: nil,
                    bottomBarTrailingConstraint: ratingBar2TrailingConstraint,
                    voteBottomLabelLeadingConstraint: nil,
                    topStrongBarTrailingConstraint: ratingStrongBar1LeadingConstraint,
                    strongTopLabelTrailingConstraint: nil,
                    bottomStrongBarTrailingConstraint: ratingStrongBar2TrailingConstraint,
                    strongBottomLabelTrailingConstraint: nil)
        
        // Move the triangle into the right position:
        // Determine what value full deflection has
        let fullDeflection: CGFloat = (centerDividerView.frame.size.width / 2) + rating100Bar1.frame.size.width
        print("full deflection determined to be: \(fullDeflection)")
        
        // Determine how much deflection we want by finding the difference between vote quantities
        let voteDifference: CGFloat = CGFloat(100 - (2 * dataSet.percentTop))
        
        // Set the triangle's offset from center to reflect the desired offset from center
        triangleMarkerCenterConstraint.constant = (voteDifference / 100) * fullDeflection
        
        // Set the triangle's label.text with the absolute value of the difference between the vote quantities
        triangleMarkerLabel.text = "\(Int(voteDifference.magnitude))%"
        
        
        

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

