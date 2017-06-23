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
        self.configureView()
        let swipeViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(AskReviewDetailsViewController.userSwiped))
        reviewDetailsView.addGestureRecognizer(swipeViewGesture)
    }
    
    // code still needed in AskReviewsTableViewController to pass these 3 properties upon segue
    
    var review: AskReview? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    var askPhoto: UIImage? {
        didSet{
            self.configureAskImageView()
        }
    }
    
    var askTitle: String? {
        didSet{
            self.configureTitleLabel()
        }
    }
    
    func configureView() {
        print("configuring ask view")
        
        // unwraps the ask that the tableView sent over:
        if let thisReview = self.review {

            if let reviewerImage = self.reviewerImageView,
                let nameLabel = self.reviewerNameLabel,
                let ageLabel = self.reviewerAgeLabel,
                let ratingLabel = self.reviewerRatingLabel,
                let selectionLabel = self.askSelectionLabel,
                let strongLabel = self.strongLabel,
                let commentsBodyLabel = self.commentsBodyLabel {
                
                reviewerImage.image = thisReview.reviewerInfo.profilePicture
                nameLabel.text = thisReview.reviewerName
                ageLabel.text = String(thisReview.reviewerAge)
                ratingLabel.text = String(round(thisReview.reviewerInfo.reviewerScore)) // this needs to be changed to show a tangerine for each 1-5 point
                selectionLabel.text = selectionToText(selection: thisReview.selection)
                strongLabel.text = strongToText(strong: thisReview.strong)
                commentsBodyLabel.text = thisReview.comments // this will probably need additional formatting so it looks right
                

            }

            if let thisLabel = self.reviewerNameLabel {
                thisLabel.text = thisReview.reviewerName
            }

            
        } else {
            print("Looks like ask is nil")
        }
        
    }
    
    func configureAskImageView() {
        if let thisImageView = self.reviewerImageView,
            let thisAskPhoto = self.askPhoto{
            
            thisImageView.image = thisAskPhoto
        }
    }
    
    func configureTitleLabel() {
        if let thisLabel = self.askTitleLabel,
            let thisAskTitle = self.askTitle {
            
            thisLabel.text = thisAskTitle
        }
    }
    
    
    
    
    
    
    // MARK: Need to store values to IBOutlet Labels!
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userSwiped() {
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


