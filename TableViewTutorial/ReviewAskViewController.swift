//
//  ReviewAskViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 6/28/17.
//  Copyright © 2017 Freedom Electric. All rights reserved.
//



import UIKit

class ReviewAskViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var askCaptionTextField: UITextField!
    @IBOutlet weak var askCaptionTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var strongButton: UIButton!
    @IBOutlet weak var commentsTextView: UITextView!
    
    
    
    @IBOutlet weak var lockedContainersLabel: UILabel!
    @IBOutlet weak var obligatoryReviewsRemainingLabel: UILabel!
    

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var ask: Ask? {
        didSet{
            self.configureView()
        }
    }
    
    let enterCommentConstant: String = "Enter optional comments here."
    
    func configureView() {
        print("configuring ReviewAsk view")
        
        // unwraps the Ask that the tableView sent over:
        if let thisAsk = ask {
            
            if let thisImageView = self.imageView,
                let thisCaptionTextField = self.askCaptionTextField,
                let thisCaptionTopConstraint = self.askCaptionTopConstraint,
                let thisLockedContainersLabel = self.lockedContainersLabel,
                let thisObligatoryReviewsRemainingLabel = self.obligatoryReviewsRemainingLabel {
                
                thisImageView.image = thisAsk.askPhoto

                thisCaptionTextField.isHidden = !thisAsk.askCaption.exists
                thisCaptionTextField.text = thisAsk.askCaption.text
                thisCaptionTopConstraint.constant = thisImageView.frame.height * thisAsk.askCaption.yLocation

                thisLockedContainersLabel.text = "🗝" + String(describing: lockedContainers.count)
                thisObligatoryReviewsRemainingLabel.text = "📋" + String(describing: obligatoryReviewsRemaining)

            }

        } else {
            print("Passed friend is nil")
        }
        
        resetTextView(textView: commentsTextView, blankText: enterCommentConstant)
            
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // first check and see if it's not an ask
        if assignedQuestions[0].type == .compare {
            //segue to CompareAsk
            // CODE NEEDED
        }
        
        ask = assignedQuestions[0] as! Ask
        // The above line causes configureView to be called.
        
        // This makes the text view have rounded corners.
        commentsTextView.clipsToBounds = true
        commentsTextView.layer.cornerRadius = 10.0
        
        // Do any additional setup after loading the view, typically from a nib.
        scrollView.delegate = self

        
        //let swipeViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(AskViewController.userSwiped))
        //askView.addGestureRecognizer(swipeViewGesture)
        
        
        // Gesture Recognizers for swiping left and right
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(FriendDetailsViewController.userSwiped))
        self.view.addGestureRecognizer(swipeRight) // right is the default so no if logic required later
        

        
    }
    
    // KEYBOARD METHODS:
    
    // This is called in the viewDidLoad section in our NSNotificationCenter command
    func keyboardWillShow(_ notification: Notification) {
        // Basically all this shit is for moving the caption out of the way of the keyboard while we're editing it:
        //if self.commentsTextView.isEditing == true { //aka if the title is editing, don't do any of this
            //get the height of the keyboard that will show and then shift the text field up by that amount
            if let userInfoDict = notification.userInfo,
                let keyboardFrameValue = userInfoDict [UIKeyboardFrameEndUserInfoKey] as? NSValue {
                
                let keyboardFrame = keyboardFrameValue.cgRectValue
                
                //this makes the text box movement animated so it looks smoother:
                UIView.animate(withDuration: 0.8, animations: {
                    // Save the captionTextField's Location so we can restore it after editing:
                    // Ensures that the saved captionYValue will be within the top and bottom limit.
                    
                    
                    //self.captionYValue = self.vetCaptionTopConstraint(self.captionTextFieldTopConstraint.constant)
                    
                    
                    self.captionYValue = self.captionTextFieldTopConstraint.constant
                    
                    
                    
                    //self.captionTextFieldBottomConstraint.constant = keyboardFrame.size.height
                    self.captionTextFieldTopConstraint.constant = self.screenHeight - keyboardFrame.size.height - self.topLayoutGuide.length - self.captionTextFieldHeight
                    self.view.layoutIfNeeded()
                })
                
            }
        //}
    }
    
    func keyboardWillHide(_ notification: Notification) {
        //get the height of the keyboard that will show and then shift the text field down by that amount
        
        if self.captionTextField.text == "" {
            self.captionTextField.isHidden = true
            mirrorCaptionButton.isHidden = true
            centerFlexibleSpace.isEnabled = false
        }
        
        //this makes the text box movement animated so it looks smoother:
        UIView.animate(withDuration: 1.0, animations: {
            //moves the caption back to its original location:
            self.captionTextFieldTopConstraint.constant = self.vetCaptionTopConstraint(self.captionYValue)
            
            
        })
        // If the user has entered no text in the titleTextField, reset it to how it was originally:
        if self.titleTextField.text == "" {
            self.titleTextField.text = enterTitleConstant
            self.titleTextField.textColor = UIColor.gray
            self.titleHasBeenTapped = false
            
            if captionTextField.text != "" {
                mirrorCaptionButton.isHidden = false
                centerFlexibleSpace.isEnabled = true
            }
        } else if titleTextField.text != enterTitleConstant  {
            mirrorCaptionButton.isHidden = true
            centerFlexibleSpace.isEnabled = false
        }
        self.view.layoutIfNeeded()
        
        //This is here because the title was somehow getting lost between it displaying correctly in the text field, and the publish button being tapped.
        print("titleTextField value at the end of hiding the keyboard is: \(titleTextField.text!)")
        
    }
    
    // This dismisses the keyboard when the user clicks the DONE button on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // I'm pretty sure I already have this functionality in datamodels
    func resetTitleTextField() {
        self.titleTextField.text = enterTitleConstant
        self.titleTextField.textColor = UIColor.gray
        currentTitle = ""
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // END KEYBOARD METHODS
    
    // Allows the user to zoom within the scrollView that the user is manipulating at the time.
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.setZoomScale(1.0, animated: true)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func reportContentButtonTapped(_ sender: Any) {
    }
    
    
    
    @IBAction func menuButtonTapped(_ sender: Any) {
    }
    

    // I need a way to switch between the two Review Controllers without
    //  stacking up multiple instances of them on top of each other.
    
    func userSwiped(gesture: UIGestureRecognizer) {
        //if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            // go back to previous view by swiping right
            self.navigationController?.popViewController(animated: true)
        //}
        
    } //end of userSwiped


    
    
}
 


