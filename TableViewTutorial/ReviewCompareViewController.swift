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
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var coverView: UIView!
    
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
    
    
    // commentsTextView outlets
    @IBOutlet weak var commentsTextViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentsTextView: UITextView!
    
    // Additional information labels and images outlets
    @IBOutlet weak var lockedContainersLabel: UILabel!
    @IBOutlet weak var strongImageView: UIImageView!
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
    
    var compare: Compare? {
        didSet{
            print("compare value changed")
            self.configureView()
        }
    }
    
    var strongFlag: Bool = false
    
    let enterCommentConstant: String = "Enter optional comments here."
    let backgroundCirclesAlphaValue: CGFloat = 0.75
    var strongOriginalSize: CGFloat = 70.0 // this is a placeholder value, updated in viewDidLoad()
    
    func configureView() {
        print("configuring ReviewAsk view")
        
        // unwraps the Ask that the tableView sent over:
        if let thisCompare = compare {
            
            // Load the top image:
            load(imageView: topImageView,
                 with: thisCompare.comparePhoto1,
                 within: topView,
                 caption: thisCompare.compareCaption1,
                 captionTextField: topCaptionTextField,
                 captionTopConstraint: topCaptionTopConstraint)
            
            // Load the bottom image:
            load(imageView: bottomImageView,
                 with: thisCompare.comparePhoto2,
                 within: bottomView,
                 caption: thisCompare.compareCaption2,
                 captionTextField: bottomCaptionTextField,
                 captionTopConstraint: bottomCaptionTopConstraint)
            
            
            if let thisLockedContainersLabel = self.lockedContainersLabel,
                let thisObligatoryReviewsRemainingLabel = self.obligatoryReviewsRemainingLabel {

                thisLockedContainersLabel.text = "🗝" + String(describing: lockedContainers.count)
                thisObligatoryReviewsRemainingLabel.text = String(describing: obligatoryReviewsRemaining) + "📋"

            }

        } else {
            print("Passed compare is nil")
        }
        
        resetTextView(textView: commentsTextView, blankText: enterCommentConstant)
            
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // first check and see if it's not a compare
        if assignedQuestions[0].type == .ask {
            segueToReviewAskViewController()
        }
        
        makeCircle(view: topLeftBackgroundView)
        makeCircle(view: topCenterBackgroundView)
        makeCircle(view: topRightBackgroundView)
        makeCircle(view: bottomRightBackgroundView)
        makeCircle(view: bottomCenterBackgroundView)
        makeCircle(view: bottomLeftBackgroundView)

        // we may or may not need this for ReviewCompareVC
        strongOriginalSize = strongImageView.frame.size.height
        
        commentsTextView.translatesAutoresizingMaskIntoConstraints = false
        
        compare = assignedQuestions[0] as? Compare
        // The above line causes configureView to be called.
        
        // This makes the text view have rounded corners.
        commentsTextView.clipsToBounds = true
        commentsTextView.layer.cornerRadius = 10.0
        commentsTextView.delegate = self
        //setTextViewYPosition()
        
        // Hides keyboard when user taps outside of text view
        self.hideKeyboardWhenTappedAround()
        
        // This will move the caption text box out of the way when the keyboard pops up:
        NotificationCenter.default.addObserver(self, selector: #selector(ReviewCompareViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // This will move the caption text box back down when the keyboard goes away:
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        

        topScrollView.delegate = self
        bottomScrollView.delegate = self

        
        //let swipeViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(AskViewController.userSwiped))
        //askView.addGestureRecognizer(swipeViewGesture)
        
        
        // Gesture Recognizers for swiping up and down
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(ReviewAskViewController.userSwiped))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view.addGestureRecognizer(swipeUp)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(ReviewAskViewController.userSwiped))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        
        // For tapping the images to select them:
        let tapTopImageGesture = UITapGestureRecognizer(target: self, action: #selector(ReviewCompareViewController.userTappedTop(_:) ))
        topImageView.addGestureRecognizer(tapTopImageGesture)
        
        let tapBottomImageGesture = UITapGestureRecognizer(target: self, action: #selector(ReviewCompareViewController.userTappedBottom(_:) ))
        bottomImageView.addGestureRecognizer(tapBottomImageGesture)

    }
    

    
    // Allows the user to zoom within the scrollView that the user is manipulating at the time.
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView == topScrollView {
            return self.topImageView
        } else {
            return self.bottomImageView
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        topScrollView.setZoomScale(1.0, animated: true)
        bottomScrollView.setZoomScale(1.0, animated: true)
    }
    

    @IBAction func commentButtonTapped(_ sender: Any) {
        displayTextView()
        commentsTextView.becomeFirstResponder() // This makes the keyboard pop up right away
    }

    
    
    // KEYBOARD METHODS:

    // Write a method here to display the comment text View:
    func displayTextView() {
        // this would look better if we animated a fade in of the coverView (and a fade out lower down)
        coverView.isHidden = false
        mainView.bringSubview(toFront: coverView)
        mainView.bringSubview(toFront: commentsTextView)

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

                self.commentsTextViewTopConstraint.constant = UIScreen.main.bounds.height - keyboardFrame.size.height - self.topLayoutGuide.length - self.commentsTextView.frame.size.height
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        //this makes the text box movement animated so it looks smoother:
        UIView.animate(withDuration: 1.0, animations: {
            //moves the textView back to its original location:
            //self.setTextViewYPosition()
            
        })
        // If the user has entered no text in the titleTextField, reset it to how it was originally:
        if self.commentsTextView.text == "" {
            
            resetTextView(textView: commentsTextView, blankText: enterCommentConstant)
 
        }
        mainView.sendSubview(toBack: commentsTextView)
        mainView.sendSubview(toBack: coverView)
        coverView.isHidden = true
        self.view.layoutIfNeeded()
    }
    
    // This dismisses the keyboard when the user clicks the DONE button on the keyboard
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }

    // END KEYBOARD METHODS

    
    // I don't think this is necessary for ReviewCompareVC
    /*
    func setTextViewYPosition() {
        // This positions the textView correctly so that it's not covering up the image (or too low):
        commentTextViewTopConstraint.constant = helperView.frame.size.height * 1.1
    }
    */
    
    func userTappedTop(_ pressImageGesture: UITapGestureRecognizer){
        print("user tapped top")
        self.showSelectionImage(selection: .top)
        //createReview(selection: .top)
    }
    
    func userTappedBottom(_ pressImageGesture: UITapGestureRecognizer){
        print("user tapped bottom")
        self.showSelectionImage(selection: .bottom)
        //createReview(selection: .bottom)
    }
    
    func createReview(selection: topOrBottom) {
        
        // this strongYes / strongNo logic will change if I implement strong no functionality (currently disabled)
        if commentsTextView.text == enterCommentConstant { commentsTextView.text = ""}
        let createdReview: CompareReview = CompareReview(selection: selection, strongYes: strongFlag, strongNo: false, comments: commentsTextView.text)
        
        // normally we would then send this review up to the server.
        // Instead, for the sake of testing, we will add it to the user's reviews

        if let thisCompare = compare {

            // Figures out which array the userID is at, then returns the element at that index in the usersArray.
            // In other words, it returns that user; not a copy, the actual user.
            // This will need to be changed to get the user in the database once I'm using that.
            
            // This is basically what is happening here:
            //  1. look up the user's id name in the usersArray,
            //  2. look up the container number in that user's containerCollection,
            //  3. append the new compareReview to the container's review collection.
            
            print("length of usersArray is: \(usersArray.count)")
            print("indexOfUser returned: \(indexOfUser(in: usersArray, userID: thisCompare.containerID.userID))")
            //print("length of containerCollection: \(usersArray[indexOfUser(in: usersArray, userID: thisCompare.containerID.userID)].containerCollection.count)")
            //print("index of container collection to replace \(thisCompare.containerID.containerNumber)")
            
            
            // Make sure we are creating a CompareReview:    //////
            print("about to append review to the review collection")
            usersArray[indexOfUser(in: usersArray, userID: thisCompare.containerID.userID)].containerCollection[thisCompare.containerID.containerNumber].reviewCollection.reviews.append(createdReview)

        } else {
            print("Fatal Error:")
            print("The compare was null when trying to access it in the createReview() method")
            fatalError() // crash the app deliberately
        }

        //someUser.containerCollection[containerNumber].reviewCollection.reviews.append(createdReview)
        print("new review created.")

        
        
        loadNextQuestion()

    } // end of createReview
    
    func loadNextQuestion() {
        
        assignedQuestions.removeFirst()
        
        // UNCOMMENT THIS WHEN IMPLEMENTING SEGUE FUNCTIONALITY:
        
        if assignedQuestions[0].type == .ask {
            // need code to segue to CompareReviewVC without stacking it
            print("segue to ReviewAskViewController")
            segueToReviewAskViewController()

        }
        
        compare = assignedQuestions[0] as? Compare
        // MARK: Also need code to pull a new review from the database 
        //  and maintain the proper length of assignedReviews
    }

    
    
    func userSwiped(gesture: UIGestureRecognizer) {
        //This will need to be ammended since we are no longer swiping left or right
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == UISwipeGestureRecognizerDirection.up {
                // show the strong arm and set a strong flag to true
                switch strongFlag {
                case true: return
                case false:
                    strongFlag = true
                    showStrongImage()
                }
                return // this avoids reloading the form or a segue since it was just an up-swipe
            } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.down {
                strongFlag = false
                hideStrongImage()
                return // this avoids reloading the form or a segue since it was just an down-swipe
            /*
            } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.right {
                currentSelection = .top
            } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.left {
                currentSelection = .bottom
            */
            } else {
                print("no selection made from the swipe")
            return
            }
            

        }

        
    } //end of userSwiped
    
    // Makes the view that's passed in into a circle
    func makeCircle(view: UIView){
        view.layer.cornerRadius = view.frame.size.height / 2
        view.layer.masksToBounds = true
        view.alpha = backgroundCirclesAlphaValue // this isn't technically required to make it into a circle but it's more efficient to have this command here rather than doing it in interface builder
        
    }

    func showStrongImage() {
        ////
        // Here we will manipulate the strong center background image instead of the imageView
        ////
        
        // We may just want to fade it in instead of changing the size
        self.topCenterBackgroundView.isHidden = false
        
        //self.strongImageView.isHidden = false
        UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
            self.strongImageView.frame.size.height = self.strongOriginalSize * 2.0
            self.strongImageView.frame.size.width = self.strongOriginalSize * 2.0
            self.topCenterBackgroundView.alpha = self.backgroundCirclesAlphaValue
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

    func showSelectionImage(selection: topOrBottom) {
        switch selection {
        case .top:
            self.topSelectionImageView.image = #imageLiteral(resourceName: "greencheck")
            self.topSelectionImageView.alpha = 1.0
            self.bottomSelectionImageView.image = #imageLiteral(resourceName: "redX")
            self.bottomSelectionImageView.alpha = 0.5
        case .bottom:
            self.topSelectionImageView.image = #imageLiteral(resourceName: "redX")
            self.topSelectionImageView.alpha = 0.5
            self.bottomSelectionImageView.image = #imageLiteral(resourceName: "greencheck")
            self.bottomSelectionImageView.alpha = 1.0
        }
        
        self.topSelectionImageView.isHidden = false
        self.bottomSelectionImageView.isHidden = false
        
        // delays specified number of seconds before executing code in the brackets:
        UIView.animate(withDuration: 0.5, delay: 0.3,
                       options: UIViewAnimationOptions.allowAnimatedContent,
                       animations: {
                        self.topSelectionImageView.alpha = 0.0
                        self.bottomSelectionImageView.alpha = 0.0
                        },
                       completion: { finished in
                        self.topSelectionImageView.isHidden = true
                        self.bottomSelectionImageView.isHidden = true
                        self.createReview(selection: selection)
                        }
        )

    } // end showSelectionImage()

    func segueToReviewAskViewController() {
        ///////        /////////
        // Untested thus far: //
        ///////         ////////
        if let navController = self.navigationController {
        let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "reviewAskViewController") as! ReviewAskViewController
        //let newVC = DestinationViewController(nibName: "DestinationViewController", bundle: nil)
    
        var stack = navController.viewControllers
        stack.remove(at: stack.count - 1)       // remove current VC
        stack.insert(nextVC, at: stack.count) // add the new one
        navController.setViewControllers(stack, animated: true) // boom!
        }
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
        
        
        if let thisCompare = compare {
            
            // this will need to be changed to a database update later
            usersArray[indexOfUser(in: usersArray, userID: thisCompare.containerID.userID)].containerCollection[thisCompare.containerID.containerNumber].reportsCollection.append(thisReport)
            
        } else {
            print("Fatal Error:")
            print("The ask was null when trying to access it in the createReview() method")
            fatalError() // crash the app deliberately
        }

    }
    
    func processReport() {
        
        // Here's a question:
        // Do we let them report a specific image or just the whole compare?
        // Probably just do the whole compare and display the red exclamation on both selectionImageViews.
        
        // Sets both selection images to the red exclamation point
        displayReportImages(imageView: topSelectionImageView)
        displayReportImages(imageView: bottomSelectionImageView)
   
        // delays specified number of seconds before executing code in the brackets:
        UIView.animate(withDuration: 0.5, delay: 0.3,
                       options: UIViewAnimationOptions.allowAnimatedContent,
                       animations: {
                        self.topSelectionImageView.alpha = 0.0
                        self.bottomSelectionImageView.alpha = 0.0
                        },
                       completion: { finished in
                        self.topSelectionImageView.isHidden = true
                        self.bottomSelectionImageView.isHidden = true
                        self.loadNextQuestion()
                        }
        )
    }
    
    func displayReportImages(imageView: UIImageView) {
        imageView.image = #imageLiteral(resourceName: "redexclamation")
        imageView.alpha = 0.9
        imageView.isHidden = false
    }
    
    
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        // This may need to be adjusted depending on how we segue between asks and compares
        self.navigationController?.popViewController(animated: true)
    }
    

    // I need a way to switch between the two Review Controllers without
    //  stacking up multiple instances of them on top of each other.

    
}
 


