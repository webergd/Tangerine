//
//  DetailViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/12/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit



class AskViewController: UIViewController, UIScrollViewDelegate {
    
    
    @IBOutlet weak var askRatingLabel: UILabel!
    @IBOutlet weak var askImageView: UIImageView!
    @IBOutlet weak var askTimeRemainingLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var askCaptionTextField: UITextField!
    @IBOutlet weak var askCaptionTopConstraint: NSLayoutConstraint!
    @IBOutlet var askView: UIView!

    
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
            
            // unwraps the ratingLabel from the IBOutlet
            if let thisLabel = self.askRatingLabel {
                
                
                if thisAsk.askRating > -1 {
                    //thisLabel.font.fontWithSize(50)
                    thisLabel.text = "\(thisAsk.askRating.roundToPlaces(1))"
                } else {
                    //thisLabel.font.fontWithSize(20)
                    thisLabel.text = "No Votes Yet"
                }
                
                
                
                //thisLabel.text = "\(thisAsk.askRating.roundToPlaces(1))"
            }
            // unwraps the imageView from the IBOutlet
            if let thisImageView = self.askImageView {
                thisImageView.image = thisAsk.askPhoto
            }
            // unwraps the timeRemaining from the IBOutlet
            if let thisTimeRemaining = self.askTimeRemainingLabel {
                thisTimeRemaining.text = "\(thisAsk.timeRemaining)"
            }
            
            if let thisCaptionTextField = self.askCaptionTextField {
                thisCaptionTextField.isHidden = !thisAsk.askCaption.exists
                thisCaptionTextField.text = thisAsk.askCaption.text
            }
            
            if let thisCaptionTopConstraint = self.askCaptionTopConstraint {
                thisCaptionTopConstraint.constant = askImageView.frame.height * thisAsk.askCaption.yLocation
            }

            
        } else {
            print("Looks like ask is nil")
        }

            
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
                self.navigationController?.popViewController(animated: true)
            } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.left {
                // sets the graphical view controller with the storyboard ID" comparePreviewViewController to nextVC
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "askBreakdownViewController") as! AskBreakdownViewController
                // pushes askBreakdownViewController onto the nav stack
                nextVC.container = self.container
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! AskBreakdownViewController
        // Pass the selected object to the new view controller:
        controller.container = self.container
    }
    
    
    
    
    
}

