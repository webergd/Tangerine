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
    

    @IBOutlet weak var targetDemoTotalReviewsLabel: UILabel!
    @IBOutlet weak var targetDemoYesPercentage: UILabel!
    @IBOutlet weak var targetDemoStrongYesPercentage: UILabel!
    @IBOutlet weak var targetDemo100Bar: UIView! // use this to pull the current width of the 100Bar
    @IBOutlet weak var targetDemoBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var targetDemoStrongBarTrailingConstraint: NSLayoutConstraint!

    
    
    @IBOutlet weak var friendsTotalReviewsLabel: UILabel!
    @IBOutlet weak var friendsYesPercentage: UILabel!
    @IBOutlet weak var friendsStrongYesPercentage: UILabel!
    @IBOutlet weak var friends100Bar: UIView! // use this to pull the current width of the 100Bar
    @IBOutlet weak var friendsBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendsStrongBarTrailingConstraint: NSLayoutConstraint!

    
    @IBOutlet weak var allReviewsTotalReviewsLabel: UILabel!
    @IBOutlet weak var allReviewsYesPercentage: UILabel!
    @IBOutlet weak var allReviewsStrongYesPercentage: UILabel!
    @IBOutlet weak var allReviews100Bar: UIView! // use this to pull the current width of the 100Bar
    @IBOutlet weak var allReviewsBarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var allReviewsStrongBarTrailingConstraint: NSLayoutConstraint!
 
 

    
    @IBOutlet weak var reviewsLabelWidthConstraint: UILabel!
    
    
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
    
    
    func configureView() {
        print("configuring ask view")
        

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
            
            
            let targetDemoDataSet = self.container?.reviewCollection.pullConsolidatedAskData(from: userDemoPreferences.minAge, to: userDemoPreferences.maxAge, straightWomen: userDemoPreferences.straightWomenPreferred, straightMen: userDemoPreferences.straightMenPreferred, gayWomen: userDemoPreferences.gayWomenPreferred, gayMen: userDemoPreferences.gayMenPreferred, friendsOnly: false)
            
            
            if let thisDataSet = targetDemoDataSet, let thisTotalReviewsLabel = targetDemoTotalReviewsLabel, let thisYesPercentageLabel = targetDemoYesPercentage, let this100Bar = targetDemo100Bar, let thisStrongYesPercentageLabel = targetDemoStrongYesPercentage, let thisYesTrailingConstraint = targetDemoBarTrailingConstraint, let thisStrongYesTrailingConstraint = targetDemoStrongBarTrailingConstraint   {
                displayData(dataSet: thisDataSet,
                            totalReviewsLabel: thisTotalReviewsLabel,
                            yesPercentageLabel: thisYesPercentageLabel,
                            strongYesPercentageLabel: thisStrongYesPercentageLabel,
                            hundredBarView: this100Bar,
                            yesTrailingConstraint: thisYesTrailingConstraint,
                            strongYesTrailingConstraint: thisStrongYesTrailingConstraint)
            }

            print("configuring FRIEND display **********")
            
            // configure the friend data display: (as of now without friend filtering this just shows all reviews)
            let friendDataSet = self.container?.reviewCollection.pullConsolidatedAskData(from: 0, to: 100, straightWomen: true, straightMen: true, gayWomen: true, gayMen: true, friendsOnly: true) //friendsOnly value doesn't do anything yet - need to add this functionality to the pullConsolidatedAskData method

            
            if let thisDataSet = friendDataSet, let thisTotalReviewsLabel = friendsTotalReviewsLabel, let thisYesPercentageLabel = friendsYesPercentage, let this100Bar = friends100Bar, let thisStrongYesPercentageLabel = friendsStrongYesPercentage, let thisYesTrailingConstraint = friendsBarTrailingConstraint, let thisStrongYesTrailingConstraint = friendsStrongBarTrailingConstraint   {
                displayData(dataSet: thisDataSet,
                            totalReviewsLabel: thisTotalReviewsLabel,
                            yesPercentageLabel: thisYesPercentageLabel,
                            strongYesPercentageLabel: thisStrongYesPercentageLabel,
                            hundredBarView: this100Bar,
                            yesTrailingConstraint: thisYesTrailingConstraint,
                            strongYesTrailingConstraint: thisStrongYesTrailingConstraint)
            }
            
            
            // configure the allReviews data display:
            
            print("configuring ALL REVIEWS display **********")
            
            let allReviewsDataSet = self.container?.reviewCollection.pullConsolidatedAskData(from: 0, to: 100, straightWomen: true, straightMen: true, gayWomen: true, gayMen: true, friendsOnly: false) // the only difference between this and the above is the friendsOnly Bool setting
            
            
            if let thisDataSet = allReviewsDataSet, let thisTotalReviewsLabel = allReviewsTotalReviewsLabel, let thisYesPercentageLabel = allReviewsYesPercentage, let this100Bar = allReviews100Bar, let thisStrongYesPercentageLabel = allReviewsStrongYesPercentage, let thisYesTrailingConstraint = allReviewsBarTrailingConstraint, let thisStrongYesTrailingConstraint = allReviewsStrongBarTrailingConstraint   {
                displayData(dataSet: thisDataSet,
                            totalReviewsLabel: thisTotalReviewsLabel,
                            yesPercentageLabel: thisYesPercentageLabel,
                            strongYesPercentageLabel: thisStrongYesPercentageLabel,
                            hundredBarView: this100Bar,
                            yesTrailingConstraint: thisYesTrailingConstraint,
                            strongYesTrailingConstraint: thisStrongYesTrailingConstraint)
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
    
    func displayData(dataSet: ConsolidatedAskDataSet, totalReviewsLabel: UILabel, yesPercentageLabel: UILabel, strongYesPercentageLabel: UILabel, hundredBarView: UIView, yesTrailingConstraint: NSLayoutConstraint, strongYesTrailingConstraint: NSLayoutConstraint){
        
        totalReviewsLabel.text = String(dataSet.numReviews)
        yesPercentageLabel.text = String(dataSet.percentYes) + "%"
        strongYesPercentageLabel.text = String(dataSet.percentStrongYes) + "%"
        
        print("strong yes percentage: \(dataSet.percentStrongYes)")
        
        let hundredBarWidth = hundredBarView.frame.size.width
        
        yesTrailingConstraint.constant = calcTrailingConstraint(percentYes: dataSet.percentYes, hundredBarWidth: hundredBarWidth)
        
        strongYesTrailingConstraint.constant = calcTrailingConstraint(percentYes: dataSet.percentStrongYes, hundredBarWidth: hundredBarWidth)
        
        
    }
    

 
 
    
    
    
    
    
    
        


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        scrollView.delegate = self
        self.configureView()
        
        //let swipeViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(AskViewController.userSwiped))
        //askView.addGestureRecognizer(swipeViewGesture)
        
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(AskViewController.userSwiped))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(AskViewController.userSwiped))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
        
        
        
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
    
    func userSwiped(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == UISwipeGestureRecognizerDirection.right {
                // go back to previous view by swiping right
                self.navigationController?.popViewController(animated: true)
            } /* /////////    uncomment this in order to regain left swipe nav capability:   ///////////
                        ///////////////////////////////////////////////////////////////////
                else if swipeGesture.direction == UISwipeGestureRecognizerDirection.left {
                // sets the graphical view controller with the storyboard ID" comparePreviewViewController to nextVC
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "askBreakdownViewController") as! AskBreakdownViewController
                // pushes askBreakdownViewController onto the nav stack
                nextVC.container = self.container
                self.navigationController?.pushViewController(nextVC, animated: true)
            } */
            
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! AskBreakdownViewController
        // Pass the selected object to the new view controller:
        controller.container = self.container
    }
    
    
    
    
    
}

