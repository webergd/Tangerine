//
//  ReviewAskViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 6/28/17.
//  Copyright © 2017 Freedom Electric. All rights reserved.
//



import UIKit

class ReviewAskViewController: UIViewController, UIScrollViewDelegate, UITextViewDelegate, isReviewVC {
    
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var coverViewLabel: UILabel!
    
    @IBOutlet weak var helperView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var askCaptionTextField: UITextField!
    @IBOutlet weak var askCaptionTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectionImageView: UIImageView!
    @IBOutlet weak var strongImageView: UIImageView!
    //@IBOutlet weak var strongImageView: UIImageView! // this was the old one in the upper right. Once it's all working, delete the imageView in IB
    @IBOutlet weak var textViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentsTextView: UITextView!
    
    // Background views. These are outlets so they can be cropped into circles.
    @IBOutlet weak var topLeftBackgroundView: UIView!
    @IBOutlet weak var topCenterBackgroundView: UIView!
    @IBOutlet weak var topRightBackgroundView: UIView!
    @IBOutlet weak var bottomRightBackgroundView: UIView!
    @IBOutlet weak var bottomLeftBackgroundView: UIView!
    
    @IBOutlet weak var centralDisplayLabel: UILabel!
    
    @IBOutlet weak var lockedContainersLabel: UILabel!
    @IBOutlet weak var obligatoryReviewsRemainingLabel: UILabel!

    
    
 // Need to get rid of the strongImageView and substitute that functionality with the new one I dropped in. The imageView inside Top Center
    
// Re attach the menu return and the report functionality to the new buttons I added in which are no longer in a toolBar
// Reattach the labels for reviews remaining and locked containers
// Make the holder views into circles
//Something is fucked up with the image not displaying - fix this
    // one clue into this is that the caption text field is displaying for some reason.
    
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
    let backgroundCirclesAlphaValue: CGFloat = 0.75
    var strongOriginalSize: CGFloat = 70.0 // this is a placeholder value, updated in viewDidLoad()
    
    func configureView() {
        print("configuring ReviewAsk view")
        strongFlag = false
        strongImageView.isHidden = true
        topCenterBackgroundView.isHidden = true

        
        // unwraps the Ask that the tableView sent over: ..what tableView? Is this an old comment from a different VC?
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

                thisLockedContainersLabel.text = "🗝" + String(describing: localMyUser.lockedContainers.count)
                thisObligatoryReviewsRemainingLabel.text = String(describing: obligatoryReviewsRemaining) + "📋"

            }

        } else {
            print("Passed ask is nil")
        }
        
        resetTextView(textView: commentsTextView, blankText: enterCommentConstant)
            
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // This allows user to tap coverView to segue to main menu (if we run out of quetions):
        let tapCoverViewGesture = UITapGestureRecognizer(target: self, action: #selector(ReviewAskViewController.userTappedCoverView(_:) ))
        coverView.addGestureRecognizer(tapCoverViewGesture)
        
        if assignedQuestions.count < 1 {
            informUserNoAvailableQuestions()
        } else {
            
            // setting this to false prevents a segue when the coverView is being displayed due to text editing
            tapCoverViewToSegue = false
            coverView.alpha = 0.85
            
            // make sure the coverView wasn't still displayed from a previous showing of this view:
            hide(coverView: coverView, mainView: mainView)

   
            // 6. If a user deletes a locked container, the containerID should also be removed from the locked containers list
            
            ////////////////////////////////////////////////
            //
            // START HERE:
            //
            // 
            // Rebuild the Ask and Compare TableView cells.
            // A big thing they need is a display bar for target demo (or maybe all reviews).
            // They also need a label that tells the user how many reviews they have to do to unlock the container.
            // It would be nice to give them a black background.
            // It would also be nice to give the locked cells a slightly lighter background.
            // Compare images - maybe I should decrease Alpha of the losing image
            //
            // I kind of like the idea of the data bars being as tall and wide as the whole cell.
            // We could put greyed out backgrounds for the labels so that we can still read them.
            //
            ////////////////////////////////////
 
        
            // first check and see if it's not an ask
            if assignedQuestions[0].type == .compare {
                segueToReviewCompareViewController()
            }
        
            makeCircle(view: topLeftBackgroundView, alpha: backgroundCirclesAlphaValue)
            makeCircle(view: topCenterBackgroundView, alpha: backgroundCirclesAlphaValue)
            makeCircle(view: topRightBackgroundView, alpha: backgroundCirclesAlphaValue)
            makeCircle(view: bottomRightBackgroundView, alpha: backgroundCirclesAlphaValue)
            makeCircle(view: bottomLeftBackgroundView, alpha: backgroundCirclesAlphaValue)
            
            //topCenterBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.01)
            
            //setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0.5
            
            strongOriginalSize = strongImageView.frame.size.height
        
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
            NotificationCenter.default.addObserver(self, selector: #selector(ReviewAskViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
            // This will move the caption text box back down when the keyboard goes away:
            NotificationCenter.default.addObserver(self, selector: #selector(ReviewAskViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
            // Do any additional setup after loading the view, typically from a nib.
            scrollView.delegate = self

        
            //let swipeViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(AskViewController.userSwiped))
            //askView.addGestureRecognizer(swipeViewGesture)
        
        
            // Gesture Recognizers for swiping left and right
            let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(ReviewAskViewController.userSwiped))
            swipeUp.direction = UISwipeGestureRecognizer.Direction.up
            self.view.addGestureRecognizer(swipeUp)
        
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(ReviewAskViewController.userSwiped))
            swipeDown.direction = UISwipeGestureRecognizer.Direction.down
            self.view.addGestureRecognizer(swipeDown)
        
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(ReviewAskViewController.userSwiped))
            swipeRight.direction = UISwipeGestureRecognizer.Direction.right
            self.view.addGestureRecognizer(swipeRight)
        
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(ReviewAskViewController.userSwiped))
            swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
            self.view.addGestureRecognizer(swipeLeft)
            

        }
    }
    
    // KEYBOARD METHODS:

    // There is a decent amount of this in viewDidLoad() also
    @objc func keyboardWillShow(_ notification: Notification) {
        // this would look better if we animated a fade in of the coverView (and a fade out lower down)
        coverView.isHidden = false
        mainView.bringSubviewToFront(coverView)
        mainView.bringSubviewToFront(commentsTextView)
        
        // Basically all this is for moving the textView out of the way of the keyboard while we're editing it:
        
        self.commentsTextView.textColor = UIColor.black
        
        if self.commentsTextView.text == enterCommentConstant {
            self.commentsTextView.text = ""
        }
        
        //get the height of the keyboard that will show and then shift the text field up by that amount
        if let userInfoDict = notification.userInfo,
            let keyboardFrameValue = userInfoDict [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                
            let keyboardFrame = keyboardFrameValue.cgRectValue
                
            //this makes the text box movement animated so it looks smoother:
            UIView.animate(withDuration: 0.8, animations: {

                self.textViewTopConstraint.constant = UIScreen.main.bounds.height - keyboardFrame.size.height - self.topLayoutGuide.length - self.commentsTextView.frame.size.height
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        //this makes the text box movement animated so it looks smoother:
        UIView.animate(withDuration: 1.0, animations: {
            //moves the textView back to its original location:
            self.setTextViewYPosition()
            
        })
        // If the user has entered no text in the titleTextField, reset it to how it was originally:
        if self.commentsTextView.text == "" {
            
            resetTextView(textView: commentsTextView, blankText: enterCommentConstant)
 
        }
        mainView.sendSubviewToBack(coverView)
        coverView.isHidden = true
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
        
        // unwrap the ask again to pull its containerID:
        
        if let thisAsk = ask {

            let createdReview: AskReview = AskReview(selection: selection, strong: strong, comments: commentsTextView.text, containerID: thisAsk.containerID)
            
            // Pretty sure this whole comment block no longer applies:
            
            // normally we would then send this review up to the server.
            // Instead, for the sake of testing, we will add it to the user's reviews
            // I'm thinking I will need to create a dictionary of the containers and containerID's so that we can look up the container and attach the new review to its reviewCollection.
        

                // Figures out which array the userID is at, then returns the element at that index in the usersArray.
                // In other words, it returns that user; not a copy, the actual user.
                // This will need to be changed to get the user in the database once I'm using that.
            
                // This is basically what is happening here:
                //  1. look up the user's id name in the usersArray,
                //  2. look up the container number in that user's containerCollection,
                //  3. append the new askReview to the container's review collection.
            
                //print("length of usersArray is: \(usersArray.count)")
                //print("indexOfUser returned: \(indexOfUser(in: usersArray, userID: thisAsk.containerID.userID))")
                //print("length of containerCollection: \(usersArray[indexOfUser(in: usersArray, userID: thisAsk.containerID.userID)].containerCollection.count)")
                //print("index of container collection to replace \(thisAsk.containerID.containerNumber)")
            
                //print("inside the usersArray, myUser's containerCollection length is: \(usersArray[indexOfUser(in: usersArray, userID: thisAsk.containerID.userID)].containerCollection.count)")
                //print("on its own, myUser's containerCollection length is: \(myUser.containerCollection.count)")
            
                //print("trying to modify the review collection of myUser's container at index: \(thisAsk.containerID.containerNumber)")
            
                //usersArray[indexOfUser(in: usersArray, userID: thisAsk.containerID.userID)].containerCollection[thisAsk.containerID.containerNumber].reviewCollection.reviews.append(createdReview)
            
            unuploadedReviews.append(createdReview)
            localMyUser.removeOneObligatoryReview()
            refreshUserProfile()
            refreshReviews()

        } else {
            print("Fatal Error:")
            print("The ask was null when trying to access it in the createReview() method")
            fatalError() // crash the app deliberately
        }

        //someUser.containerCollection[containerNumber].reviewCollection.reviews.append(createdReview)
        print("new review created.")
        loadNextQuestion()

    } // end of createReview
    
    func loadNextQuestion() {
        assignedQuestions.removeFirst()
        loadAssignedQuestions()
        
        if assignedQuestions.count < 1 {
            
            informUserNoAvailableQuestions()
            
        } else {
            if assignedQuestions[0].type == .compare {
                // need code to segue to CompareReviewVC without stacking it
                print("segue to ReviewCompareViewController")
                segueToReviewCompareViewController()
                return
            }
            ask = assignedQuestions[0] as? Ask
            // MARK: Also need code to pull a new review from the database
            //  and maintain the proper length of assignedReviews
        }
    }
    
    func informUserNoAvailableQuestions(){
        informUserNoQuestions(coverView: coverView, coverViewLabel: coverViewLabel, mainView: mainView, viewController: self)
    }
    
    
    @objc func userSwiped(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            var currentSelection: yesOrNo
            if swipeGesture.direction == UISwipeGestureRecognizer.Direction.up {
                // show the strong arm and set a strong flag to true
                switch strongFlag {
                case true: return
                case false:
                    strongFlag = true
                    showStrongImage()
                }
                
                /*
                strongFlag = true
                print("Strong Flag set to: \(strongFlag)")
                showStrongImage()
                print("Strong Image alpha = \(strongImageView.alpha)")
                */
                return // this avoids reloading the form or a segue since it was just an up-swipe
            } else if swipeGesture.direction == UISwipeGestureRecognizer.Direction.down {
                strongFlag = false
                hideStrongImage()
                return // this avoids reloading the form or a segue since it was just an down-swipe
            } else if swipeGesture.direction == UISwipeGestureRecognizer.Direction.right {
                currentSelection = .yes
            } else if swipeGesture.direction == UISwipeGestureRecognizer.Direction.left {
                currentSelection = .no
            } else {
                print("no selection made from the swipe")
            return
            }
            self.showSwipeImage(selection: currentSelection)
        }

    } //end of userSwiped
    
    
    
    func showStrongImage() {
        ////
        // Here we will manipulate the strong center background image instead of the imageView
        ////
        
        // We may just want to fade it in instead of changing the size
        self.topCenterBackgroundView.isHidden = false
        self.strongImageView.isHidden = false
        self.centralDisplayLabel.isHidden = true

        
        //self.strongImageView.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
            self.strongImageView.frame.size.height = self.strongOriginalSize * 2.0
            self.strongImageView.frame.size.width = self.strongOriginalSize * 2.0
            self.topCenterBackgroundView.alpha = 1.0
            // I could also try to animate a change in the alpha instead to let it fade in
            // I'm pretty sure that will work.
        }, completion: {
            finished in
            
        })
        self.strongImageView.frame.size.height = self.strongOriginalSize
        self.strongImageView.frame.size.width = self.strongOriginalSize
    } // end of showStrongImage
    
    
    func hideStrongImage() {
        self.centralDisplayLabel.isHidden = false
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
            self.strongImageView.frame.size.height = self.strongOriginalSize * 0.0001
            self.strongImageView.frame.size.width = self.strongOriginalSize * 0.0001
            self.topCenterBackgroundView.alpha = 0.0
            //self.strongImageView.isHidden = true
            // I could also try to animate a change in the alpha instead to let it fade in
            // I'm pretty sure that will work.
        }, completion: {
            finished in
            //self.strongImageView.isHidden = true
            self.topCenterBackgroundView.isHidden = true
        })
        
        
        
    } // end of hideStrongImage()
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    func showStrongImage() {
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
    */
    func showSwipeImage(selection: yesOrNo) {
        // It would be great to animate this or make it fade in and out
        
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
        UIView.animate(withDuration: 0.5, delay: 0.3,
            options: UIView.AnimationOptions.allowAnimatedContent,
            animations: {
                self.selectionImageView.alpha = 0.0
            },
            completion: {
                finished in
                self.selectionImageView.isHidden = true
                self.createReview(selection: selection)
        })

    }
    
    func segueToReviewCompareViewController() {
        // pop this VC off the stack
        //self.navigationController?.popViewController(animated: false)
        
        ////////////
        // ok this works when the above line is commented out but is there a way to push the next VC and then pop the next one below that in the background without the user seeing?
        

        ///////        /////////
        // Untested thus far: //
        ///////         ////////
        if let navController = self.navigationController {
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "reviewCompareViewController") as! ReviewCompareViewController
            //let newVC = DestinationViewController(nibName: "DestinationViewController", bundle: nil)
            
            var stack = navController.viewControllers
            stack.remove(at: stack.count - 1)       // remove current VC
            stack.insert(nextVC, at: stack.count) // add the new one
            navController.setViewControllers(stack, animated: false) // boom!
        }
        
        
        
        
        
        
        
        // then load the review compare VC onto the stack
        //let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "reviewCompareViewController") as! ReviewCompareViewController
        // pushes askBreakdownViewController onto the nav stack
        //self.navigationController?.pushViewController(nextVC, animated: false)
    }

    
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
    


    @IBAction func reportButtonTapped(_ sender: Any) {
    
        //pop up a menu and find out what kind of report the user wants
        print("report content button tapped")
        // we pass the processReport function here so that the system will wait for the alert controller input before continuing on:
        let thisReportType: reportType = askForReportType(viewController: self, function: processReport)
        
        if thisReportType == .cancel { return }

        
        
        
        if let thisAsk = ask {
            
            let thisReport: Report = Report(type: thisReportType, containerID: thisAsk.containerID)
            
            unuploadedReports.append(thisReport)
            refreshReports()
            
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
        UIView.animate(withDuration: 0.5, delay: 0.3, options: UIView.AnimationOptions.allowAnimatedContent, animations: {self.selectionImageView.alpha = 0.0}, completion: { finished in
            self.selectionImageView.isHidden = true
            self.loadNextQuestion()
        })
    }
    
  
    @IBAction func menuButtonTapped(_ sender: Any) {
        // This may need to be adjusted depending on how we segue between asks and compares
        returnToMainMenu()
    }
    
    @objc func userTappedCoverView(_ pressImageGesture: UITapGestureRecognizer){
        print("user tapped coverView")
        if tapCoverViewToSegue == true {
            returnToMainMenu()
        } else {
            commentsTextView.resignFirstResponder()
        }
    }
    
    func returnToMainMenu() {
        self.navigationController?.popViewController(animated: true)
    }
    // I need a way to switch between the two Review Controllers without
    //  stacking up multiple instances of them on top of each other.

    
}
 


