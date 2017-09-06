//
//  AskTableViewCell.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/14/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class AskTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    //@IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var numVotesLabel: UILabel!
    @IBOutlet weak var reviewsRequiredToUnlockLabel: UILabel!
    @IBOutlet weak var lockLabel: UILabel!
    

    @IBOutlet weak var yesPercentage: UILabel!
    @IBOutlet weak var strongYesPercentage: UILabel!
    @IBOutlet weak var rating100Bar: UIView!
    @IBOutlet weak var ratingBar: UIView!
    @IBOutlet weak var ratingStrongBar: UIView!
    @IBOutlet weak var ratingBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var ratingStrongBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var yesPercentageLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var strongYesPercentageTrailingConstraint: NSLayoutConstraint!
    
    func displayCellData(dataSet: ConsolidatedAskDataSet){
        displayData(dataSet: dataSet,
                    totalReviewsLabel: numVotesLabel,
                    yesPercentageLabel: yesPercentage,
                    strongYesPercentageLabel: strongYesPercentage,
                    hundredBarView: rating100Bar,
                    yesTrailingConstraint: ratingBarTrailingConstraint,
                    yesLabelLeadingConstraint: yesPercentageLeadingConstraint,
                    strongYesTrailingConstraint: ratingStrongBarTrailingConstraint,
                    strongYesLabelTrailingConstraint: strongYesPercentageTrailingConstraint)
    }
    /* // This was moved to DataModels.swift
    func displayData(dataSet: ConsolidatedAskDataSet,
                     totalReviewsLabel: UILabel,
                     yesPercentageLabel: UILabel,
                     strongYesPercentageLabel: UILabel,
                     hundredBarView: UIView,
                     yesTrailingConstraint: NSLayoutConstraint,
                    yesLabelLeadingConstraint: NSLayoutConstraint,
                    strongYesTrailingConstraint: NSLayoutConstraint,
                    strongYesLabelTrailingConstraint: NSLayoutConstraint){
        
        totalReviewsLabel.text = String(dataSet.numReviews)
        yesPercentageLabel.text = String(dataSet.percentYes) + "%"
        strongYesPercentageLabel.text = String(dataSet.percentStrongYes) + "%"
        
        print("strong yes percentage: \(dataSet.percentStrongYes)")
        
        let hundredBarWidth = hundredBarView.frame.size.width
        
        yesTrailingConstraint.constant = calcTrailingConstraint(percentYes: dataSet.percentYes, hundredBarWidth: hundredBarWidth)
        
        strongYesTrailingConstraint.constant = calcTrailingConstraint(percentYes: dataSet.percentStrongYes, hundredBarWidth: hundredBarWidth)
        
        strongYesLabelTrailingConstraint.constant = 0.5
        strongYesPercentageLabel.textColor = UIColor.white
        strongYesPercentageLabel.isHidden = false
        
        flipBarLabelsAsRequired(hundredBarWidth: hundredBarWidth,
                                yesTrailingConstraint: yesTrailingConstraint,
                                yesPercentageLabel: yesPercentageLabel,
                                yesLabelLeadingConstraint: yesLabelLeadingConstraint,
                                strongYesTrailingConstraint: strongYesTrailingConstraint,
                                strongYesPercentageLabel: strongYesPercentageLabel,
                                strongYesLabelTrailingConstraint: strongYesLabelTrailingConstraint)
        
    } // end of displayData(..)
    */
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

    
    
}





















