//
//  DetailViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/12/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit



class AskViewController: UIViewController, UIScrollViewDelegate {
    
    

    @IBOutlet weak var askImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var askCaptionTextField: UITextField!
    @IBOutlet weak var askCaptionTopConstraint: NSLayoutConstraint!
    @IBOutlet var askView: UIView!
    @IBOutlet weak var askTimeRemainingLabel: UILabel!
    
    // TARGET DEMO OUTLETS
    @IBOutlet weak var targetDemoTotalReviewsLabel: UILabel!
    @IBOutlet weak var targetDemoYesPercentage: UILabel!
    @IBOutlet weak var targetDemoStrongYesPercentage: UILabel!
    @IBOutlet weak var targetDemo100Bar: UIView! // use this to pull the current width of the 100Bar
    @IBOutlet weak var targetDemoBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var targetDemoStrongBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var targetDemoYesLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var targetDemoStrongLabelTrailingConstraint: NSLayoutConstraint!
    
    
    // FRIENDS OUTLETS
    @IBOutlet weak var friendsTotalReviewsLabel: UILabel!
    @IBOutlet weak var friendsYesPercentage: UILabel!
    @IBOutlet weak var friendsStrongYesPercentage: UILabel!
    @IBOutlet weak var friends100Bar: UIView! // use this to pull the current width of the 100Bar
    @IBOutlet weak var friendsBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendsStrongBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendsYesLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendsStrongLabelTrailingConstraint: NSLayoutConstraint!
    
    
    

    // ALL REVIEWS OUTLETS
    @IBOutlet weak var allReviewsTotalReviewsLabel: UILabel!
    @IBOutlet weak var allReviewsYesPercentage: UILabel!
    @IBOutlet weak var allReviewsStrongYesPercentage: UILabel!
    @IBOutlet weak var allReviews100Bar: UIView! // use this to pull the current width of the 100Bar
    @IBOutlet weak var allReviewsBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var allReviewsStrongBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var allReviewsYesLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var allReviewsStrongLabelTrailingConstraint: NSLayoutConstraint!
 
    @IBOutlet weak var reviewsLabelWidthConstraint: UILabel!
    
    // OUTLETS TO USE LABELS AS BUTTONS
    @IBOutlet weak var targetDemoLabel: UILabel!
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var allReviewsLabel: UILabel!
    // For these to work, user interaction must be enabled in attributes inspector
    
    
    
    //@IBOutlet weak var detailDescriptionLabel: UILabel!
    
    //var detailText: String = ""
    //var ask: Ask = Ask(title: "blank", rating: 11, photo: UIImage(named: "defaultPhoto")! )
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    var container: Container? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var sortType: userGroup = .allUsers // this will be adjusted prior to segue if user taps specific area
    
    func configureView() {
        print("configuring ask view")
        
        // from this point until the end of the configureView method, "container" refers to the local unwrapped version of container
        guard let container = container else {
            print("container was nil")
            return
        }
        
        //print("first reviewer's username is: \(container.reviewCollection.reviews[0].reviewerName)")
        

        // unwraps the ask that the tableView sent over:
        if let thisAsk = self.container?.question as! Ask? {
            
            // unwraps the ratingLabel from the IBOutlet:
            /* if let thisLabel = self.askRatingLabel {
                if thisAsk.askRating > -1 {
                    //thisLabel.font.fontWithSize(50)
                    thisLabel.text = "\(thisAsk.askRating.roundToPlaces(1))"
                } else {
                    //thisLabel.font.fontWithSize(20)
                    thisLabel.text = "No Votes Yet"
                }
                //thisLabel.text = "\(thisAsk.askRating.roundToPlaces(1))"
            } 
            */
            
            if let thisLabel = self.titleLabel {
                thisLabel.text = thisAsk.askTitle
            }
            
            // unwraps the imageView from the IBOutlet
            if let thisImageView = self.askImageView {
                thisImageView.image = thisAsk.askPhoto
            }
            // unwraps the timeRemaining from the IBOutlet
            if let thisTimeRemaining = self.askTimeRemainingLabel {
                thisTimeRemaining.text = "TIME REMAINING: \(thisAsk.timeRemaining)"
            }
            
            if let thisCaptionTextField = self.askCaptionTextField {
                thisCaptionTextField.isHidden = !thisAsk.askCaption.exists
                thisCaptionTextField.text = thisAsk.askCaption.text
            }
            
            if let thisCaptionTopConstraint = self.askCaptionTopConstraint {
                thisCaptionTopConstraint.constant = askImageView.frame.height * thisAsk.askCaption.yLocation
            }
            
            // configure the target demo data display:
            print("configuring TARGET DEMO display **********")
            
            let targetDemoDataSet = pullConsolidatedData(from: container, filteredBy: .targetDemo) as! ConsolidatedAskDataSet
            
            //let targetDemoDataSet = self.container?.reviewCollection.pullConsolidatedAskData(from: myTargetDemo.minAge, to: myTargetDemo.maxAge, straightWomen: myTargetDemo.straightWomenPreferred, straightMen: myTargetDemo.straightMenPreferred, gayWomen: myTargetDemo.gayWomenPreferred, gayMen: myTargetDemo.gayMenPreferred, friendsOnly: false)
            
            
            if let thisTotalReviewsLabel = targetDemoTotalReviewsLabel, let thisYesPercentageLabel = targetDemoYesPercentage, let this100Bar = targetDemo100Bar, let thisStrongYesPercentageLabel = targetDemoStrongYesPercentage, let thisYesTrailingConstraint = targetDemoBarTrailingConstraint, let thisYesLabelLeadingConstraint = targetDemoYesLabelLeadingConstraint, let thisStrongYesTrailingConstraint = targetDemoStrongBarTrailingConstraint, let thisStrongYesLabelTrailingConstraint = targetDemoStrongLabelTrailingConstraint   {
                
                ///////////////////////////////////
                //     START HERE:
                //
                // Since we changed the displayData method, these errors should probably all just be
                //  commented out at first. We can change them later once we get the first heart tool
                //  working inside AskTableViewCell.
                // Once that works right. Let's fix the one in CompareTableViewCell and then work our way out from there.
                //
                ////////////////////////////////////
                
                
                
                
                
                displayData(dataSet: targetDemoDataSet,
                            totalReviewsLabel: thisTotalReviewsLabel,
                            yesPercentageLabel: thisYesPercentageLabel,
                            strongYesPercentageLabel: thisStrongYesPercentageLabel,
                            hundredBarView: this100Bar,
                            yesTrailingConstraint: thisYesTrailingConstraint,
                            yesLabelLeadingConstraint: thisYesLabelLeadingConstraint,
                            strongYesTrailingConstraint: thisStrongYesTrailingConstraint,
                            strongYesLabelTrailingConstraint: thisStrongYesLabelTrailingConstraint)
            }

            print("configuring FRIEND display **********")
            
            // configure the friend data display: (as of now without friend filtering this just shows all reviews)
            
            let friendsDataSet = pullConsolidatedData(from: container, filteredBy: .friends) as! ConsolidatedAskDataSet
            
            //let friendDataSet = self.container?.reviewCollection.pullConsolidatedAskData(from: 0, to: 100, straightWomen: true, straightMen: true, gayWomen: true, gayMen: true, friendsOnly: true) //friendsOnly value doesn't do anything yet - need to add this functionality to the pullConsolidatedAskData method

            
            if let thisTotalReviewsLabel = friendsTotalReviewsLabel, let thisYesPercentageLabel = friendsYesPercentage, let this100Bar = friends100Bar, let thisStrongYesPercentageLabel = friendsStrongYesPercentage, let thisYesTrailingConstraint = friendsBarTrailingConstraint, let thisYesLabelLeadingConstraint = friendsYesLabelLeadingConstraint, let thisStrongYesTrailingConstraint = friendsStrongBarTrailingConstraint, let thisStrongYesLabelTrailingConstraint = friendsStrongLabelTrailingConstraint   {
                
                displayData(dataSet: friendsDataSet,
                            totalReviewsLabel: thisTotalReviewsLabel,
                            yesPercentageLabel: thisYesPercentageLabel,
                            strongYesPercentageLabel: thisStrongYesPercentageLabel,
                            hundredBarView: this100Bar,
                            yesTrailingConstraint: thisYesTrailingConstraint,
                            yesLabelLeadingConstraint: thisYesLabelLeadingConstraint,
                            strongYesTrailingConstraint: thisStrongYesTrailingConstraint,
                            strongYesLabelTrailingConstraint: thisStrongYesLabelTrailingConstraint)
            }
            
            
            // configure the allReviews data display:
            
            print("configuring ALL REVIEWS display **********")
            
            let allReviewsDataSet = pullConsolidatedData(from: container, filteredBy: .allReviews) as! ConsolidatedAskDataSet
            
            
            //let allReviewsDataSet = self.container?.reviewCollection.pullConsolidatedAskData(from: 0, to: 100, straightWomen: true, straightMen: true, gayWomen: true, gayMen: true, friendsOnly: false) // the only difference between this and the above is the friendsOnly Bool setting
            
            // this multiple if-let is just unwrapping the outlets so we can jam them into the displayData method.
            if let thisTotalReviewsLabel = allReviewsTotalReviewsLabel, let thisYesPercentageLabel = allReviewsYesPercentage, let this100Bar = allReviews100Bar, let thisStrongYesPercentageLabel = allReviewsStrongYesPercentage, let thisYesTrailingConstraint = allReviewsBarTrailingConstraint, let thisYesLabelLeadingConstraint = allReviewsYesLabelLeadingConstraint, let thisStrongYesTrailingConstraint = allReviewsStrongBarTrailingConstraint, let thisStrongYesLabelTrailingConstraint = allReviewsStrongLabelTrailingConstraint {
                
                displayData(dataSet: allReviewsDataSet,
                            totalReviewsLabel: thisTotalReviewsLabel,
                            yesPercentageLabel: thisYesPercentageLabel,
                            strongYesPercentageLabel: thisStrongYesPercentageLabel,
                            hundredBarView: this100Bar,
                            yesTrailingConstraint: thisYesTrailingConstraint,
                            yesLabelLeadingConstraint: thisYesLabelLeadingConstraint,
                            strongYesTrailingConstraint: thisStrongYesTrailingConstraint,
                            strongYesLabelTrailingConstraint: thisStrongYesLabelTrailingConstraint)
            }

            
            
            // pull review data for the 3 bar graph displays and display it in the view controller
            
            // I need to create a consolidatedAskDataSet for each of the 3 reviewer types (TD, Friends, All)
            //  and then use the information in those data sets to populate the labels and bar graphs.
            // I'm not sure whether to write out the code for each of the 3 or if there's a way I can 
            //  run a loop and do each one, or have a functon that sets up each one.
            // Maybe a function that takes in the label and bar graph IBOutlets as arguments and automatically assigns new values to those arguments?
            // I'm unsure whether this will work based on scope. Inside a function, swift may not recognize
            //  the stored IBOutlets as the same ones I passed in. It may be different than the if let statements.
            //   ^^^^^^^^^^^^^^ I'm almost certain this works and is already functioning, just double check ^^^^^

            

            
        } else {
            print("Looks like ask is nil")
        }

            
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

 
 
        


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        scrollView.delegate = self
        self.configureView()
        
        //let swipeViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(AskViewController.userSwiped))
        //askView.addGestureRecognizer(swipeViewGesture)
        
        
        // Gesture Recognizers for swiping left and right
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(AskViewController.userSwiped))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(AskViewController.userSwiped))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        // Gesture recognizers for tapping sortType labels to filter reviews
        let tdTap = UITapGestureRecognizer(target: self, action: #selector(AskViewController.userTappedTargetDemographicLabel))
        targetDemoLabel.addGestureRecognizer(tdTap)
        
        let friendsTap = UITapGestureRecognizer(target: self, action: #selector(AskViewController.userTappedFriendsLabel))
        friendsLabel.addGestureRecognizer(friendsTap)
        
        let arTap = UITapGestureRecognizer(target: self, action: #selector(AskViewController.userTappedAllReviewsLabel))
        allReviewsLabel.addGestureRecognizer(arTap)
  
    }
    
    // Allows the user to zoom within the scrollView that the user is manipulating at the time.
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.askImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.setZoomScale(1.0, animated: true)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func userSwiped(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == UISwipeGestureRecognizerDirection.right {
                // go back to previous view by swiping right
                self.navigationController?.popViewController(animated: true)
            } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.left {
                sortType = .allUsers // on left swipe show all reviews (may want to change this to targetDemo instead)
                segueToNextViewController()
            }
        }
        
    } //end of userSwiped
    
    @objc func userTappedTargetDemographicLabel(sender: UITapGestureRecognizer) {
        print("td label tapped")
        self.sortType = .targetDemo
        segueToNextViewController()
    }
    
    @objc func userTappedFriendsLabel(sender: UITapGestureRecognizer) {
        print("friends label tapped")
        self.sortType = .friends
        segueToNextViewController()
    }
    
    @objc func userTappedAllReviewsLabel(sender: UITapGestureRecognizer) {
        print("all users label tapped")
        self.sortType = .allUsers
        segueToNextViewController()
    }
    
    func segueToNextViewController() {
        // sets the graphical view controller with the storyboard ID askReviewsTableViewController to nextVC
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "askReviewsTableViewController") as! AskReviewsTableViewController
        
        // sends this VC's container over to the next one
        //print("The container to be passed has a row type of: \(container?.question.rowType)")
        nextVC.sortType = self.sortType
        nextVC.container = self.container
        print("sortType being sent to next VC is: \(self.sortType)")
        //print("The container that was passed has a row type of: \(nextVC.container?.question.rowType)")
        // pushes askBreakdownViewController onto the nav stack
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    // This method never gets called:
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        print("prepare for segue called in AskViewController")
        let controller = segue.destination as! AskReviewsTableViewController
        // Pass the current container to the AskReviewsTableViewController:
        //print("The container to be passed has a row type of: \(String(describing: container?.question.type))")
        controller.container = self.container
        controller.sortType = self.sortType // tells the tableView which reviews to display
        
    }
    
    
    
    
    
}

