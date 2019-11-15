//
//  FriendDetailsViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 6/25/17.
//  Copyright © 2017 Freedom Electric. All rights reserved.
//

import UIKit

class FriendDetailsViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!

    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
   
    
    var friend: User? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    

    func configureView() {
        print("configuring friend view")
        

        // unwraps the friend that the tableView sent over:
        if let thisFriend = friend {

            if let thisUserImageView = self.userImageView,
                let thisNameLabel = self.nameLabel,
                let thisAgeLabel = self.ageLabel,
                let thisRatingLabel = self.ratingLabel,
                let thisReviewsLabel = self.reviewsLabel {
                
                thisUserImageView.image = returnProfilePic(image: thisFriend.publicInfo.profilePicture)
                
                thisNameLabel.text = thisFriend.publicInfo.displayName
                thisAgeLabel.text = String(thisFriend.publicInfo.age)
                thisRatingLabel.text = reviewerRatingToTangerines(rating: thisFriend.publicInfo.reviewerScore)
                thisReviewsLabel.text = String(thisFriend.publicInfo.reviewsRated) + " Total Reviews"


            }
            

            
        } else {
            print("Passed friend is nil")
        }

            
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        scrollView.delegate = self
        self.configureView()
        
        //let swipeViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(AskViewController.userSwiped))
        //askView.addGestureRecognizer(swipeViewGesture)
        
        
        // Gesture Recognizers for swiping left and right
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(FriendDetailsViewController.userSwiped))
        self.view.addGestureRecognizer(swipeRight) // right is the default so no if logic required later
        

        
    }
    
    // Allows the user to zoom within the scrollView that the user is manipulating at the time.
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.userImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.setZoomScale(1.0, animated: true)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func userSwiped(gesture: UIGestureRecognizer) {
        //if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            // go back to previous view by swiping right
            self.navigationController?.popViewController(animated: true)
        //}
        
    } //end of userSwiped


    
    
}

