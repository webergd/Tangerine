//
//  CompareBreakdownViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/26/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class CompareBreakdownViewController: UIViewController {

    // This outlet is here to enable swipe funtionality:
    @IBOutlet weak var compareBreakdownView: UIView!

    // Target Demographic Outlets:
    @IBOutlet weak var targetDemoNumReviewsLabel: UILabel!
    @IBOutlet weak var targetDemoWinningImageView: UIImageView!
    @IBOutlet weak var targetDemoWinningTitleLabel: UILabel!
    @IBOutlet weak var targetDemoVotePercentageTop: UILabel!
    @IBOutlet weak var targetDemoVotePercentageBottom: UILabel!
    @IBOutlet weak var targetDemoStrongVotePercentageTop: UILabel!
    @IBOutlet weak var targetDemoStrongVotePercentageBottom: UILabel!
    @IBOutlet weak var targetDemo100BarTop: UIView!
    @IBOutlet weak var targetDemo100BarBottom: UIView!
    @IBOutlet weak var targetDemoTopBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var targetDemoBottomBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var targetDemoTopStrongBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var targetDemoBottomStrongBarTrailingConstraint: NSLayoutConstraint!

    // Friends Outlets
    @IBOutlet weak var friendsNumReviewsLabel: UILabel!
    @IBOutlet weak var friendsWinningImageView: UIImageView!
    @IBOutlet weak var friendsWinningTitleLabel: UILabel!
    @IBOutlet weak var friendsVotePercentageTop: UILabel!
    @IBOutlet weak var friendsVotePercentageBottom: UILabel!
    @IBOutlet weak var friendsStrongVotePercentageTop: UILabel!
    @IBOutlet weak var friendsStrongVotePercentageBottom: UILabel!
    @IBOutlet weak var friends100BarTop: UIView!
    @IBOutlet weak var friends100BarBottom: UIView!
    @IBOutlet weak var friendsTopBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendsBottomBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendsTopStrongBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendsBottomStrongBarTrailingConstraint: NSLayoutConstraint!
    
    // All Reviews Outlets
    @IBOutlet weak var allReviewsNumReviewsLabel: UILabel!
    @IBOutlet weak var allReviewsWinningImageView: UIImageView!
    @IBOutlet weak var allReviewsWinningTitleLabel: UILabel!
    @IBOutlet weak var allReviewsVotePercentageTop: UILabel!
    @IBOutlet weak var allReviewsVotePercentageBottom: UILabel!
    @IBOutlet weak var allReviewsStrongVotePercentageTop: UILabel!
    @IBOutlet weak var allReviewsStrongVotePercentageBottom: UILabel!
    @IBOutlet weak var allReviews100BarTop: UIView!
    @IBOutlet weak var allReviews100BarBottom: UIView!
    @IBOutlet weak var allReviewsTopBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var allReviewsBottomBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var allReviewsTopStrongBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var allReviewsBottomStrongBarTrailingConstraint: NSLayoutConstraint!
    
    

    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        let swipeViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(CompareBreakdownViewController.userSwiped))
        compareBreakdownView.addGestureRecognizer(swipeViewGesture)
    }
    
    var container: Container? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        print("configuring ask view")
        
        // unwraps the ask that the tableView sent over:
        if let thisCompare = self.container?.question as! Compare? {
            let compareSW = thisCompare.breakdown.straightWomen as! CompareDemo
            let compareSM = thisCompare.breakdown.straightMen as! CompareDemo
            let compareGW = thisCompare.breakdown.gayWomen as! CompareDemo
            let compareGM = thisCompare.breakdown.gayMen as! CompareDemo
            
            // unwraps the ratingLabel from the IBOutlet and stores the demo rating to it (rounded)
            if let thisLabel = self.straightWomenVotes4OneLabel {
                thisLabel.text = "\(compareSW.votesForOne)"
            }
            if let thisLabel = self.straightWomenVotes4TwoLabel {
                thisLabel.text = "\(compareSW.votesForTwo)"
            }
            if let thisLabel = self.straightMenVotes4OneLabel {
                thisLabel.text = "\(compareSM.votesForOne)"
            }
            if let thisLabel = self.straightMenVotes4TwoLabel {
                thisLabel.text = "\(compareSM.votesForTwo)"
            }
            if let thisLabel = self.gayWomenVotes4OneLabel {
                thisLabel.text = "\(compareGW.votesForOne)"
            }
            if let thisLabel = self.gayWomenVotes4TwoLabel {
                thisLabel.text = "\(compareGW.votesForTwo)"
            }
            if let thisLabel = self.gayMenVotes4OneLabel {
                thisLabel.text = "\(compareGM.votesForOne)"
            }
            if let thisLabel = self.gayMenVotes4TwoLabel {
                thisLabel.text = "\(compareGM.votesForTwo)"
            }
            
            
            // unwraps the imageView from the IBOutlet
            if let thisImageView = self.imageView1 {
                thisImageView.image = thisCompare.comparePhoto1
            }
            if let thisImageView = self.imageView2 {
                thisImageView.image = thisCompare.comparePhoto2
            }
            
            if let thisLabel = self.title1Label {
                thisLabel.text = "\(thisCompare.compareTitle1)"
            }
            if let thisLabel = self.title2Label {
                thisLabel.text = "\(thisCompare.compareTitle2)"
            }
            
            // load the Avg Age labels
            if let thisLabel = self.straightWomenAvgAgeLabel {
                thisLabel.text = "\(compareSW.avgAge)"
            }
            if let thisLabel = self.straightMenAvgAgeLabel {
                thisLabel.text = "\(compareSM.avgAge)"
            }
            if let thisLabel = self.gayWomenAvgAgeLabel {
                thisLabel.text = "\(compareGW.avgAge)"
            }
            if let thisLabel = self.gayMenAvgAgeLabel {
                thisLabel.text = "\(compareGM.avgAge)"
            }
            
            // After linking constraints to this code using outlets,
            //  set this side by side with the AskViewController code
            //  and set up the equivalent for the CompareBreakdown bars
            // There should be more code in this one since there are 2x the bars.
            
            
            let targetDemoDataSet = self.container?.reviewCollection.pullConsolidatedCompareData(from: userDemoPreferences.minAge, to: userDemoPreferences.maxAge, straightWomen: userDemoPreferences.straightWomenPreferred, straightMen: userDemoPreferences.straightMenPreferred, gayWomen: userDemoPreferences.gayWomenPreferred, gayMen: userDemoPreferences.gayMenPreferred, friendsOnly: false)
            
            
            /*
            if let thisDataSet = targetDemoDataSet,
                let thisTopScoreLabel = self.votes1Label,
                let thisBottomScoreLabel = self.votes2Label {
                thisTopScoreLabel.text = "\(thisDataSet.percentTop) %"
                thisBottomScoreLabel.text = "\(thisDataSet.percentBottom) %"
            }
            
            */
            
            
            
            
            
        } else {
            print("Looks like ask is nil")
        }
    
    }
    
    

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userSwiped() {
        print("user swiped**********")
        self.navigationController?.popViewController(animated: true)
        
    }


    
}
