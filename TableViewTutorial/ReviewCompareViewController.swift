//
//  ReviewAskViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 6/28/17.
//  Copyright © 2017 Freedom Electric. All rights reserved.
//



import UIKit
//import QuartzCore // I only did this to try and show rounded corners in interface builder

class ReviewCompareViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate {
    
    // TopView's outlets:
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topScrollView: UIScrollView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var topCaptionTextField: UITextField!
    @IBOutlet weak var topCaptionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSelectionImageView: UIImageView!

    // BottomView's outlets:
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var bottomImageView: UIImageView!
    @IBOutlet weak var bottomCaptionTextField: UITextField!
    @IBOutlet weak var bottomCaptionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSelectionImageView: UIImageView!
    
    
    
    @IBOutlet weak var commentsTextViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentsTextView: UITextView!
    
    
    @IBOutlet weak var lockedContainersLabel: UILabel!
    @IBOutlet weak var obligatoryReviewsRemainingLabel: UILabel!

    
    
    
    
    // Link the background views to the code so we can crop them into circles:
    @IBOutlet weak var topLeftBackgroundView: UIView!
    @IBOutlet weak var topCenterBackgroundView: UIView!
    @IBOutlet weak var topRightBackgroundView: UIView!
    @IBOutlet weak var bottomRightBackgroundView: UIView!
    @IBOutlet weak var bottomCenterBackgroundView: UIView!
    @IBOutlet weak var bottomLeftBackgroundView: UIView!

    

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var ask: Ask? {
        didSet{
            print("ask value changed")
            self.configureView()
        }
    }
    
    var strongFlag: Bool = false
    
    let enterCommentConstant: String = "Enter optional comments here."
    var strongOriginalSize: CGFloat = 70.0 // this is a placeholder value, updated in viewDidLoad()
    
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
        
        makeCircle(view: topLeftBackgroundView)
        makeCircle(view: topCenterBackgroundView)
        makeCircle(view: topRightBackgroundView)
        makeCircle(view: bottomRightBackgroundView)
        makeCircle(view: bottomCenterBackgroundView)
        makeCircle(view: bottomLeftBackgroundView)


        
        
        strongOriginalSize = strongImageView.frame.size.height
        // first check and see if it's not an ask
        if assignedQuestions[0].type == .compare {
            //segue to CompareAsk
            // CODE NEEDED
        }
        
        commentsTextView.translatesAutoresizingMaskIntoConstraints = false
        
        ask = assignedQuestions[0] as? Ask
        // The above line causes configureView to be called.
        
        
        
        // This makes the text view have rounded corners.
        commentsTextView.clipsToBounds = true
        commentsTextView.layer.cornerRadius = 10.0
        commentsTextView.delegate = self
        setTextViewYPosition()
        
        // Hides keyboard when user taps outside of text view
        self.hideKeyboardWhenTappedAround()
        
        // This will move the caption text box out of the way when the keyboard pops up:
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // This will move the caption text box back down when the keyboard goes away:
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
        scrollView.delegate = self

        
        //let swipeViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(AskViewController.userSwiped))
        //askView.addGestureRecognizer(swipeViewGesture)
        
        
        // Gesture Recognizers for swiping left and right
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(ReviewAskViewController.userSwiped))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(ReviewAskViewController.userSwiped))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ReviewAskViewController.userSwiped))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ReviewAskViewController.userSwiped))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)

    }
    

    @IBAction func commentButtonTapped(_ sender: Any) {
        displayTextView()
    }

    
    
    // KEYBOARD METHODS:

    // Write a method here to display the comment text View:
    func displayTextView() {
        if let superView = commentsTextView.superview {
            superView.bringSubview(toFront: commentsTextView)
        }
        // Need to manually show the keyboard, as well as ensure keyboard doesn't overlap the textView
    }
    
    
    
    
    
    
    
    // There is a decent amount of this in viewDidLoad() also
    func keyboardWillShow(_ notification: Notification) {
        // Basically all this is for moving the textView out of the way of the keyboard while we're editing it:
        
        self.commentsTextView.textColor = UIColor.black
        
        if self.commentsTextView.text == enterCommentConstant {
            self.commentsTextView.text = ""
        }
        
        //get the height of the keyboard that will show and then shift the text field up by that amount
        if let userInfoDict = notification.userInfo,
            let keyboardFrameValue = userInfoDict [UIKeyboardFrameEndUserInfoKey] as? NSValue {
                
            let keyboardFrame = keyboardFrameValue.cgRectValue
                
            //this makes the text box movement animated so it looks smoother:
            UIView.animate(withDuration: 0.8, animations: {

                self.textViewTopConstraint.constant = UIScreen.main.bounds.height - keyboardFrame.size.height - self.topLayoutGuide.length - self.commentsTextView.frame.size.height
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        //this makes the text box movement animated so it looks smoother:
        UIView.animate(withDuration: 1.0, animations: {
            //moves the textView back to its original location:
            self.setTextViewYPosition()
            
        })
        // If the user has entered no text in the titleTextField, reset it to how it was originally:
        if self.commentsTextView.text == "" {
            
            resetTextView(textView: commentsTextView, blankText: enterCommentConstant)
 
        }
        self.view.layoutIfNeeded()
    }
    
    // This dismisses the keyboard when the user clicks the DONE button on the keyboard
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }

    // END KEYBOARD METHODS

    
    func setTextViewYPosition() {
        // This positions the textView correctly so that it's not covering up the image (or too low):
        textViewTopConstraint.constant = helperView.frame.size.height * 1.1
    }
    
    func createReview(selection: yesOrNo) {
        var strong: yesOrNo? = nil
        if strongFlag == true { strong = selection }
        let createdReview: AskReview = AskReview(selection: selection, strong: strong, comments: commentsTextView.text)
        // normally we would then send this review up to the server.
        // Instead, for the sake of testing, we will add it to the user's reviews
        // I'm thinking I will need to create a dictionary of the containers and containerID's so that we can look up the container and attach the new review to its reviewCollection.
        if let thisAsk = ask {

            // Figures out which array the userID is at, then returns the element at that index in the usersArray.
            // In other words, it returns that user; not a copy, the actual user.
            // This will need to be changed to get the user in the database once I'm using that.
            
            // This is basically what is happening here:
            //  1. look up the user's id name in the usersArray,
            //  2. look up the container number in that user's containerCollection,
            //  3. append the new askReview to the container's review collection.
            
            print("length of usersArray is: \(usersArray.count)")
            print("indexOfUser returned: \(indexOfUser(in: usersArray, userID: thisAsk.containerID.userID))")
            print("length of containerCollection: \(usersArray[indexOfUser(in: usersArray, userID: thisAsk.containerID.userID)].containerCollection.count)")
            print("index of container collection to replace \(thisAsk.containerID.containerNumber)")
            
            usersArray[indexOfUser(in: usersArray, userID: thisAsk.containerID.userID)].containerCollection[thisAsk.containerID.containerNumber].reviewCollection.reviews.append(createdReview)

        } else {
            print("Fatal Error:")
            print("The ask was null when trying to access it in the createReview() method")
            fatalError() // crash the app deliberately
        }

        //someUser.containerCollection[containerNumber].reviewCollection.reviews.append(createdReview)
        print("new review created.")
        loadNextReview()

    } // end of createReview
    
    func loadNextReview() {
        assignedQuestions.removeFirst()
        if assignedQuestions[0].type == .compare {
            // need code to segue to CompareReviewVC without stacking it
            print("segue to CompareReviewViewController")
        }
        ask = assignedQuestions[0] as? Ask
        // MARK: Also need code to pull a new review from the database 
        //  and maintain the proper length of assignedReviews
    }
    
    // we also will need a userTapped() method
    
    func userSwiped(gesture: UIGestureRecognizer) {
        //This will need to be ammended since we are no longer swiping left or right
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            var currentSelection: yesOrNo
            if swipeGesture.direction == UISwipeGestureRecognizerDirection.up {
                // show the strong arm and set a strong flag to true
                strongFlag = true
                showStrongImage()
                return // this avoids reloading the form or a segue since it was just an up-swipe
            } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.down {
                strongFlag = true
                hideStrongImage()
                return // this avoids reloading the form or a segue since it was just an down-swipe
            } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.right {
                currentSelection = .yes
            } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.left {
                currentSelection = .no
            } else {
                print("no selection made from the swipe")
            return
            }
            self.showSwipeImage(selection: currentSelection)
        }

        
    } //end of userSwiped
    
    // Makes the view that's passed in into a circle
    func makeCircle(view: UIView){
        view.layer.cornerRadius = self.view.frame.size.height / 2
        view.layer.masksToBounds = true
        view.alpha = 0.6 // this isn't technically required to make it into a circle but it's more efficient to have this command here rather than doing it in interface builder
        
    }

    func showStrongImage() {
        ////
        // Here we will manipulate the strong center background image instead of the imageView
        ////
        
        // We may just want to fade it in instead of changing the size
        
        self.strongImageView.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.strongImageView.frame.size.height = self.strongOriginalSize * 2.0
            self.strongImageView.frame.size.width = self.strongOriginalSize * 2.0
            // I could also try to animate a change in the alpha instead to let it fade in
            // I'm pretty sure that will work.
        }, completion: {
            finished in
            
        })
        self.strongImageView.frame.size.height = self.strongOriginalSize
        self.strongImageView.frame.size.width = self.strongOriginalSize
    } // end of showStrongImage
    
    
    func hideStrongImage() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.strongImageView.frame.size.height = self.strongOriginalSize * 0.0001
            self.strongImageView.frame.size.width = self.strongOriginalSize * 0.0001
            //self.strongImageView.isHidden = true
            // I could also try to animate a change in the alpha instead to let it fade in
            // I'm pretty sure that will work.
        }, completion: {
            finished in
            self.strongImageView.isHidden = true
        })
        

        
    } // end of hideStrongImage()
    
    
    
    
    
    
    
    func showSwipeImage(selection: yesOrNo) {
 
        // If the user swiped up, the muscle emoji should already be set and the image will display
        // Actually this whole method could be rewritten with that in mind.
        
        switch selection {
        case .yes:
            // display yes image on screen
            self.selectionImageView.image = #imageLiteral(resourceName: "greencheck")
        case .no:
            //display no image on screen
            self.selectionImageView.image = #imageLiteral(resourceName: "redX")
        }
        self.selectionImageView.alpha = 0.9
        self.selectionImageView.isHidden = false
        
        // delays specified number of seconds before executing code in the brackets:
        UIView.animate(withDuration: 0.5, delay: 0.3, options: UIViewAnimationOptions.allowAnimatedContent, animations: {self.selectionImageView.alpha = 0.0}, completion: { finished in
            self.selectionImageView.isHidden = true
            self.createReview(selection: selection)
        })

    }
    
    

    
    // Allows the user to zoom within the scrollView that the user is manipulating at the time.
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        // I think I'll need an if statement here to choose which scrollView to manipulate. Put it alongside other CompareVC's to see how I did it before.
        
        return self.imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.setZoomScale(1.0, animated: true)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func reportButtonTapped(_ sender: Any) {
        //pop up a menu and find out what kind of report the user wants
        print("report content button tapped")
        // we pass the processReport function here so that the system will wait for the alert controller input before continuing on:
        let thisReportType: reportType = askForReportType(viewController: self, function: processReport)

        let thisReport: Report = Report(type: thisReportType)
        
        
        if let thisAsk = ask {
            
            // this will need to be changed to a database update later
            usersArray[indexOfUser(in: usersArray, userID: thisAsk.containerID.userID)].containerCollection[thisAsk.containerID.containerNumber].reportsCollection.append(thisReport)
            
        } else {
            print("Fatal Error:")
            print("The ask was null when trying to access it in the createReview() method")
            fatalError() // crash the app deliberately
        }

    }
    
    func processReport() {
        self.selectionImageView.image = #imageLiteral(resourceName: "redexclamation")
        self.selectionImageView.alpha = 0.9
        self.selectionImageView.isHidden = false
        // delays specified number of seconds before executing code in the brackets:
        UIView.animate(withDuration: 0.5, delay: 0.3, options: UIViewAnimationOptions.allowAnimatedContent, animations: {self.selectionImageView.alpha = 0.0}, completion: { finished in
            self.selectionImageView.isHidden = true
            self.loadNextReview()
        })
    }
    
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        // This may need to be adjusted depending on how we segue between asks and compares
        self.navigationController?.popViewController(animated: true)
    }
    

    // I need a way to switch between the two Review Controllers without
    //  stacking up multiple instances of them on top of each other.

    
}
 


