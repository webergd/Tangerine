//
//  CompareBreakdownViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/26/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

// Does the time remaining label display yet?


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
    
    
    @IBOutlet weak var compareTimeRemainingLabel: UILabel!
    
    // these are all initialized with actual values in configureView()
    var compareImage1: UIImage? = nil
    var compareImage2: UIImage? = nil
    var compareTitle1: String = ""
    var compareTitle2: String = ""

    
    
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
        print("configuring compare view")
        
        // unwraps the compare that the tableView sent over:
        if let thisCompare = self.container?.question as! Compare? {

            compareImage1 = thisCompare.comparePhoto1
            compareImage2 = thisCompare.comparePhoto2
            compareTitle1 = thisCompare.compareTitle1
            compareTitle2 = thisCompare.compareTitle2
            
            // unwraps the timeRemaining from the IBOutlet
            if let thisTimeRemaining = self.compareTimeRemainingLabel {
                thisTimeRemaining.text = "TIME REMAINING: \(thisCompare.timeRemaining)"
            }
            
            // After linking constraints to this code using outlets,
            //  set this side by side with the AskViewController code
            //  and set up the equivalent for the CompareBreakdown bars
            // There should be more code in this one since there are 2x the bars.
            
            
            // Configure TARGET DEMO data display:
            
            let targetDemoDataSet = self.container?.reviewCollection.pullConsolidatedCompareData(from: userDemoPreferences.minAge, to: userDemoPreferences.maxAge, straightWomen: userDemoPreferences.straightWomenPreferred, straightMen: userDemoPreferences.straightMenPreferred, gayWomen: userDemoPreferences.gayWomenPreferred, gayMen: userDemoPreferences.gayMenPreferred, friendsOnly: false)
 
            
            if let thisDataSet = targetDemoDataSet,
                let thisNumReviewsLabel = targetDemoNumReviewsLabel,
                let thisWinningImageView = targetDemoWinningImageView,
                let thisWinningTitleLabel = targetDemoWinningTitleLabel,
                let thisVotePercentageTopLabel = targetDemoVotePercentageTop,
                let thisVotePercentageBottomLabel = targetDemoVotePercentageBottom,
                let thisStrongVotePercentageTopLabel = targetDemoStrongVotePercentageTop,
                let thisStrongVotePercentageBottomLabel = targetDemoStrongVotePercentageBottom,
                let this100BarTop = targetDemo100BarTop,
                let this100BarBottom = targetDemo100BarBottom,
                let thisTopBarTrailingConstraint = targetDemoTopBarTrailingConstraint,
                let thisBottomBarTrailingConstraint = targetDemoBottomBarTrailingConstraint,
                let thisTopStrongBarTrailingConstraint = targetDemoTopStrongBarTrailingConstraint,
                let thisBottomStrongBarTrailingConstraint = targetDemoBottomStrongBarTrailingConstraint   {
                
                displayData(dataSet: thisDataSet,
                            numReviewsLabel: thisNumReviewsLabel,
                            winningImageView: thisWinningImageView,
                            winningTitleLabel: thisWinningTitleLabel,
                            votePercentageTopLabel: thisVotePercentageTopLabel,
                            votePercentageBottomLabel: thisVotePercentageBottomLabel,
                            strongVotePercentageTopLabel: thisStrongVotePercentageTopLabel,
                            strongVotePercentageBottomLabel: thisStrongVotePercentageBottomLabel,
                            hundredBarTopView: this100BarTop,
                            hundredBarBottomView: this100BarBottom,
                            topBarTrailingConstraint: thisTopBarTrailingConstraint,
                            bottomBarTrailingConstraint: thisBottomBarTrailingConstraint,
                            topStrongBarTrailingConstraint: thisTopStrongBarTrailingConstraint,
                            bottomStrongBarTrailingConstraint: thisBottomStrongBarTrailingConstraint)
            }
            
            // Configure FRIENDS data display:
            
            let friendsDataSet = self.container?.reviewCollection.pullConsolidatedCompareData(from: 0, to: 150, straightWomen: true, straightMen: true, gayWomen: true, gayMen: true, friendsOnly: true)
            
            
            if let thisDataSet = friendsDataSet,
                let thisNumReviewsLabel = friendsNumReviewsLabel,
                let thisWinningImageView = friendsWinningImageView,
                let thisWinningTitleLabel = friendsWinningTitleLabel,
                let thisVotePercentageTopLabel = friendsVotePercentageTop,
                let thisVotePercentageBottomLabel = friendsVotePercentageBottom,
                let thisStrongVotePercentageTopLabel = friendsStrongVotePercentageTop,
                let thisStrongVotePercentageBottomLabel = friendsStrongVotePercentageBottom,
                let this100BarTop = friends100BarTop,
                let this100BarBottom = friends100BarBottom,
                let thisTopBarTrailingConstraint = friendsTopBarTrailingConstraint,
                let thisBottomBarTrailingConstraint = friendsBottomBarTrailingConstraint,
                let thisTopStrongBarTrailingConstraint = friendsTopStrongBarTrailingConstraint,
                let thisBottomStrongBarTrailingConstraint = friendsBottomStrongBarTrailingConstraint   {
                
                // There is probably a way to avoid calling this next line in its entirety.
                // Violates the DRY principle but it does work..
                displayData(dataSet: thisDataSet,
                            numReviewsLabel: thisNumReviewsLabel,
                            winningImageView: thisWinningImageView,
                            winningTitleLabel: thisWinningTitleLabel,
                            votePercentageTopLabel: thisVotePercentageTopLabel,
                            votePercentageBottomLabel: thisVotePercentageBottomLabel,
                            strongVotePercentageTopLabel: thisStrongVotePercentageTopLabel,
                            strongVotePercentageBottomLabel: thisStrongVotePercentageBottomLabel,
                            hundredBarTopView: this100BarTop,
                            hundredBarBottomView: this100BarBottom,
                            topBarTrailingConstraint: thisTopBarTrailingConstraint,
                            bottomBarTrailingConstraint: thisBottomBarTrailingConstraint,
                            topStrongBarTrailingConstraint: thisTopStrongBarTrailingConstraint,
                            bottomStrongBarTrailingConstraint: thisBottomStrongBarTrailingConstraint)
            }
            
            // Configure ALL REVIEWS data display:
            
            let allReviewsDataSet = self.container?.reviewCollection.pullConsolidatedCompareData(from: 0, to: 150, straightWomen: true, straightMen: true, gayWomen: true, gayMen: true, friendsOnly: false)
            
            
            if let thisDataSet = allReviewsDataSet,
                let thisNumReviewsLabel = allReviewsNumReviewsLabel,
                let thisWinningImageView = allReviewsWinningImageView,
                let thisWinningTitleLabel = allReviewsWinningTitleLabel,
                let thisVotePercentageTopLabel = allReviewsVotePercentageTop,
                let thisVotePercentageBottomLabel = allReviewsVotePercentageBottom,
                let thisStrongVotePercentageTopLabel = allReviewsStrongVotePercentageTop,
                let thisStrongVotePercentageBottomLabel = allReviewsStrongVotePercentageBottom,
                let this100BarTop = allReviews100BarTop,
                let this100BarBottom = allReviews100BarBottom,
                let thisTopBarTrailingConstraint = allReviewsTopBarTrailingConstraint,
                let thisBottomBarTrailingConstraint = allReviewsBottomBarTrailingConstraint,
                let thisTopStrongBarTrailingConstraint = allReviewsTopStrongBarTrailingConstraint,
                let thisBottomStrongBarTrailingConstraint = allReviewsBottomStrongBarTrailingConstraint   {
                
                displayData(dataSet: thisDataSet,
                            numReviewsLabel: thisNumReviewsLabel,
                            winningImageView: thisWinningImageView,
                            winningTitleLabel: thisWinningTitleLabel,
                            votePercentageTopLabel: thisVotePercentageTopLabel,
                            votePercentageBottomLabel: thisVotePercentageBottomLabel,
                            strongVotePercentageTopLabel: thisStrongVotePercentageTopLabel,
                            strongVotePercentageBottomLabel: thisStrongVotePercentageBottomLabel,
                            hundredBarTopView: this100BarTop,
                            hundredBarBottomView: this100BarBottom,
                            topBarTrailingConstraint: thisTopBarTrailingConstraint,
                            bottomBarTrailingConstraint: thisBottomBarTrailingConstraint,
                            topStrongBarTrailingConstraint: thisTopStrongBarTrailingConstraint,
                            bottomStrongBarTrailingConstraint: thisBottomStrongBarTrailingConstraint)
            }
            
            
            
        } else {
            print("Looks like ask is nil")
        }
    
    }
    
    
    func displayData(dataSet: ConsolidatedCompareDataSet,
                     numReviewsLabel: UILabel,
                     winningImageView: UIImageView,
                     winningTitleLabel: UILabel,
                     votePercentageTopLabel: UILabel,
                     votePercentageBottomLabel: UILabel,
                     strongVotePercentageTopLabel: UILabel,
                     strongVotePercentageBottomLabel: UILabel,
                     hundredBarTopView: UIView,
                     hundredBarBottomView: UIView,
                     topBarTrailingConstraint: NSLayoutConstraint,
                     bottomBarTrailingConstraint: NSLayoutConstraint,
                     topStrongBarTrailingConstraint: NSLayoutConstraint,
                     bottomStrongBarTrailingConstraint: NSLayoutConstraint){
        
        numReviewsLabel.text = String(dataSet.numReviews)
        
        switch dataSet.winner {
        case .photo1Won:
            winningImageView.image = compareImage1
            winningTitleLabel.text = compareTitle2
        case .photo2Won:
            winningImageView.image = compareImage2
            winningTitleLabel.text = compareTitle2
        case .itsATie:
            winningImageView.image = #imageLiteral(resourceName: "shrug")
            winningTitleLabel.text = "TIE"
        }
      
        votePercentageTopLabel.text = String(dataSet.percentTop) + "%"
        votePercentageBottomLabel.text = String(dataSet.percentBottom) + "%"
        
        strongVotePercentageTopLabel.text = String(dataSet.percentStrongYesTop) + "%"
        strongVotePercentageBottomLabel.text = String(dataSet.percentStrongYesBottom) + "%"
        // Note: strongNo storage capability exists but has not been (and may never be) implemented
        
        let hundredBarTopWidth = hundredBarTopView.frame.size.width
        let hundredBarBottomWidth = hundredBarBottomView.frame.size.width
        
        // Both 100 bars should presumably be the same size. I used their separate values though in case something funky happens with te constraints at runtime.
        topBarTrailingConstraint.constant = calcTrailingConstraint(percentYes: dataSet.percentTop, hundredBarWidth: hundredBarTopWidth)
        bottomBarTrailingConstraint.constant = calcTrailingConstraint(percentYes: dataSet.percentBottom, hundredBarWidth: hundredBarBottomWidth)
        
        topStrongBarTrailingConstraint.constant = calcTrailingConstraint(percentYes: dataSet.percentStrongYesTop, hundredBarWidth: hundredBarTopWidth)
        bottomStrongBarTrailingConstraint.constant = calcTrailingConstraint(percentYes: dataSet.percentStrongYesBottom, hundredBarWidth: hundredBarBottomWidth)
        
        
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
