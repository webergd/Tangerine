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
    @IBOutlet weak var targetDemoLabel: UILabel!
    @IBOutlet weak var targetDemoView: UIView!
    
    @IBOutlet weak var targetDemoNumReviewsLabel: UILabel!
    @IBOutlet weak var targetDemoWinningImageView: UIImageView!
    @IBOutlet weak var targetDemoWinningTitleLabel: UILabel!
    @IBOutlet weak var targetDemoVotePercentageTop: UILabel!
    @IBOutlet weak var targetDemoVotePercentageBottom: UILabel!
    @IBOutlet weak var targetDemoStrongVotePercentageTop: UILabel!
    @IBOutlet weak var targetDemoStrongVotePercentageBottom: UILabel!
    @IBOutlet weak var targetDemo100BarTop: UIView!
    @IBOutlet weak var targetDemo100BarBottom: UIView!
    @IBOutlet weak var targetDemoTopBarTrailingConstraint: NSLayoutConstraint! //controls length of top white bar
    @IBOutlet weak var targetDemoBottomBarTrailingConstraint: NSLayoutConstraint! //controls length of bottom white bar
    @IBOutlet weak var targetDemoTopStrongBarTrailingConstraint: NSLayoutConstraint! //controls length of top blue bar
    @IBOutlet weak var targetDemoBottomStrongBarTrailingConstraint: NSLayoutConstraint! //controls length of bottom blue bar
    @IBOutlet weak var targetDemoVoteTopLabelLeadingConstraint: NSLayoutConstraint! //controls position of normal votes top number
    @IBOutlet weak var targetDemoVoteBottomLabelLeadingConstraint: NSLayoutConstraint! //controls position of normal votes bottom number
    @IBOutlet weak var targetDemoStrongTopLabelTrailingConstraint: NSLayoutConstraint! //controls position of strong votes top number
    @IBOutlet weak var targetDemoStrongBottomLabelTrailingConstraint: NSLayoutConstraint! //controls position of strong votes top number
    

    // Friends Outlets
    @IBOutlet weak var friendsLabel: UILabel! // remove this
    @IBOutlet weak var friendsView: UIView!
    
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
    @IBOutlet weak var friendsVoteTopLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendsVoteBottomLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendsStrongTopLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendsStrongBottomLabelTrailingConstraint: NSLayoutConstraint!

    
    
    
    // All Reviews Outlets
    @IBOutlet weak var allReviewsLabel: UILabel! //remove this
    @IBOutlet weak var allReviewsView: UIView!
    
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
    @IBOutlet weak var allReviewsVoteTopLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var allReviewsVoteBottomLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var allReviewsStrongTopLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var allReviewsStrongBottomLabelTrailingConstraint: NSLayoutConstraint!


    
    @IBOutlet weak var compareTimeRemainingLabel: UILabel!
    
    var sortType: userGroup = .allUsers // this will be adjusted prior to segue if user taps specific area
    
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
        sortType = .allUsers // this should always be the default
        let swipeViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(CompareBreakdownViewController.userSwiped))
        compareBreakdownView.addGestureRecognizer(swipeViewGesture)
        
        
        // Gesture Recognizers for swiping left and right
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(CompareBreakdownViewController.userSwiped))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(CompareBreakdownViewController.userSwiped))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        // Gesture recognizers for tapping sortType labels to filter reviews
        let tdTap = UITapGestureRecognizer(target: self, action: #selector(CompareBreakdownViewController.userTappedTargetDemographicLabel))
        targetDemoView.addGestureRecognizer(tdTap)

        
        
        let friendsTap = UITapGestureRecognizer(target: self, action: #selector(CompareBreakdownViewController.userTappedFriendsLabel))
        friendsView.addGestureRecognizer(friendsTap)
        
        let arTap = UITapGestureRecognizer(target: self, action: #selector(CompareBreakdownViewController.userTappedAllReviewsLabel))
        allReviewsView.addGestureRecognizer(arTap)
        

        
    }
    
    var container: Container? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        print("configuring compare view")

        guard let container = container else {
            print("container was nil")
            return
        }
        
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
            
            let targetDemoDataSet = pullConsolidatedData(from: container, filteredBy: .targetDemo) as! ConsolidatedCompareDataSet
            
            /*let targetDemoDataSet = self.container?.reviewCollection.pullConsolidatedCompareData(
                from: localMyUser.targetDemo.minAge,
                to: localMyUser.targetDemo.maxAge,
                straightWomen: localMyUser.targetDemo.straightWomenPreferred,
                straightMen: localMyUser.targetDemo.straightMenPreferred,
                gayWomen: localMyUser.targetDemo.gayWomenPreferred,
                gayMen: localMyUser.targetDemo.gayMenPreferred,
                friendsOnly: false)
            */
 
            
            if let thisNumReviewsLabel = targetDemoNumReviewsLabel,
                let thisWinningImageView = targetDemoWinningImageView,
                let thisWinningTitleLabel = targetDemoWinningTitleLabel,
                let thisVotePercentageTopLabel = targetDemoVotePercentageTop,
                let thisVotePercentageBottomLabel = targetDemoVotePercentageBottom,
                let thisStrongVotePercentageTopLabel = targetDemoStrongVotePercentageTop,
                let thisStrongVotePercentageBottomLabel = targetDemoStrongVotePercentageBottom,
                let this100BarTop = targetDemo100BarTop,
                let this100BarBottom = targetDemo100BarBottom,
                let thisTopBarTrailingConstraint = targetDemoTopBarTrailingConstraint,
                let thisVoteTopLabelLeadingConstraint = targetDemoVoteTopLabelLeadingConstraint,
                let thisBottomBarTrailingConstraint = targetDemoBottomBarTrailingConstraint,
                let thisVoteBottomLabelLeadingConstraint = targetDemoVoteBottomLabelLeadingConstraint,
                let thisTopStrongBarTrailingConstraint = targetDemoTopStrongBarTrailingConstraint,
                let thisStrongTopLabelTrailingConstraint = targetDemoStrongTopLabelTrailingConstraint,
                let thisBottomStrongBarTrailingConstraint = targetDemoBottomStrongBarTrailingConstraint,
                let thisStrongBottomLabelTrailingConstraint = targetDemoStrongBottomLabelTrailingConstraint {
                
                displayData(dataSet: targetDemoDataSet,
                            numReviewsLabel: thisNumReviewsLabel,
                            votePercentageTopLabel: thisVotePercentageTopLabel,
                            votePercentageBottomLabel: thisVotePercentageBottomLabel,
                            strongVotePercentageTopLabel: thisStrongVotePercentageTopLabel,
                            strongVotePercentageBottomLabel: thisStrongVotePercentageBottomLabel,
                            hundredBarTopView: this100BarTop,
                            hundredBarBottomView: this100BarBottom,
                            topBarTrailingConstraint: thisTopBarTrailingConstraint,
                            voteTopLabelLeadingConstraint: thisVoteTopLabelLeadingConstraint,
                            bottomBarTrailingConstraint: thisBottomBarTrailingConstraint,
                            voteBottomLabelLeadingConstraint: thisVoteBottomLabelLeadingConstraint,
                            topStrongBarTrailingConstraint: thisTopStrongBarTrailingConstraint,
                            strongTopLabelTrailingConstraint: thisStrongTopLabelTrailingConstraint,
                            bottomStrongBarTrailingConstraint: thisBottomStrongBarTrailingConstraint,
                            strongBottomLabelTrailingConstraint: thisStrongBottomLabelTrailingConstraint)
                
                displayWinningImage(in: thisWinningImageView, with: thisWinningTitleLabel, using: targetDemoDataSet)
                
            }
            
            // Configure FRIENDS data display:
            
            let friendsDataSet = pullConsolidatedData(from: container, filteredBy: .friends) as! ConsolidatedCompareDataSet
            
            //let friendsDataSet = self.container?.reviewCollection.pullConsolidatedCompareData(from: 0, to: 150, straightWomen: true, straightMen: true, gayWomen: true, gayMen: true, friendsOnly: true)
            
            
            if let thisNumReviewsLabel = friendsNumReviewsLabel,
                let thisWinningImageView = friendsWinningImageView,
                let thisWinningTitleLabel = friendsWinningTitleLabel,
                let thisVotePercentageTopLabel = friendsVotePercentageTop,
                let thisVotePercentageBottomLabel = friendsVotePercentageBottom,
                let thisStrongVotePercentageTopLabel = friendsStrongVotePercentageTop,
                let thisStrongVotePercentageBottomLabel = friendsStrongVotePercentageBottom,
                let this100BarTop = friends100BarTop,
                let this100BarBottom = friends100BarBottom,
                let thisTopBarTrailingConstraint = friendsTopBarTrailingConstraint,
                let thisVoteTopLabelLeadingConstraint = friendsVoteTopLabelLeadingConstraint,
                let thisBottomBarTrailingConstraint = friendsBottomBarTrailingConstraint,
                let thisVoteBottomLabelLeadingConstraint = friendsVoteBottomLabelLeadingConstraint,
                let thisTopStrongBarTrailingConstraint = friendsTopStrongBarTrailingConstraint,
                let thisStrongTopLabelTrailingConstraint = friendsStrongTopLabelTrailingConstraint,
                let thisBottomStrongBarTrailingConstraint = friendsBottomStrongBarTrailingConstraint,
                let thisStrongBottomLabelTrailingConstraint = friendsStrongBottomLabelTrailingConstraint   {
                
                // There is probably a way to avoid calling this next line in its entirety.
                // Violates the DRY principle but it does work..
                // Although it is technically just a method call
                displayData(dataSet: friendsDataSet,
                            numReviewsLabel: thisNumReviewsLabel,
                            votePercentageTopLabel: thisVotePercentageTopLabel,
                            votePercentageBottomLabel: thisVotePercentageBottomLabel,
                            strongVotePercentageTopLabel: thisStrongVotePercentageTopLabel,
                            strongVotePercentageBottomLabel: thisStrongVotePercentageBottomLabel,
                            hundredBarTopView: this100BarTop,
                            hundredBarBottomView: this100BarBottom,
                            topBarTrailingConstraint: thisTopBarTrailingConstraint,
                            voteTopLabelLeadingConstraint: thisVoteTopLabelLeadingConstraint,
                            bottomBarTrailingConstraint: thisBottomBarTrailingConstraint,
                            voteBottomLabelLeadingConstraint: thisVoteBottomLabelLeadingConstraint,
                            topStrongBarTrailingConstraint: thisTopStrongBarTrailingConstraint,
                            strongTopLabelTrailingConstraint: thisStrongTopLabelTrailingConstraint,
                            bottomStrongBarTrailingConstraint: thisBottomStrongBarTrailingConstraint,
                            strongBottomLabelTrailingConstraint: thisStrongBottomLabelTrailingConstraint)
                
                displayWinningImage(in: thisWinningImageView, with: thisWinningTitleLabel, using: friendsDataSet)
            }
            
            // Configure ALL REVIEWS data display:
            
            
            let allReviewsDataSet = pullConsolidatedData(from: container, filteredBy: .allReviews) as! ConsolidatedCompareDataSet
            
            //let allReviewsDataSet = self.container?.reviewCollection.pullConsolidatedCompareData(from: 0, to: 150, straightWomen: true, straightMen: true, gayWomen: true, gayMen: true, friendsOnly: false)
            
            
            if let thisNumReviewsLabel = allReviewsNumReviewsLabel,
                let thisWinningImageView = allReviewsWinningImageView,
                let thisWinningTitleLabel = allReviewsWinningTitleLabel,
                let thisVotePercentageTopLabel = allReviewsVotePercentageTop,
                let thisVotePercentageBottomLabel = allReviewsVotePercentageBottom,
                let thisStrongVotePercentageTopLabel = allReviewsStrongVotePercentageTop,
                let thisStrongVotePercentageBottomLabel = allReviewsStrongVotePercentageBottom,
                let this100BarTop = allReviews100BarTop,
                let this100BarBottom = allReviews100BarBottom,
                let thisTopBarTrailingConstraint = allReviewsTopBarTrailingConstraint,
                let thisVoteTopLabelLeadingConstraint = allReviewsVoteTopLabelLeadingConstraint,
                let thisBottomBarTrailingConstraint = allReviewsBottomBarTrailingConstraint,
                let thisVoteBottomLabelLeadingConstraint = allReviewsVoteBottomLabelLeadingConstraint,
                let thisTopStrongBarTrailingConstraint = allReviewsTopStrongBarTrailingConstraint,
                let thisStrongTopLabelTrailingConstraint = allReviewsStrongTopLabelTrailingConstraint,
                let thisBottomStrongBarTrailingConstraint = allReviewsBottomStrongBarTrailingConstraint,
                let thisStrongBottomLabelTrailingConstraint = allReviewsStrongBottomLabelTrailingConstraint   {
                
                displayData(dataSet: allReviewsDataSet,
                            numReviewsLabel: thisNumReviewsLabel,
                            votePercentageTopLabel: thisVotePercentageTopLabel,
                            votePercentageBottomLabel: thisVotePercentageBottomLabel,
                            strongVotePercentageTopLabel: thisStrongVotePercentageTopLabel,
                            strongVotePercentageBottomLabel: thisStrongVotePercentageBottomLabel,
                            hundredBarTopView: this100BarTop,
                            hundredBarBottomView: this100BarBottom,
                            topBarTrailingConstraint: thisTopBarTrailingConstraint,
                            voteTopLabelLeadingConstraint: thisVoteTopLabelLeadingConstraint,
                            bottomBarTrailingConstraint: thisBottomBarTrailingConstraint,
                            voteBottomLabelLeadingConstraint: thisVoteBottomLabelLeadingConstraint,
                            topStrongBarTrailingConstraint: thisTopStrongBarTrailingConstraint,
                            strongTopLabelTrailingConstraint: thisStrongTopLabelTrailingConstraint,
                            bottomStrongBarTrailingConstraint: thisBottomStrongBarTrailingConstraint,
                            strongBottomLabelTrailingConstraint: thisStrongBottomLabelTrailingConstraint)
                
                displayWinningImage(in: thisWinningImageView, with: thisWinningTitleLabel, using: allReviewsDataSet)
            
            }
            
            
            
            
            
        } else {
            print("Looks like ask is nil")
        }
    
    }
    
    func displayWinningImage(in winningImageView: UIImageView, with winningTitleLabel: UILabel, using dataSet: ConsolidatedCompareDataSet){
        // This only comes into play when using the method for CompareBreakdownVC
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
    }
    
    /*
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
                     voteTopLabelLeadingConstraint: NSLayoutConstraint,
                     bottomBarTrailingConstraint: NSLayoutConstraint,
                     voteBottomLabelLeadingConstraint: NSLayoutConstraint,
                     topStrongBarTrailingConstraint: NSLayoutConstraint,
                     strongTopLabelTrailingConstraint: NSLayoutConstraint,
                     bottomStrongBarTrailingConstraint: NSLayoutConstraint,
                     strongBottomLabelTrailingConstraint: NSLayoutConstraint){
        
        
        
        numReviewsLabel.text = "\(dataSet.numReviews) reviews"
        
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
      
        //////////
        
        // The next step here is to mimick the if logic in the displayData
        //  method of AskViewController in order to cause the Top or 
        //  bottom and strong top or bottom labels to:
        //  (1) switch sides if there isn't enough room to display the number
        //  (2) become hidden if strong is too close to regular such that
        //       the labels displayed would become cluttered.
        //
        //  Most of the code is already written. It should go quickly.
        
        //////////
        
        
        
        
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
        
        
        // adjust top bar labels if necessary:
        flipBarLabelsAsRequired(hundredBarWidth: hundredBarTopWidth,
                                yesTrailingConstraint: topBarTrailingConstraint,
                                yesPercentageLabel: votePercentageTopLabel,
                                yesLabelLeadingConstraint: voteTopLabelLeadingConstraint,
                                strongYesTrailingConstraint: topStrongBarTrailingConstraint,
                                strongYesPercentageLabel: strongVotePercentageTopLabel,
                                strongYesLabelTrailingConstraint: strongTopLabelTrailingConstraint)
        
        // adjust bottom bar labels if necessary:
        flipBarLabelsAsRequired(hundredBarWidth: hundredBarBottomWidth,
                                yesTrailingConstraint: bottomBarTrailingConstraint,
                                yesPercentageLabel: votePercentageBottomLabel,
                                yesLabelLeadingConstraint: voteBottomLabelLeadingConstraint,
                                strongYesTrailingConstraint: bottomStrongBarTrailingConstraint,
                                strongYesPercentageLabel: strongVotePercentageBottomLabel,
                                strongYesLabelTrailingConstraint: strongBottomLabelTrailingConstraint)

        
        
    } // end of displayData method */

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userSwiped(gesture: UIGestureRecognizer) {
        //print("user swiped**********")
        //self.navigationController?.popViewController(animated: true)
        
        
        ///////////////////////////////////////////////////
        // The next step is to hook up the swipe and tap //
        //  segues from this view controller.            //
        // Almost all example functionality should       //
        //  be found in AskViewController                //
        ///////////////////////////////////////////////////
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == UISwipeGestureRecognizerDirection.right {
                // go back to previous view by swiping right
                self.navigationController?.popViewController(animated: true)
            } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.left {
                sortType = .allUsers // on left swipe show all reviews (may want to change this to targetDemo instead)
                segueToNextViewController()
            }

        }
    } // end of userSwiped
    
    func userTappedTargetDemographicLabel(sender: UITapGestureRecognizer) {
        print("td label tapped")
        self.sortType = .targetDemo
        segueToNextViewController()
    }
    
    func userTappedFriendsLabel(sender: UITapGestureRecognizer) {
        print("friends label tapped")
        self.sortType = .friends
        segueToNextViewController()
    }
    
    func userTappedAllReviewsLabel(sender: UITapGestureRecognizer) {
        print("all users label tapped")
        self.sortType = .allUsers
        segueToNextViewController()
    }
    
    func segueToNextViewController() {
        // sets the graphical view controller with the storyboard ID askReviewsTableViewController to nextVC
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "compareReviewsTableViewController") as! CompareReviewsTableViewController
        
        // sends this VC's container over to the next one
        //print("The container to be passed has a row type of: \(container?.question.rowType)")
        nextVC.sortType = self.sortType
        nextVC.container = self.container
        print("sortType being sent to next VC is: \(self.sortType)")
        //print("The container that was passed has a row type of: \(nextVC.container?.question.rowType)")
        // pushes askBreakdownViewController onto the nav stack
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    
    
    
}
