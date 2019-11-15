//
//  AskReviewDetailsViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 6/22/17.
//  Copyright © 2017 Freedom Electric. All rights reserved.
//

import UIKit

class AskReviewDetailsViewController: UIViewController, UINavigationControllerDelegate {

    // Outlets:
    @IBOutlet weak var reviewerImageView: UIImageView!
    @IBOutlet weak var reviewerAgeLabel: UILabel!
    @IBOutlet weak var reviewerRatingLabel: UILabel!
    @IBOutlet weak var reviewerNameLabel: UILabel!
    @IBOutlet weak var reviewerDemoLabel: UILabel!
    
    
    @IBOutlet weak var askImageView: UIImageView!
    @IBOutlet weak var askTitleLabel: UILabel!
    @IBOutlet weak var askSelectionLabel: UILabel!
    @IBOutlet weak var strongLabel: UILabel!
    
    @IBOutlet weak var commentsTitleLabel: UILabel!
    @IBOutlet weak var commentsBodyLabel: UILabel!
    
    @IBOutlet var reviewDetailsView: UIView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureReviewItems()
        self.configureAskItems()
        let swipeViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(AskReviewDetailsViewController.userSwiped))
        reviewDetailsView.addGestureRecognizer(swipeViewGesture)
    }
    
    // code still needed in AskReviewsTableViewController to pass these 2 properties upon segue
    
    
    // Sending over 1 review and the ask prevents us from having to send all reviews
    //  as would be the case if we sent the whole container.
    var review: AskReview? {
        didSet {
            // Update the view.
            self.configureReviewItems()
        }
    }
    
    var ask: Ask? {
        didSet{
            self.configureAskItems()
        }
    }
    
    
    func configureReviewItems() {
        print("configuring ask view")
        
        // unwraps the ask that the tableView sent over:
        if let thisReview = self.review {

            if let reviewerImage = self.reviewerImageView,
                let nameLabel = self.reviewerNameLabel,
                let ageLabel = self.reviewerAgeLabel,
                let demoLabel = self.reviewerDemoLabel,
                let ratingLabel = self.reviewerRatingLabel,
                let selectionLabel = self.askSelectionLabel,
                let strongLabel = self.strongLabel,
                let commentsBodyLabel = self.commentsBodyLabel {
                
                // MARK: Need an if statement so if user is not a friend, profile picture and name are hidden
                reviewerImage.image = returnProfilePic(image: thisReview.reviewerInfo.profilePicture)
                nameLabel.text = thisReview.reviewerName
                
                ageLabel.text = String(thisReview.reviewerAge)
                
                // MARK: Hide this label if user is a friend
                demoLabel.text = orientationToText(userDemo: thisReview.reviewerOrientation)
                demoLabel.textColor = orientationSpecificColor(userOrientation: thisReview.reviewerOrientation)
                
                ratingLabel.text = reviewerRatingToTangerines(rating: thisReview.reviewerInfo.reviewerScore)
                selectionLabel.text = selectionToText(selection: thisReview.selection)
                strongLabel.text = strongToText(strong: thisReview.strong)
                commentsBodyLabel.text = thisReview.comments // this will probably need additional formatting so it looks right

            }


        } else { // I probably don't need this else statement
            print("Looks like review is nil")
        }
        
    }
    
    func configureAskItems() {
        if let thisImageView = self.askImageView,
            let thisLabel = self.askTitleLabel,
            let thisAsk = self.ask {
            
            thisImageView.image = thisAsk.askPhoto
            thisLabel.text = thisAsk.askTitle
        }
    }
    
    
    

    // MARK: Need to store values to IBOutlet Labels!
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func userSwiped() {
        print("user swiped**********")
        self.navigationController?.popViewController(animated: true)
        
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}


