//
//  DataModels.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/22/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import Foundation; import UIKit

//  an "Ask" is an object holding one image and its
//  associated values

public enum RowType: String {
    case isSingle
    case isDual
}

public enum ImageAspectType: String {
    case isPortrait
    case isLandscape
    case isSquare
}

public enum yesOrNo: String {
    case yes
    case no
}

public enum topOrBottom: String {
    case top
    case bottom
}

public enum askOrCompare: String {
    case ask
    case compare
}

public enum orientation: String {
    case straightWoman
    case straightMan
    case gayWoman
    case gayMan
}

public enum userGroup: String {
    case targetDemo
    case friends
    case allUsers
}

public enum objectToCreate: String {
    case ask
    case compare
    
}


// MARK: MAIN VARIABLES
public var currentImage: UIImage = UIImage(named: "tangerineImage2")!
public var currentTitle: String = "" //realistically this should probably be an optional
public var currentCaption: Caption = Caption(text: "", yLocation: 0.0)
// No longer necessary. questionCollection was replaced with myUser.containerCollection, which is a property of User
//public var questionCollection: [Container] = [] // an array of 'Containers' aka it can hold asks and compares
// when this is true, we will use the photo info taken in from user to create a compare instead of a simple ask. The default, as you can see, is false, meaning we default to creating an Ask
public var isCompare: Bool = false
public var friendsArray: [User] = []

// this object holds a max of 2 images that are currently being edited
// It stores the first image in, then if the user creates a second image, isAsk is set to false
public var currentCompare = compareBeingEdited(isAsk: true, imageBeingEdited1: nil, imageBeingEdited2: nil, creationPhase: .noPhotoTaken)


//this allows for hard dates to be created for test examples
public let formatter = DateFormatter()


// MARK: Set this to set time Ask will post
// This determines how long the compares and asks will be displayed before they expire.
// It's a var so that we can change it at runtime in the future if we need to.
// 5 hours is 5 * 3600 => 18,000 seconds
public var displayTime: TimeInterval = 18000.0

// These are in here so that the properties are only created once, as opposed to every time a new photo is created.
public var initialZoomScale: CGFloat {
    return currentImage.size.height / currentImage.size.width // recomputes in case image is different size than the last one
}

public var initialContentOffset: CGPoint {
    // 47.25 is the ratio of contentOffset/zoomScale when the image is zoomed in enough to make it a square and the contentOffset is centered.
    return CGPoint(x: (47.25 * initialZoomScale), y: 47.25 * (initialZoomScale))
}

// an array of questions that are fed into the review process. As of now we will keep its length at 3.
// It's essentially a buffer.
// This length may need to be adjusted if reviewers are swiping faster than the array can keep up.
public var assignedQuestions: [Question] = []
// I will need a method in this file to load this up that the ReviewAsk and ReviewCompare can call on.
// The method should check the age of the questions and purge them and reload new ones if they are too old.
// The method should also check the length of the array and append new questions until its back to where we want.
public let assignedQuestionsBufferLimit: Int = 3
// We will use the above constant to set the length of the assignQuestions array.
// The name of the method that references it will be below and called loadAssignedQuestions()

public var unreviewedContainersRemainInDatabase: Bool = false

// This will hold the containerID of Questions that the user created but has not performed the requisite number of reviews
//  yet in order to be allowed to view the results.

// We will have to check in AskTableView whether the container has been unlocked before we can display the results

public var tapCoverViewToSegue: Bool = false

// MARK: OBLIGATORY REVIEWS


// Sets the number of reviews required to unlock a container:
public let obligatoryReviewsPerContainer: Int = 3

public var obligatoryReviewsRemaining: Int {
    // The reason for the minus one is because obligatoryReviewsToUnlockNextContainer adds the reviews for the first container
    var additionalContainers: Int = localMyUser.lockedContainers.count - 1
    // If additionalContainers were allowed to drop below zero, we would get a negative value for obligatoryReviewsRemaining
    if additionalContainers < 0 { additionalContainers = 0 }
    return localMyUser.obligatoryReviewsToUnlockNextContainer + (additionalContainers * obligatoryReviewsPerContainer)
}
// There is also a function in DataModels that adds more obligatory reviews when a new Question is created.



// MARK: LOCAL PROPERTIES (VARIABLES)

// These hold data offline and are used to perform actions in absence of the ability to synch with the database.
// Some push to the database and others pull from it.
// Reload these in MainController

public var localContainerCollection: [Container] = []

public var localFriendCollection: [PublicInfo] = [] // how can we modify this so that friend profiles are stored locally but thier private info is not? - question alread answered- by storing only their publicInfo

// keep in mind, a user has a friendNames array that only stores the friends' usernames
// locally, we will store copies of the friends' user profiles so that we can display thier pictures, etc. Before displaying the friends table view, we will refresh this localFriendCollection by searching the database for each friend's profile, based on the list of usernames that is currently in the online user's friendCollection (which, once again is just a list of strings)
//  ^^^^ better yet, I just stored the friends' publicInfo's in an array that we can use to populate a friend tableView without connecting online

// This will need to be stored locally for "app off" storage
//  using either UserDefaults or CoreData functionality.
// I will need an if statement where if the UserDefaults data is nil,
//  it then reroutes user to a login / create new account page.
// For now I will just bypass this by pulling from the simulated database since it is always available:

public var localMyUser: User = sd.usersArray[indexOfUser(in: sd.usersArray, userID: "wyatt")]
// we will need a flag somewhere that tells us whether the user profile has been updated without uploading those changes to the database, so that we know whether to merge the profile with the one online.
// For now we will just assume myUser's profile was already in the database and is exactly how we want it to be.

public var undeletedContainers: [ContainerIdentification] = []

public var unuploadedContainers: [Container] = []

public var unuploadedReviews: [isAReview] = []

public var unuploadedReports: [Report] = []

// should be arrays of usernames
public var undeletedFriends: [String] = []
public var newlyAcceptedFriends: [String] = []
public var newlyRequestedFriends: [String] = []

public var friendsIRequestedPending: [PublicInfo] = []
public var friendsRequestedMePending: [PublicInfo] = []

// END OF LOCAL PROPERTIES





// I'm supposed to change this to round(to places: Int) for swift 3 compliance but to make that work I will also have to change all the places where it is implemented.
public extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(_ places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// This enables us to set a View Controller so that when a user taps outside of a text field, the keyboard will dismiss.
// the only other thing that has to be done is the line:
// self.hideKeyboardWhenTappedAround()
// must be added to the override func viewDidLoad method in each individual VC's source code.

public extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

public func clearOutCurrentCompare() {
    currentCompare.creationPhase = .noPhotoTaken
    currentCompare.imageBeingEdited1 = nil
    currentCompare.imageBeingEdited2 = nil
    //whatToCreate = .ask //hopefully we can get rid of this property also
}

public func resetTextView(textView: UITextView?, blankText: String) {
    if let thisTextView = textView {
        thisTextView.text = blankText
        thisTextView.textColor = UIColor.gray
    }
    
}

public func askForReportType(viewController: UIViewController, function: @escaping ()-> Void) -> reportType {
    print("report alert view method called in datamodels")
    var valueToReturn: reportType = .other
    let alertController = UIAlertController(title: "PLEASE LIST REASON FOR REPORTING", message: nil, preferredStyle: .actionSheet)
    
    // this should iterate through all enum values and add them as possible selections in the alertView
    for rT in iterateEnum(reportType.self)/*this was just (reportType) without the .self - if we get an error, we will need to add arguments per the Swift4 conversion - it had 2 options and we chose the easy one - .self*/ {
        let action = UIAlertAction(title: rT.rawValue, style: .default) {
            UIAlertAction in
            valueToReturn = rT
            function()
        }
        alertController.addAction(action)
    }
    
    viewController.present(alertController, animated: true, completion: nil)
    return valueToReturn
}

/*
case nudity
case demeaning
case notRelevant
case other
case none
 */

func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
    var i = 0
    return AnyIterator {
        let next = withUnsafeBytes(of: &i) { $0.load(as: T.self) }
        if next.hashValue != i { return nil }
        i += 1
        return next
    }
}


// There is a method very similar to this in the simulated database.
// find the index of a container within the containersArray by searching for the container's containerID:
func index(of containerID: ContainerIdentification, containersArray: [Container]) -> Int {
    var index: Int = 0
    for container in containersArray {
        if container.containerID.userID == containerID.userID {
            if container.containerID.timePosted == containerID.timePosted {
                return index
            }
        }
        index += 1
    }
    print("Index of container not found. Container not present in the array.")
    return -1
}




// MARK: TIME REMAINING

public func calcTimeRemaining(_ timePosted: Date) -> String {
    let elapsedTime = Date().timeIntervalSince(timePosted) //returns a double representing seconds
    let secondsRemaining: TimeInterval = displayTime - elapsedTime
    return secondsRemaining.time //applies the below extention to the NSTimeInterval (aka elapsed time, aka seconds converted to an actual time)
}

extension TimeInterval { //got this off the internet to convert an NSTimeInterval into a readable time String. NSTI is just a Double.
    var time: String {
        return String(format:"%02d:%02d", Int((self/3600.0).truncatingRemainder(dividingBy: 24)), Int((self/60.0).truncatingRemainder(dividingBy: 60)))
        //use this way if I want seconds to display also:
        //return String(format:"%02d:%02d:%02d", Int((self/3600.0)%24), Int((self/60.0)%60), Int((self)%60))
    }
}


func ageIfBorn(on birthday: Date) -> Int {
    
    // ensure the date string is passed in the following format
    
    let currentCalendar = Calendar.current

    guard let birthday = currentCalendar.ordinality(of: .day, in: .era, for: birthday) else {
        return 0
    }
    
    guard let today = currentCalendar.ordinality(of: .day, in: .era, for: Date()) else {
        return 0
    }
    
    let age = (today - birthday) / 365
    return age
}

// Makes the view that's passed in into a circle
func makeCircle(view: UIView, alpha: CGFloat){
    view.layer.cornerRadius = view.frame.size.height / 2
    view.layer.masksToBounds = true
    
    view.backgroundColor = UIColor.black.withAlphaComponent(alpha)
    
    //view.alpha = alpha // this isn't technically required to make it into a circle but it's more efficient to have this command here rather than doing it in interface builder
    
}

func display(coverView: UIView, mainView: UIView) {
    // this would look better if we animated a fade in of the coverView (and a fade out lower down)
    print("displaying coverView")
    coverView.isHidden = false
    mainView.bringSubview(toFront: coverView)
}

func hide(coverView: UIView, mainView: UIView) {
    mainView.sendSubview(toBack: coverView)
    coverView.isHidden = true
}

public protocol isReviewVC {
    func loadNextQuestion()
}

func informUserNoQuestions(coverView: UIView, coverViewLabel: UILabel, mainView: UIView, viewController: isReviewVC ) {
    //animate coverview darkening
    coverView.alpha = 0.1
    UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
        display(coverView: coverView, mainView: mainView)
        coverView.alpha = 1.0
    }, completion: {
        finished in
        
    })
    coverViewLabel.text = "Connecting to Server"
    coverViewLabel.isHidden = false
    if unreviewedContainersRemainInDatabase == false {
        loadAssignedQuestions() // first reattempt to load the array again
        if unreviewedContainersRemainInDatabase == true {
            //we were able to loadAssignedQuestions successfully this time, just reload the view.
            coverViewLabel.isHidden = false
            hide(coverView: coverView, mainView: mainView)
            viewController.loadNextQuestion()
        } else {
            print("database is out of questions")
            // we know for sure that the database has no more questions in it to review
            tapCoverViewToSegue = true
            coverViewLabel.text = "You have reviewed all currently available photos! Congratulations! Tap to return to main menu."
            // we want to unlock all of the user's containers because with nothing to review, they won't be able to unlock them any other way
            localMyUser.lockedContainers = []
            localMyUser.obligatoryReviewsToUnlockNextContainer = 0
            
        }
    } else {
        // loadAssignedQuestions never encountered a nil value from the database and therefore
        //  the reason for the array being out of questions is a lack of connectivity, not a lack of questions left to review
        // Notify user of connectivity problem and reroute the user back to the mainVC.
        tapCoverViewToSegue = true
        coverViewLabel.text = "Connectivity issues are preventing retrieval of more photos. Tap to return to main menu"
    }
} // end informUserNoAvailableQuestions()


// calculates the caption's autolayout constraint for its distance from the top of the imageView it is being displayed over.
// Normally this constraint will actually be within a View that is acting as a container for the imageView, scrollView, and captionTextField
public func calcCaptionTextFieldTopConstraint(imageViewFrameHeight: CGFloat, captionYLocation: CGFloat) -> CGFloat {
    // As you can see, all this does it multiply the values
    // This is because the yLocation is just a fraction between 0 and 1
    //  that represents the percentage of the way down the outside view
    //  that the caption should appear
    // The property "imageViewFrameHeight could be misleading because
    //  it could also be the height of the external "helper view" that contains
    //  a scrollView which in turn contains an imageView.
    // The reason it works normally to call the method using the imageView's
    //  height is because this method is normally invoked upon loading the
    //  view controller and the scrollView's zoomScale is normally 1.0 at that
    //  point in the code's execution. 
    return imageViewFrameHeight * captionYLocation
}


// This function sets up an image with its accompanying caption correctly
public func loadImageView(imageView: UIImageView?, with image: UIImage?, within helperView: UIView?, caption: Caption, captionTextField: UITextField?, captionTopConstraint: NSLayoutConstraint?) {
    if let thisImageView = imageView,
        let thisHelperView = helperView,
        let thisTopConstraint = captionTopConstraint,
        let thisImage = image,
        let thisTextField = captionTextField {
        
        thisImageView.image = thisImage
        
        thisTextField.isHidden = !caption.exists
        thisTextField.text = caption.text
        thisTopConstraint.constant = calcCaptionTextFieldTopConstraint(imageViewFrameHeight: thisHelperView.frame.height, captionYLocation: caption.yLocation)
        
    }
    
    
}



// Should this just be in the AskVC since Compare bars are calc'd slightly differently?
/////// Here we need a funcion into which we can pass the screenwidth, ////////////////
///////  size of the width constraint of whatever is to the left of it (reviews label or image), and percent yes      ////////////////
///////  that returns the value that the trailing constraint should be ////////////////
///////  in order for the graphical white bar to be proportionate      ////////////////
///////  to the percent of yes votes, without squishing the numerical label. //////////



// This is different now since I added the 100 bars in IB. It will be much simpler,
// Basically we will just multiply (one minus the percentage) times the 100 bar width in order to get the trailing constraint of'
//   whichever view we are dealing with. This will work in Compare VC and AskVC and for normal and strong bars alike. 
public func calcTrailingConstraint(percentYes: Int, hundredBarWidth: CGFloat) -> CGFloat {
    
    //Converts the percentage Int value into a decimal CGFloat that is < 1:
    let decimalPercentYes: CGFloat = CGFloat(percentYes) / 100.0
    
    print("decimalPercentYes: \(decimalPercentYes)")
    
    //Calculates how wide we need the bar we are setting up to be:
    let neededBarWidth = hundredBarWidth * decimalPercentYes
    
    //Calculates the size of the trailing constraint of the bar being set up:
    let constraintSize = hundredBarWidth - neededBarWidth

    return constraintSize

}

public func flipBarLabelsAsRequired(hundredBarWidth: CGFloat, yesTrailingConstraint: NSLayoutConstraint, yesPercentageLabel: UILabel, yesLabelLeadingConstraint: NSLayoutConstraint, strongYesTrailingConstraint: NSLayoutConstraint, strongYesPercentageLabel: UILabel, strongYesLabelTrailingConstraint: NSLayoutConstraint) {
    
    // Switch the yesPercentageLabel to the inside of the bar if there isn't enough space to display it on the outside:
    if (yesTrailingConstraint.constant < yesPercentageLabel.frame.size.width) {
        // this flips the label over to the other side by giving the constraint a negative constant
        yesLabelLeadingConstraint.constant = -1 * yesPercentageLabel.frame.size.width * 1.3
        // this changes the text color
        yesPercentageLabel.textColor = UIColor.black
        
        if ((strongYesTrailingConstraint.constant - yesTrailingConstraint.constant) < (yesPercentageLabel.frame.size.width * 1.3)){
            print("inside the fixer nested if - system knows there is not enough room for both labels")
            // in layman's terms:
            // If the space left for the label is too small,
            //  hide the strong label
            strongYesPercentageLabel.isHidden = true
        }

    } else { // this just sets it back to normal in case we flipped the label over and it needs to go back
        yesLabelLeadingConstraint.constant = 0.5
        yesPercentageLabel.textColor = UIColor.white
    }

    // Switch the strongYesPercentageLabel to the outside of the bar if there isn't enough space to display it on the inside:
    if ((hundredBarWidth - strongYesTrailingConstraint.constant) < yesPercentageLabel.frame.size.width) {
        // this flips the label over to the other side by giving the constraint a negative constant
        strongYesLabelTrailingConstraint.constant = -1 * strongYesPercentageLabel.frame.size.width // 0.5 is just a little extra padding
        // this changes the text color
        strongYesPercentageLabel.textColor = UIColor.blue
        strongYesPercentageLabel.isHidden = false

        if ((yesTrailingConstraint.constant - strongYesTrailingConstraint.constant) < (yesPercentageLabel.frame.size.width * 1.3)){
            print("inside the fixer nested if - system knows there is not enough room for both labels")
            
            // hide the strong label if there's not enough room to display it:
            strongYesPercentageLabel.isHidden = true
            
            
        }
    }
    
} // end of public func flipBarLabelsAsRequired(..)


/* The old header. Can be deleted once new rating display functionality is fully working */
public func displayData(dataSet: ConsolidatedAskDataSet,
                        totalReviewsLabel: UILabel,
                        yesPercentageLabel: UILabel,
                        strongYesPercentageLabel: UILabel,
                        hundredBarView: UIView,
                        yesTrailingConstraint: NSLayoutConstraint,
                        yesLabelLeadingConstraint: NSLayoutConstraint,
                        strongYesTrailingConstraint: NSLayoutConstraint,
                        strongYesLabelTrailingConstraint: NSLayoutConstraint) {
    
}
///// ^^^^ This will all go away soon

public func displayData(dataSet: ConsolidatedAskDataSet,
                 totalReviewsLabel: UILabel,
                 displayTool: DataDisplayTool,
                 displayBottom: Bool,
                 ratingValueLabel: UILabel){
    
    totalReviewsLabel.text = String(dataSet.numReviews)
    
    displayTool.displayIcons(dataSet: dataSet, forBottom: displayBottom)
    
    if dataSet.numReviews < 1 {
        ratingValueLabel.text = "No reviews from the specified group."
        ratingValueLabel.font = ratingValueLabel.font.withSize(10.0)
    } else {
        ratingValueLabel.font = ratingValueLabel.font.withSize(17.0)
        ratingValueLabel.text = String(dataSet.rating)
    }
    
    /*
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
     */
} // end of displayData(Ask)

public func displayData(dataSet: ConsolidatedCompareDataSet,
                 numReviewsLabel: UILabel,
                 votePercentageTopLabel: UILabel,
                 votePercentageBottomLabel: UILabel,
                 strongVotePercentageTopLabel: UILabel?,
                 strongVotePercentageBottomLabel: UILabel?,
                 hundredBarTopView: UIView,
                 hundredBarBottomView: UIView,
                 topBarTrailingConstraint: NSLayoutConstraint,
                 voteTopLabelLeadingConstraint: NSLayoutConstraint?,
                 bottomBarTrailingConstraint: NSLayoutConstraint,
                 voteBottomLabelLeadingConstraint: NSLayoutConstraint?,
                 topStrongBarTrailingConstraint: NSLayoutConstraint,
                 strongTopLabelTrailingConstraint: NSLayoutConstraint?,
                 bottomStrongBarTrailingConstraint: NSLayoutConstraint,
                 strongBottomLabelTrailingConstraint: NSLayoutConstraint?){
    

    
    numReviewsLabel.text = "\(dataSet.numReviews) votes"
    

    votePercentageTopLabel.text = String(dataSet.percentTop) + "%"
    votePercentageBottomLabel.text = String(dataSet.percentBottom) + "%"
    

    let hundredBarTopWidth = hundredBarTopView.frame.size.width
    let hundredBarBottomWidth = hundredBarBottomView.frame.size.width
    
    // Both 100 bars should presumably be the same size. I used their separate values though in case something funky happens with te constraints at runtime.
    topBarTrailingConstraint.constant = calcTrailingConstraint(percentYes: dataSet.percentTop, hundredBarWidth: hundredBarTopWidth)
    bottomBarTrailingConstraint.constant = calcTrailingConstraint(percentYes: dataSet.percentBottom, hundredBarWidth: hundredBarBottomWidth)
    
    topStrongBarTrailingConstraint.constant = calcTrailingConstraint(percentYes: dataSet.percentStrongYesTop, hundredBarWidth: hundredBarTopWidth)
    bottomStrongBarTrailingConstraint.constant = calcTrailingConstraint(percentYes: dataSet.percentStrongYesBottom, hundredBarWidth: hundredBarBottomWidth)
    
    // Here we unwrap all the optionals having to do with labels.
    // They are optional arguments because CompareTableViewCell doesn't use them.
    if let thisStrongTopLabel = strongVotePercentageTopLabel,
        let thisStrongBottomLabel = strongVotePercentageBottomLabel,
        let thisVoteBottomLabelLeadingConstraint = voteBottomLabelLeadingConstraint,
        let thisVoteTopLabelLeadingConstraint = voteTopLabelLeadingConstraint,
        let thisStrongTopLabelTrailingConstraint = strongTopLabelTrailingConstraint,
        let thisStrongBottomLabelTrailingConstraint = strongBottomLabelTrailingConstraint {
        
        thisStrongTopLabel.text = String(dataSet.percentStrongYesTop) + "%"
        thisStrongBottomLabel.text = String(dataSet.percentStrongYesBottom) + "%"
        // Note: strongNo storage capability exists but has not been (and may never be) implemented
   
    
        //  (1) switch sides if there isn't enough room to display the number
        //  (2) become hidden if strong is too close to regular such that
        //       the labels displayed would become cluttered.
        
        // adjust top bar labels if necessary:
        flipBarLabelsAsRequired(hundredBarWidth: hundredBarTopWidth,
                                yesTrailingConstraint: topBarTrailingConstraint,
                                yesPercentageLabel: votePercentageTopLabel,
                                yesLabelLeadingConstraint: thisVoteTopLabelLeadingConstraint,
                                strongYesTrailingConstraint: topStrongBarTrailingConstraint,
                                strongYesPercentageLabel: thisStrongTopLabel,
                                strongYesLabelTrailingConstraint: thisStrongTopLabelTrailingConstraint)
    
        // adjust bottom bar labels if necessary:
        flipBarLabelsAsRequired(hundredBarWidth: hundredBarBottomWidth,
                                yesTrailingConstraint: bottomBarTrailingConstraint,
                                yesPercentageLabel: votePercentageBottomLabel,
                                yesLabelLeadingConstraint: thisVoteBottomLabelLeadingConstraint,
                                strongYesTrailingConstraint: bottomStrongBarTrailingConstraint,
                                strongYesPercentageLabel: thisStrongBottomLabel,
                                strongYesLabelTrailingConstraint: thisStrongBottomLabelTrailingConstraint)
    }
    
    
} // end of displayData(Compare)



// convert the enum value to a text value that's useful in labels:
public func selectionToText(selection: yesOrNo) -> String {
    switch selection {
    case .yes: return "YES"
    case .no: return "NO"
    }
}

public func selectionImage(selection: topOrBottom, compare: Compare) -> UIImage {
    switch selection {
    case .top: return compare.comparePhoto1
    case .bottom: return compare.comparePhoto2
    }
}

public func selectionTitle(selection: topOrBottom, compare: Compare) -> String {
    switch selection {
    case .top: return compare.compareTitle1
    case .bottom: return compare.compareTitle2
    }
}

// This method is for Asks
public func strongToText(strong: yesOrNo?) -> String {
    if let strong = strong { // strong is an optional property
        switch strong {
        case .yes: return "🔥"
        case .no: return "❄️" // I have not yet implemented any strong No's
        }
    } else {
        return ""
    }
}

// This method is for compares
public func strongToText(strongYes: Bool, strongNo: Bool) -> String {
    var stringToReturn: String = ""
    if strongYes == true {
        stringToReturn = stringToReturn + "🔥"
    }
    if strongNo == true {
        stringToReturn = stringToReturn + "❄️"
    }
    
    // It's possible that the label could have both emojis
    // This would be a situation where the user loved the one they voted for
    //  and really hated the one they didn't.
    // I'm not sure if I'll ever even use the strong no.
    // It is currently unimplemented.
    
    return stringToReturn
}

public func reviewerRatingToTangerines(rating: Double) -> String {
    switch rating {
    case 0..<0.5: return "" + String(format:"%.1f", rating)
    case 0.5..<1.5: return "🍊" + String(format:"%.1f", rating)
    case 1.5..<2.5: return "🍊🍊" + String(format:"%.1f", rating)
    case 2.5..<3.5: return "🍊🍊🍊" + String(format:"%.1f", rating)
    case 3.5..<4.5: return "🍊🍊🍊🍊" + String(format:"%.1f", rating)
    case 4.5..<5.1: return "🍊🍊🍊🍊🍊" + String(format:"%.1f", rating)
    default: return String(format:"%.1f", rating)
    }
}


public func orientationToText(userDemo: orientation) -> String {
    switch userDemo {
    case .straightWoman: return "Straight Woman"
    case .straightMan: return "Straight Man"
    case .gayWoman: return "Gay Woman"
    case .gayMan: return "Gay Man"
    }
}



// an awesome website for color conversion is: http://uicolor.xyz/#/hex-to-ui
public func orientationSpecificColor(userOrientation: orientation) -> UIColor {
    switch userOrientation {
    case .straightWoman: return UIColor(red:0.92, green:0.63, blue:0.89, alpha:1.0) //pink
    case .straightMan: return UIColor(red:0.48, green:0.65, blue:0.93, alpha:1.0) //blue
    case .gayWoman: return UIColor(red:0.71, green:0.36, blue:0.89, alpha:1.0) //purple
    case .gayMan: return UIColor(red:0.48, green:0.93, blue:0.55, alpha:1.0) //green
    }
}


public func returnProfilePic(image: UIImage?) -> UIImage {
    // unwrap reviewing user's profile picture (it's optional)
    if let thisImage = image {
        return thisImage
    } else {
        return #imageLiteral(resourceName: "generic_user")
    }
}

public func createContainerID() -> ContainerIdentification {
    // this works because myUser always exists
    return ContainerIdentification(userID: localMyUser.publicInfo.userName,
                                   containerNumber: localMyUser.lowestAvailableContainerIDNumber(), timePosted: Date())
    // ^^ This shouldn't need a timePosted parameter being passed in. The compiler started asking for it after I 
    //  created a second initializer method for the asks and compares to take a dummy time.
}



public func indexOfUser(in array: [User], userID: String)-> Int {
    // find userID's index in the array:
    var index: Int = 0
    for user in array {
        if user.publicInfo.userName == userID {
            return index
        }
        index += 1
    }
    print("myUser wasn't found in the usersArray, therefore the dummy containers couldn't be appended to it")
    fatalError()
}


public func indexOf(containerID: ContainerIdentification, in array: [ContainerIdentification])-> Int {
    // find containerID's index in the array:
    var index: Int = 0
    for cID in array {
        // we don't need to search the userID because they are all the same
        if cID.timePosted == containerID.timePosted {
            return index
        }
        index += 1
    }
    print("containerID wasn't found in the array, returning -1")
    return -1
}



public func loadAssignedQuestions() {
    
    unreviewedContainersRemainInDatabase = true
    
    if assignedQuestions.count == assignedQuestionsBufferLimit {
        return
    }
    
    print("assignedQuestions.count= \(assignedQuestions.count)")
    while assignedQuestions.count < assignedQuestionsBufferLimit {
        if let newQuestion = fetchNewQuestion(recycleQuestions: false) {
            assignedQuestions.append(newQuestion)
            print("added a new question to the assignedQuestions queue")
            print("assignedQuestions.count= \(assignedQuestions.count)")
        } else {
            unreviewedContainersRemainInDatabase = false // this tells the system that the assignedQuestions array is not filled to capacity
            return
        }
    }
    
    while assignedQuestions.count > assignedQuestionsBufferLimit {
        assignedQuestions.removeFirst()
        print("assignedQuestions had too many elements, removed the first element")
        print("assignedQuestionsBufferLimit = \(assignedQuestionsBufferLimit)")
        print("assignedQuestions.count= \(assignedQuestions.count)")
    }
    
    // what about the situation where the user has literally reviewed every question in the database?
    // It IS technically possible, especially early on...
    //
    // Realistically what needs to happen is the same as tinder. It just shows a blank screen that says nothing available to review.
    // At this point we must also unlock all of the user's personal questions because without questions to review,
    //  they'll never be able to view their results otherwise.
}

// This counter is only for use with dummy Questions. It allows us to keep iterating through them.
//var questionCounter: Int = 0

public func fetchNewQuestion(recycleQuestions: Bool) -> Question? {
    // This will have to pull info from the database. For now we will just use dummy questions.
    print("fetching new question")
    
    let question: Question? = sd.questionRequesting(orientation: localMyUser.publicInfo.orientation, age: localMyUser.publicInfo.age, requesterName: localMyUser.publicInfo.userName)

    if let thisQuestion = question {
        print("new question's timePosted is \(thisQuestion.containerID.timePosted)")
        return thisQuestion
    }
    
    // anything below this will happen if fetchNewQuestion returned nil (i.e. there are no more q's in the db for myUser to review):
    
    switch recycleQuestions {
    case true:
        //print("questionCounter = \(questionCounter)")
        //questionCounter += 1 //increment questionCounter each time we send the user a question
        // this wont work right if we're trying to review questions that the user creates at runtime.
        //if questionCounter > sd.containersArray.count {
            //print("resetting questionCounter to 0")
            //questionCounter = 0 // at this point we've reviewed everything in the containersArray and need to go back to the beginning to keep testing the reviewOthers fucntionality
            // clear out the usersSentTo lists for all of the dummy containers
        print("clearing all usersSentTo arrays")
        for container in sd.containersArray {
            container.usersSentTo = []
            
            /*
            if let thisQuestion = sd.questionRequesting(orientation: localMyUser.publicInfo.orientation, age: localMyUser.publicInfo.age, requesterName: localMyUser.publicInfo.userName) {
                return thisQuestion
            } else {
                print("ERROR: RecycleQuestions is set to true, however database is still returning nil *******")
                return nil
            }
            */
        
        }
        print("calling fetchNewQuestion again")
        return fetchNewQuestion(recycleQuestions: true)
    case false:
        print("RecycleQuestions is set to false. No more questions to review")
        return nil
    }

    return nil
    
    //let question = sd.questionRequesting(orientation: localMyUser.publicInfo.orientation, age: localMyUser.publicInfo.age, requesterName: localMyUser.publicInfo.userName)
    
    //print("new question's userID is \(question.containerID.userID)")
    //print("new question's timePosted is \(question.containerID.timePosted)")
    
    //return question //sd.containersArray[questionCounter].question
}











/*
public struct DemoPreferences {
    var minAge: Int
    var maxAge: Int
    var straightWomenPreferred: Bool
    var straightMenPreferred: Bool
    var gayWomenPreferred: Bool
    var gayMenPreferred: Bool
}
*/




public protocol Question { //this really should be isQuestion
    var type: askOrCompare {get set}
    //var timePosted: Date {get set}
    var numVotes: Int {get}
    // this should enable us to send reviews about this question up to the database:
    // We may need to create a dictionary at some point with the database primary keys of each containerID
    var containerID: ContainerIdentification {get set}
    // MARK: Will also need to set up a timePosted requirement so the array of these objects can be sorted according to that
}

// The Container holds the Ask or Compare (aka Question) as well as the associated ReviewCollection
// The reason for not just adding the ReviewCollection as a property of the Question is so that 
//   on the reviewing side, we can send the reviewer Question's without also forcing the device
//   to download all associated reviews in the ReviewCollection, which they will never see or use.
// Essentially, it's an effort to save bandwidth / transmitted data.
public class Container {
    var containerID: ContainerIdentification {
        return question.containerID
    }
    var containerType: askOrCompare {
        return question.type
    }
    var question: Question
    
    // This keeps track of how many users we sent the container's question to:
    // We can use this to spread questions equally to the available reviewers.
    var usersSentTo: [String] = []
    var numberOfUsersSentTo: Int { return usersSentTo.count }
    
    var reviewCollection: ReviewCollection
    var reportsCollection: [Report]
    var numReviews: Int { return reviewCollection.reviews.count }
    var numReports: Int { return reportsCollection.count }
    
    init(question q: Question) {
        question = q
        reviewCollection = ReviewCollection(type: question.type)
        reportsCollection = []
        localMyUser.containerIDCollection.append(self.containerID) // at some point I will also need a way to remove the containers
        // MARK: Does this yield the correct index location given the containerID?
        localContainerCollection.append(self)
    }
    
    // This additional initializer exists only for the sake of testing.
    // It enables us to create containers using different usernames.
    init(question q: Question, createdBy username: String) {
        question = q
        reviewCollection = ReviewCollection(type: question.type)
        reportsCollection = []
        
        //localMyUser.containerIDCollection.append(self.containerID) // at some point I will also need a way to remove the containers
        // MARK: Does this yield the correct index location given the containerID?
        sd.containersArray.append(self)
    }

    
    func isLocked() -> Bool {
        refreshUserProfile() // ensure lockedContainers list is as up to date as possible
        let lockedContainers: [ContainerIdentification] = localMyUser.lockedContainers
        for someContainerID in lockedContainers {
            if someContainerID.userID == containerID.userID {
                if someContainerID.timePosted == containerID.timePosted {
                    // this means that the containerID was found in the locked list
                    return true
                }
            }
        }
        // if we get to this point, it means we searched the locked list and didn't find the containerID
        return false
    }
}

public struct ContainerIdentification {
    // see if I can change these to let constants vice vars:
    var userID: String
    var containerNumber: Int // not planning on using this anymore
    // MARK: this should be changed back to a let constant when beta is launched.
    // It is only var so that we can change it for the dummy Questions
    var timePosted: Date = Date() //sets timePosted to the current time at the time of Question creation.
    
}

public struct Report {
    var type: reportType
    var containerID: ContainerIdentification
}

public class ReviewCollection {
    var reviewCollectionType: askOrCompare
    var reviews: [isAReview]
    
    init(type: askOrCompare) {
        reviews = [] //keep in mind, this is empty, not optional
        reviewCollectionType = type
    }
    
    //Things I want in a consolidated review page:
    // % yes and % no
    // % strong yes, % strong no
    // Average age
    // % of each orientation
    // Can I pull all of these on just one trip through the loop?
    // Can I create a method that will pull this info from the RC within specific constraints?
    
    func isTargetDemo(index: Int, targetDemo: TargetDemo) -> Bool {
        let thisReview = reviews[index]
        
        if thisReview.reviewerAge <= targetDemo.minAge || thisReview.reviewerAge >= targetDemo.maxAge {
            print("too old or young.")
            return false // skips the rest of the code in this method
        }

        // This switch statement checks which orientation the reviewer was, and if we are
        //  trying to pull from that demographic, it returns true (since we already know they
        //  are in the appropriate age range)

        switch thisReview.reviewerOrientation {
        case .straightWoman:
            print("found a straight woman")
            if targetDemo.straightWomenPreferred {return true}
        case .straightMan:
            if targetDemo.straightMenPreferred {return true}
        case .gayWoman:
            if targetDemo.gayWomenPreferred {return true}
        case .gayMan:
            if targetDemo.gayMenPreferred {return true}
        }
        // the reviewer was in the age range but was not in any of my preferred orientations
        return false
    }
    
    func isFriend(index: Int, targetDemo: TargetDemo) -> Bool {
        //let thisReview = reviews[index]  //UNCOMMENT WHEN UPDATING THIS METHOD
        // This method will require updating once I start linking users together through friendship
        // As of now, all users are friends because this always returns true.
        return true
    }
    
    func filterReviews(by sortType: userGroup) -> [isAReview] {
        var filteredReviewsArray: [isAReview] = []
        var index: Int = 0
        switch sortType {
        case .allUsers: return self.reviews
        case .targetDemo:
            print("filtering for target demo")
            for review in reviews {
                if self.isTargetDemo(index: index, targetDemo: localMyUser.targetDemo) {
                    print("appending a \(String(describing: review.reviewerOrientation)) to the array")
                    filteredReviewsArray.append(review)
                }
                index += 1
            }
        case .friends:
            print("filtering for friends")
            for review in reviews {
                if self.isFriend(index: index, targetDemo: localMyUser.targetDemo) {
                    filteredReviewsArray.append(review)
                }
                index += 1
            }
        }
        
        return filteredReviewsArray
    }
    // Returns aggregated data within the age and orientation demographic specified in the arguments:
    func pullConsolidatedAskData(requestedDemo: TargetDemo, friendsOnly: Bool)-> ConsolidatedAskDataSet {

            let lowestAge: Int = requestedDemo.minAge
            let highestAge: Int = requestedDemo.maxAge
            let straightWomen: Bool = requestedDemo.straightWomenPreferred
            let straightMen: Bool = requestedDemo.straightMenPreferred
            let gayWomen: Bool = requestedDemo.gayWomenPreferred
            let gayMen: Bool = requestedDemo.gayMenPreferred
        
        //  Friends Only filter not yet implemented //
        // What I forsee for this is to outsource a function that checks to see if a review is from a friend
        //  (likely by searching a friend list for this specific user name)
        //  and then in the loop where we look at each review, if friendsOnly is true, 
        //  call the friend search function on each review to decide whether we should count it or not
        // It will be similar to the Demo switch but will have to either be encompassing it, or 
        //  bypassing it separately. Because if I want all my friends, I don't care if they are straight or 
        //  female or whatever so what's the point in checking if they are.
        
        
        // These are doubles so we can do fraction math on them without them rounding automatically to zero
        var countYes: Double = 0.0
        var countNo: Double = 0.0
        
        var countStrongYes: Double = 0.0
        var countStrongNo: Double = 0.0
        
        var countAge: Double = 0.0
        
        var countSW: Double = 0.0
        var countSM: Double = 0.0
        var countGW: Double = 0.0
        var countGM: Double = 0.0
        
        reviewLoop: for r in reviews {
            let review = r as! AskReview //this way we can access all properties of an AskReview
            
            // the isTargetDemo method could be incorporated into this method to shorten/sugar it
            
            // This guard statement skips this iteration if review is outside the selected age
            guard review.reviewerAge >= lowestAge || review.reviewerAge <= highestAge else {
                print("continuing review loop")
                continue reviewLoop // sends us back to the top of the loop
            }
            
            
            // This switch statement checks which orientation demo the reviewer was, and if we aren't
            //  trying to pull from that demo, we go back to the beginning of the for loop.
            // If we are trying to pull from that demo, we increment that demo's count and move on.
            switch review.reviewerOrientation {
            case .straightWoman:
                if straightWomen == false {continue reviewLoop}
                countSW += 1
            case .straightMan:
                if straightMen == false {continue reviewLoop}
                countSM += 1
            case .gayWoman:
                if gayWomen == false {continue reviewLoop}
                countGW += 1
            case .gayMan:
                if gayMen == false {continue reviewLoop}
                countGM += 1
                
            }
            

            countAge += Double(review.reviewerAge) // we just add up all the ages for now, divide them out later
            
            switch review.selection {
            case .yes: countYes += 1; print("counted a yes")
            case .no: countNo += 1; print("counted a no")
            }
            
            // We need this because the strong property is optional.
            // Basically, if strong is nil, we'll increment neither.
            if let strong = review.strong {
               switch strong {
               case .yes: countStrongYes += 1
               case .no: countStrongNo += 1
               }
            }
            
        }
        
        
        print("countYes= \(countYes), countNo= \(countNo)")
        let countReviews = countYes + countNo
        
        
        if countReviews > 0 {
            return ConsolidatedAskDataSet(percentYes: Int(100 * (countYes / countReviews)),
                                          percentStrongYes: Int(100 * countStrongYes / countReviews),
                                          percentStrongNo: Int(100 * countStrongNo / countReviews),
                                          averageAge: (countAge / countReviews),
                                          percentSW: Int(100 * countSW / countReviews),
                                          percentSM: Int(100 * countSM / countReviews),
                                          percentGW: Int(100 * countGW / countReviews),
                                          percentGM: Int(100 * countGM / countReviews),
                                          numReviews: Int(countReviews))
        } else {
            return ConsolidatedAskDataSet(percentYes: 0,
                                          percentStrongYes: 0,
                                          percentStrongNo: 0,
                                          averageAge: 0.0,
                                          percentSW: 0,
                                          percentSM: 0,
                                          percentGW: 0,
                                          percentGM: 0,
                                          numReviews: 0)
        }
    }
    
    
    // create a function in here that returns the selection. There will need to be two types, one for ask and one for compare.
    // There should probably also be one for desired demo and one for undesired demo.
    // Therefore, we need a way to sort the reviews into those two catgories
    // We also need a way to return the total selection (desired and undesired)
    // Actually we will need to be able to return a ton of different stuff:
    //   value by demo, value by age, etc; a bunch of stuff for graphs and displays
    // What we do with this data is the meat of the entire app. It's why people are using it. For this data.
    // Also, though outside of the scope of the above comments, we need a way to save Containers for offline use on a local file. 
    
    func pullConsolidatedCompareData(requestedDemo: TargetDemo, friendsOnly: Bool)-> ConsolidatedCompareDataSet {
        
        let lowestAge: Int = requestedDemo.minAge
        let highestAge: Int = requestedDemo.maxAge
        let straightWomen: Bool = requestedDemo.straightWomenPreferred
        let straightMen: Bool = requestedDemo.straightMenPreferred
        let gayWomen: Bool = requestedDemo.gayWomenPreferred
        let gayMen: Bool = requestedDemo.gayMenPreferred
        
        
        
        //  Friends Only filter not yet implemented //
        //  See pullConsolidatedAskData method for lengthier comment on this //
        
        
        
        var countTop: Double = 0.0
        var countBottom: Double = 0.0
        
        var countStrongYesTop: Double = 0.0
        var countStrongYesBottom: Double = 0.0
        var countStrongNoTop: Double = 0.0
        var countStrongNoBottom: Double = 0.0
        
        var countAge: Double = 0.0
        
        var countSW: Double = 0.0
        var countSM: Double = 0.0
        var countGW: Double = 0.0
        var countGM: Double = 0.0
        
        reviewLoop: for r in reviews {
            print("inside reviewLoop while pulling Compare Data")
            let review = r as! CompareReview //this way we can access all properties of a CompareReview
            
            // This guard statement skips this iteration if review is outside the selected age
            guard review.reviewerAge >= lowestAge || review.reviewerAge <= highestAge else {
                print("too old or young. skipping to next review")
                continue reviewLoop // sends us back to the top of the loop
            }

            // This switch statement checks which orientation demo the reviewer was, and if we aren't
            //  trying to pull from that demo, we go back to the beginning of the for loop.
            // If we are trying to pull from that demo, we increment that demo's count and move on.
            switch review.reviewerOrientation {
            case .straightWoman:
                if straightWomen == false {continue reviewLoop}
                countSW += 1
            case .straightMan:
                if straightMen == false {continue reviewLoop}
                countSM += 1
            case .gayWoman:
                if gayWomen == false {continue reviewLoop}
                countGW += 1
            case .gayMan:
                if gayMen == false {continue reviewLoop}
                countGM += 1
            }
            
            
            countAge += Double(review.reviewerAge) // we just add up all the ages for now, divide them out later

            switch review.selection {
            case .top:
                countTop += 1; print("counted a top")
                if review.strongYes == true {countStrongYesTop += 1}
                if review.strongNo == true {countStrongNoBottom += 1}
            case .bottom:
                countBottom += 1; print("counted a bottom")
                if review.strongYes == true {countStrongYesBottom += 1}
                if review.strongNo == true {countStrongNoTop += 1}
            }

        }
        
        
        print("countTop: \(countTop), countBottom: \(countBottom)")
        let countReviews = countTop + countBottom
        
        
        if countReviews > 0 {
            
            return ConsolidatedCompareDataSet(percentTop: Int(100 * countTop / countReviews),
                                          percentStrongYesTop: Int(100 * countStrongYesTop / countReviews),
                                          percentStrongYesBottom: Int(100 * countStrongYesBottom / countReviews),
                                          //percentStrongNoTop: Int(100 * countStrongNoTop / countReviews),
                                          //percentStrongNoBottom: Int(100 * countStrongNoBottom / countReviews),
                                          averageAge: (Double(countAge / countReviews)),
                                          percentSW: Int(100 * countSW / countReviews),
                                          percentSM: Int(100 * countSM / countReviews),
                                          percentGW: Int(100 * countGW / countReviews),
                                          percentGM: Int(100 * countGM / countReviews),
                                          numReviews: Int(countReviews))
        } else {
            return ConsolidatedCompareDataSet(percentTop: 0,
                                              percentStrongYesTop: 0,
                                              percentStrongYesBottom: 0,
                                              //percentStrongNoTop: 0,
                                              //percentStrongNoBottom: 0,
                                              averageAge: 0,// consider returning -1 or some indicator for label to display NA
                                              percentSW: 0,
                                              percentSM: 0,
                                              percentGW: 0,
                                              percentGM: 0,
                                              numReviews: 0)
        }

    }
}

public protocol isConsolidatedDataSet {
    // this exists only so that I can have one pullConsolidatedData method
    var rating: Double {get}
}


//////////////////////////////// Probably should be moved up to the top at some point /////
// MARK: Rating Constant Values
let strongYesConstant = 5
let yesConstant = 4
let noConstant = 1
let strongNoConstant = 0
// These are used in ConsolidatedAskDataSet and ConsolidatedCompareDataSet to calculate a 1-5 rating for the Question
////////////////////////////////

public struct ConsolidatedAskDataSet: isConsolidatedDataSet {
    let percentYes: Int
    var percentNo: Int { return 100 - percentYes }
    let percentStrongYes: Int
    let percentStrongNo: Int
    let averageAge: Double
    let percentSW: Int
    let percentSM: Int
    let percentGW: Int
    let percentGM: Int
    let numReviews: Int
    
    public var rating: Double {
        let rawRating = (percentStrongYes * strongYesConstant) +
                    ((percentYes - percentStrongYes) * yesConstant) +
                    ((percentNo - percentStrongNo) * noConstant) +
                    (percentStrongNo * strongNoConstant)
        let ratingToReturn = Double(rawRating) / 100 // rawRating is out of 500, rating to return is out of 5
        return ratingToReturn.roundToPlaces(1) // returns the double with only one decimal place
    }
}




public struct ConsolidatedCompareDataSet: isConsolidatedDataSet {
    // Keeps these values consistent with the ones defined above
    // We use these for computing the top image's rating, the bottom image is just 5 minus the top
    let strongYesTopConstant = strongYesConstant
    let yesTopConstant = yesConstant
    let yesBottomConstant = noConstant
    let strongYesBottomConstant = strongNoConstant // a strong yes for the bottom is essentially a strong no for the top
    
    let percentTop: Int
    var percentBottom: Int {
        if numReviews < 1 {
            return 0
        } else {
            return 100 - percentTop
        }
    }
    let percentStrongYesTop: Int
    let percentStrongYesBottom: Int
    //let percentStrongNoTop: Int
    //let percentStrongNoBottom: Int
    let averageAge: Double
    let percentSW: Int
    let percentSM: Int
    let percentGW: Int
    let percentGM: Int
    let numReviews: Int
    var winner: CompareWinner {
        switch percentTop {
        case 51...100: return .photo1Won
        case 0...49: return .photo2Won
        default: return .itsATie // the only other case could be 50% so this is why it's a tie.
        }
    }
    
    
    public var rating: Double {
        let rawRating = (percentStrongYesTop * strongYesTopConstant) +
            (percentTop * yesTopConstant) +
            (percentBottom * yesBottomConstant) +
            (percentStrongYesBottom * strongYesBottomConstant)
        let ratingToReturn = Double(rawRating) / 100 // rawRating is out of 500, rating to return is out of 5
        return ratingToReturn.roundToPlaces(1) // returns the double with only one decimal place
    }
}

public enum dataFilterType: String {
    case targetDemo = "targetDemo"
    case friends = "friends"
    case allReviews = "allReviews"
}

public func pullConsolidatedData(from container: Container, filteredBy filterType: dataFilterType) -> isConsolidatedDataSet {
    var minAge: Int = 0
    var maxAge: Int = 100
    var straightWomen: Bool = true
    var straightMen: Bool = true
    var gayWomen: Bool = true
    var gayMen: Bool = true
    var friendsOnly: Bool
    
    switch filterType {
    case .targetDemo:
        minAge = localMyUser.targetDemo.minAge
        maxAge = localMyUser.targetDemo.maxAge
        straightWomen = localMyUser.targetDemo.straightWomenPreferred
        straightMen = localMyUser.targetDemo.straightMenPreferred
        gayWomen = localMyUser.targetDemo.gayWomenPreferred
        gayMen = localMyUser.targetDemo.gayMenPreferred
        friendsOnly = false
    case .friends:
        friendsOnly = true
    case .allReviews:
        friendsOnly = false
        
    }

    let requestedDemo: TargetDemo = TargetDemo(
        minAge: minAge,
        maxAge: maxAge,
        straightWomenPreferred: straightWomen,
        straightMenPreferred: straightMen,
        gayWomenPreferred: gayWomen,
        gayMenPreferred: gayMen)
    
    var targetDemoDataSet: isConsolidatedDataSet
    
    switch container.containerType {
    case .ask:
        targetDemoDataSet = container.reviewCollection.pullConsolidatedAskData(requestedDemo: requestedDemo, friendsOnly: friendsOnly)
    case .compare:
        targetDemoDataSet = container.reviewCollection.pullConsolidatedCompareData(requestedDemo: requestedDemo, friendsOnly: friendsOnly)
    }
    
    // to use this on the receiving end, we will have to cast this to the right type of consolidated data set (ask or compare).
    return targetDemoDataSet
}

public struct DataDisplayTool {
    // To use this tool, cut and paste the graphical hearts in their container to the place you want to use it,
    //  then link up the heart images as outlets.
    // Create a dataDisplayTool object in the ViewController source code using the 5 heart images.
    // To display the right number of hearts, call the displayIcons() method for the particular dataDisplayTool object,
    //  passing the appropriate data set and set the forBottom flag to true only if these 5 hearts will be displaying
    //  data for the second (bottom) image of a compare.
    
    
    let goodImage: UIImage = #imageLiteral(resourceName: "Heart Yellow")
    let halfImage: UIImage = #imageLiteral(resourceName: "Heart Half Yellow")
    let badImage: UIImage = #imageLiteral(resourceName: "Heart Black 2")
    
    let icon0: UIImageView
    let icon1: UIImageView
    let icon2: UIImageView
    let icon3: UIImageView
    let icon4: UIImageView

    // rating is a Double from 0.0 to 5.0
    func displayIcons(dataSet: isConsolidatedDataSet, forBottom bottom: Bool){
        
        let imageViews: [UIImageView] = [icon0, icon1, icon2, icon3, icon4]
        
        // calculate percentage rating based on aggregated yes and strong yes data:
        var ratingValue: Double = dataSet.rating // this returns the score for the top (for compare Compares) or only image (as in an Ask)
        
        print("Preparing to output hearts for a rating value of \(ratingValue)")
        
        if bottom { // if we're displaying the bottom image's results, use the inverse
            ratingValue = 5.0 - ratingValue
        }
        
        var imageIndexValue: Double = 0.0
        for imageView in imageViews {
            // ex: for position 2 (the 3rd heart), if the rating is 2.5, the imageIndexValue of 2 will be subtracted leaving 0.5
            //  meaning that 0.5 is less than 0.9 and will therefore display the bad image aka black (empty) heart.
            print("rating value is: \(ratingValue)")
            print("imageIndexValue is: \(imageIndexValue)")
            
            print("ratingValue - imageIndexValue = \(ratingValue - imageIndexValue)")
            if (ratingValue - imageIndexValue) > 0.9 {
                imageView.image = goodImage
                print("selected yellow heart")
            } else if (ratingValue - imageIndexValue) > 0.4 {
                imageView.image = halfImage
                print("selected half heart")
            } else {
                imageView.image = badImage
                print("selected black heart")
            }
            imageIndexValue += 1
        }
    }

    
}


// an "Ask" is an object containing a single image to be rated
// (and its associated values)
open class Ask: Question {
    
    var askTitle: String
    //var askRating: Double
    let askPhoto: UIImage
    open var type: askOrCompare = .ask
    let askCaption: Caption
    public var containerID: ContainerIdentification // it seems stupid that this has to be public but the compiler is forcing me to make it that way
    
    // This loads breakdown with 4 fully initialized AskDemo objects because they don't require parameters to initialize
    let breakdown = Breakdown(straightWomen: AskDemo(), straightMen: AskDemo(), gayWomen: AskDemo(), gayMen: AskDemo())
    
    // uses the timePosted to return a string of the timeRemaining
    var timeRemaining: String {
        return calcTimeRemaining(containerID.timePosted)
    }
    
    var askRating: Double {
        // As of 2Aug17 we are not using this breakdown anymore. Reviews are stored in the holding container's ReviewCollection, not in the question itself.
        
        let numSW = breakdown.straightWomen as! AskDemo
        let numSM = breakdown.straightMen as! AskDemo
        let numGW = breakdown.gayWomen as! AskDemo
        let numGM = breakdown.gayMen as! AskDemo
        
        // Please ensure when they get ratings they also get votes
        print("numSW: \(numSW.rating)")
        print("numSM: \(numSM.rating)")
        print("numGW: \(numGW.rating)")
        print("numGM: \(numGM.rating)")
        
        
        let numerator: Double = numSW.rating * Double(numSW.numVotes) + numSM.rating * Double(numSM.numVotes) + numGW.rating * Double(numGW.numVotes) + numGM.rating * Double(numGM.numVotes)
        let denominator: Double = (Double(numSW.numVotes) + Double(numSM.numVotes) + Double(numGW.numVotes) + Double(numGM.numVotes))
        if denominator <= 0 { // denominator is 0 if there are no votes yet for this ask
            return -1.0 // this negative number will be a signal to the label to display "no votes yet"
        } else {
            return numerator/denominator
        }
    }
    
    open var numVotes: Int {
        let numSW = breakdown.straightWomen as! AskDemo
        let numSM = breakdown.straightMen as! AskDemo
        let numGW = breakdown.gayWomen as! AskDemo
        let numGM = breakdown.gayMen as! AskDemo
        
        return numSW.numVotes + numSM.numVotes + numGW.numVotes + numGM.numVotes
    }

    init(title: String, photo: UIImage,caption: Caption) {
        askTitle = title
        askPhoto = photo
        askCaption = caption
        self.containerID = createContainerID() //automatically creates a containerID when you make a new Ask
        print("containerID created for ask. userID: \(self.containerID.userID), containerNumber: \(self.containerID.containerNumber), timePosted: \(self.containerID.timePosted)")
        
    }
    // This extra init method is for dummy Asks where we assign the object a hard coded timePosted rather that obtaining it at the time of creation.
    // This is because the dummy values are created in such quick succession that they all have the same timePosted and thus end up with the same ContainerIDs
    init(dummyValueTime timePosted: Date, title: String, photo: UIImage,caption: Caption) {
        askTitle = title
        askPhoto = photo
        askCaption = caption
        self.containerID = createContainerID() //automatically creates a containerID when you make a new Ask
        // switch the containerID's timePosted to our hard coded value parameter:
        containerID.timePosted = timePosted
        print("containerID created for ask. userID: \(self.containerID.userID), containerNumber: \(self.containerID.containerNumber), timePosted: \(self.containerID.timePosted)")
        
    }
}


//  a "Compare" is an object holding the two images to compare
//  (and its associated values)

enum CompareWinner: String {
    case photo1Won
    case photo2Won
    case itsATie
}


//I'm commenting this out because I don't think this method is actually ever used:
/*
public func createAsk (){
    // create a new Ask using the photo, title, and timestamp
    // will also need to implement a caption string (using the editor)
    let newAsk = Ask(title: currentTitle, photo: currentImage, timePosted: NSDate()/*,caption: nil*/)
    
    
    print("New Ask Created! title: \(newAsk.askTitle), timePosted: \(newAsk.timePosted)")
    // Once the Ask is created it is appended to the main array
    
    
    
    
    // The main array will be sorted by time stamp by the AskTableViewController prior to being displayed in the table view.
}
*/ //Should be deleted in later versions. Doesn't seem to do anything at all.

open class Compare: Question {
    
    open var type: askOrCompare = .compare
    
    //first image (displayed on top or left)
    var compareTitle1: String
    let comparePhoto1: UIImage
    let compareCaption1: Caption

    
    //second image (displayed on bottom or right)
    var compareTitle2: String
    let comparePhoto2: UIImage
    let compareCaption2: Caption
    
    public var containerID: ContainerIdentification
    //open var timePosted: Date // this is in ContainerID now
    
    let breakdown = Breakdown(straightWomen: CompareDemo(), straightMen: CompareDemo(), gayWomen: CompareDemo(), gayMen: CompareDemo())
    
    // uses the timePosted to return a string of the timeRemaining
    var timeRemaining: String {
        return calcTimeRemaining(containerID.timePosted)
    }
    
    
    // I don't use these next two computed properties for anything anymore:
    
    var compareVotes1: Int {
        let sW = breakdown.straightWomen as! CompareDemo
        let sM = breakdown.straightMen as! CompareDemo
        let gW = breakdown.gayWomen as! CompareDemo
        let gM = breakdown.gayMen as! CompareDemo
        return sW.votesForOne + sM.votesForOne + gW.votesForOne + gM.votesForOne
    }
    
    var compareVotes2: Int {
        let sW = breakdown.straightWomen as! CompareDemo
        let sM = breakdown.straightMen as! CompareDemo
        let gW = breakdown.gayWomen as! CompareDemo
        let gM = breakdown.gayMen as! CompareDemo
        return sW.votesForTwo + sM.votesForTwo + gW.votesForTwo + gM.votesForTwo
    }
    
    // winner is a computed property returning a string characterizing the
    // number of the image that has more votes
    // Ex: "photo1Won" means the photo on the left/top has more votes.
    // This is used to determine which way the arrow points in the
    // user reviews section and which photo lights up in the Compare1 view.
    
    
    // This needs to move to the ReviewCollection class
    var winner: String {
        if self.compareVotes1 > self.compareVotes2 {
            return CompareWinner.photo1Won.rawValue
        } else if self.compareVotes1 < self.compareVotes2 {
            return CompareWinner.photo2Won.rawValue
        } else if self.compareVotes1 == self.compareVotes2 {
            return CompareWinner.itsATie.rawValue
        }
        else {
            print("Data Models: Error. Votes are not >,<, or =")
            print("compareVotes1: \(compareVotes1), compareVotes2: \(compareVotes2)")
            fatalError()
        }
    }
    
    // If we even use this, it needs to move to the ReviewCollection class
    open var numVotes: Int {
        let numSW = breakdown.straightWomen as! CompareDemo
        let numSM = breakdown.straightMen as! CompareDemo
        let numGW = breakdown.gayWomen as! CompareDemo
        let numGM = breakdown.gayMen as! CompareDemo
        
        return numSW.numVotes + numSM.numVotes + numGW.numVotes + numGM.numVotes
    }

    init(title1: String, photo1: UIImage, caption1: Caption, title2: String, photo2: UIImage, caption2: Caption) {
        
        compareTitle1 = title1
        comparePhoto1 = photo1
        compareCaption1 = caption1
        compareTitle2 = title2
        comparePhoto2 = photo2
        compareCaption2 = caption2
        containerID = createContainerID()
        print("containerID created for compare. userID: \(containerID.userID), containerNumber: \(containerID.containerNumber), timePosted: \(self.containerID.timePosted)")
    }
    // This extra init method is for dummy Asks where we assign the object a hard coded timePosted rather that obtaining it at the time of creation.
    // This is because the dummy values are created in such quick succession that they all have the same timePosted and thus end up with the same ContainerIDs
    init(dummyValueTime timePosted: Date, title1: String, photo1: UIImage, caption1: Caption, title2: String, photo2: UIImage, caption2: Caption) {
    
        compareTitle1 = title1
        comparePhoto1 = photo1
        compareCaption1 = caption1
        compareTitle2 = title2
        comparePhoto2 = photo2
        compareCaption2 = caption2
        containerID = createContainerID()
        // switch the containerID's timePosted to our hard coded value parameter:
        containerID.timePosted = timePosted
        print("containerID created for compare. userID: \(containerID.userID), containerNumber: \(containerID.containerNumber), timePosted: \(self.containerID.timePosted)")
    }
}

// MARK: BREAKDOWN
// Here we set up the necessary structure to organize and store
// information about the breakdown of votes from various demographics

/////
//////
/* I'm trying to remember why the heck I did it this way rather than just having one demo for both Ask's and Compare's */
//////
/////

protocol hasOrientation {
    //  avgAge might not exist if there are no votes from that category yet
    var avgAge: Double? {get set}
    var numVotes: Int {get}
}

// an AskDemo object represents a specifc demographic's numbers within an Ask's Breakdown
class AskDemo: hasOrientation {
    var avgAge: Double? = nil
    var rating: Double = 0.0
    var numVotes: Int = 0
    
}

// a CompareDemo object represents a specifc demographic's numbers within an Ask's Breakdown
class CompareDemo: hasOrientation {
    var avgAge: Double? = nil
    var votesForOne: Int = 0
    var votesForTwo: Int = 0
    var numVotes: Int {
        return votesForOne + votesForTwo
    }
}

// This is currently not being used for anything:
struct Breakdown {
    
    // All breakdown really does for us is give us the average age and number of votes
    
    let straightWomen: hasOrientation
    let straightMen: hasOrientation
    let gayWomen: hasOrientation
    let gayMen: hasOrientation
    
    // The total number of ratings or votes that this compare or ask has received
    var numVotes: Int {
        return straightMen.numVotes + straightWomen.numVotes +  gayWomen.numVotes + gayMen.numVotes
    }
    
    var avgAge: Double {
        // These are the components of the overall average age that each demographic makes up.
        // For example, if only straight people have rated the ask, the gay components will be zero
        // In this same case, if the avg straight man was 30 and the avg straight woman was 20
        // and there were an equal number of male and female raters, the value for 
        // straightMenAverageAgeWeighted would be 15 (because 30*.5 = 15) and the value for
        // straightWomenAverageAgeWeighted would be 10 (because 20*.5 = 10) and
        // when we add all 4 components together at the end (10 + 15 + 0 + 0), we get 25, which is the correct answer
        let straightWomenAverageAgeWeighted: Double
        let straightMenAverageAgeWeighted: Double
        let gayWomenAverageAgeWeighted: Double
        let gayMenAverageAgeWeighted: Double
        
        // these if lets are necessary to unwrap avgAge which is optional
        if let swAA = straightWomen.avgAge {
            // this is actually a fraction, not a percentage because it is less than one
            // to technically be a percentage we would multiply this number by 100:
            let percentStraightWomen = Double(straightWomen.numVotes/self.numVotes)
            straightWomenAverageAgeWeighted = percentStraightWomen * swAA
        } else {
            // if the avgAge value for a demographic is nil, we store zero to the
            // straightWomenAverageAgeWeighted component because there are no votes from that demo.
            straightWomenAverageAgeWeighted = 0
        }
        if let smAA = straightMen.avgAge {
            let percentStraightMen = Double(straightMen.numVotes/self.numVotes)
            straightMenAverageAgeWeighted = percentStraightMen * smAA
        } else {
            straightMenAverageAgeWeighted = 0
        }
        if let gwAA = gayWomen.avgAge {
            let percentGayWomen = Double(gayWomen.numVotes/self.numVotes)
            gayWomenAverageAgeWeighted = percentGayWomen * gwAA
        } else {
            gayWomenAverageAgeWeighted = 0
        }
        if let gmAA = gayMen.avgAge {
            let percentGayMen = Double(gayMen.numVotes/self.numVotes)
            gayMenAverageAgeWeighted = percentGayMen * gmAA
        } else {
            gayMenAverageAgeWeighted = 0
        }

        return straightWomenAverageAgeWeighted + straightMenAverageAgeWeighted + gayWomenAverageAgeWeighted + gayMenAverageAgeWeighted
    }
    
}

public struct Caption {
    var text: String
    //this way we can check to see if a caption exists for the give Ask or Compare
    var exists: Bool {
        if text == "" { return false }
        else { return true }
    }

    var yLocation: CGFloat //a number <= 1 and >= 0 that specifies where on the image the caption y value should be in terms of a ratio. 0.0 is the top and 1.0 is the bottom, 0.5 is the center. We must convert to this number when setting it and convert from it to use it to position the caption correctly.
    
    /*init(txt: String) {
        text = ""
        //exists = false
        //need to initialize yLocation, this is a placeholder:
        yLocation = 0.1
    }*/
}


// a "Review" is a protocol that governs AskReview's and CompareReview's

public protocol isAReview {  // I am still undecided whether to attach the whole user object to a review or just the username and some simple info
    // The big thing to decide is whether to attach the reviewing user's picture to the review because that's more memory
    // Maybe just reference the picture from the server if the user de
    var reviewID: ReviewID {get}
    var reviewerName: String {get} // this might need to be displayName instead
    var reviewerOrientation: orientation {get}
    var reviewerAge: Int {get}
    var comments: String {get set}
    var reviewerInfo: PublicInfo {get set}
}


public struct ReviewID {
    let containerID: ContainerIdentification
    let reviewerID: String //this is just the reviewer's username
}


// move this to the top after integrating into Reviews
public enum reportType: String {
    case nudity = "Nudity"
    case demeaning = "Demeaning Content"
    case notRelevant = "Not Relevant"
    case other = "Other"
    case cancel = "Cancel"
}

// an "AskReview" is a review of an Ask from a single individual
// AskReviews are held in an array of AskReviews that is part of the Ask.
// This array is known as the Ask's "reviewCollection"

public struct AskReview: isAReview {
    
    public var reviewID: ReviewID
    var selection: yesOrNo
    var strong: yesOrNo?
    public var reviewerInfo: PublicInfo
    public var reviewerName: String {return reviewerInfo.displayName }
    public var reviewerOrientation: orientation { return reviewerInfo.orientation }
    public var reviewerAge: Int { return reviewerInfo.age }
    public var comments: String
    
    init(selection sel: yesOrNo, strong strg: yesOrNo?, comments c: String, containerID: ContainerIdentification) {
        selection = sel
        strong = strg
        reviewerInfo = localMyUser.publicInfo
        comments = c
        reviewID = ReviewID(containerID: containerID, reviewerID: reviewerInfo.userName)
    }
    
    // this only exists to facilitate dummy reviews:
    // Normally we would never create a review for someone else, only for ourselves aka myUser
    init(selection sel: yesOrNo, strong strg: yesOrNo?, reviewerInfo p: PublicInfo, comments c: String, containerID: ContainerIdentification) {
        selection = sel
        strong = strg
        comments = c
        reviewerInfo = p
        reviewID = ReviewID(containerID: containerID, reviewerID: p.userName)
    }
}

// a "CompareReview" is a review of an Compare from a single individual
// CompareReviews are held in an array of CompareReviews that is part of the Compare.
// This array is known as the Compare's "reviewCollection"

public struct CompareReview: isAReview {
    
    public var reviewID: ReviewID
    var selection: topOrBottom
    var strongYes: Bool
    var strongNo: Bool
    public var reviewerInfo: PublicInfo
    public var reviewerName: String {return reviewerInfo.displayName }
    public var reviewerOrientation: orientation { return reviewerInfo.orientation }
    public var reviewerAge: Int { return reviewerInfo.age }
    public var comments: String
    
    init(selection sel: topOrBottom, strongYes strgY: Bool, strongNo strgN: Bool, comments c: String, containerID: ContainerIdentification) {
        selection = sel
        strongYes = strgY
        strongNo = strgN
        comments = c
        reviewerInfo = localMyUser.publicInfo
        reviewID = ReviewID(containerID: containerID, reviewerID: reviewerInfo.userName)

    }
    
    // this only exists to facilitate dummy reviews:
    // Normally we would never create a review for someone else, only for ourselves aka myUser
    init(selection sel: topOrBottom, strongYes strgY: Bool, strongNo strgN: Bool, reviewerInfo p: PublicInfo, comments c: String, containerID: ContainerIdentification) {
        selection = sel
        strongYes = strgY
        strongNo = strgN
        comments = c
        reviewerInfo = p
        reviewID = ReviewID(containerID: containerID, reviewerID: p.userName)
    }
    
}


// this struct should probably be in the database file, not down here
public struct Friendship {
    var user1: String
    var user2: String
    var friendshipID: String {
        return user1 + "%" + user2 // this value will serve as the primary key in the database
    }
    //var requestPending: Bool
}


// This seems like it should no be in User; we don't store the containers under User anymore
public class User {
    var password: String
    var emailAddress: String
    var publicInfo: PublicInfo // this is the information that gets appended to reviews that the user makes
    var targetDemo: TargetDemo
    var containerIDCollection: [ContainerIdentification]
    var friendNames: [String]
    var lockedContainers: [ContainerIdentification]
    // This keeps track of how many reviews need to be performed to open the next container:
    var obligatoryReviewsToUnlockNextContainer: Int
    
    init(password: String, emailAddress: String,
        publicInfo: PublicInfo){
        
        self.password = password
        self.emailAddress = emailAddress
        self.publicInfo = publicInfo
        self.targetDemo = TargetDemo() // creates a generic TargetDemo with all demos and ages enabled
        
        containerIDCollection = []
        friendNames = []
        lockedContainers = []
        obligatoryReviewsToUnlockNextContainer = 0
    }
    
    func unlockOneContainer() {
        // Take the first container off the locked list
        lockedContainers.removeFirst()
        // reset the number of reviews required to unlock the next one
        if lockedContainers.count > 0 {
            obligatoryReviewsToUnlockNextContainer = obligatoryReviewsPerContainer
        } else {
            obligatoryReviewsToUnlockNextContainer = 0
        }
        refreshUserProfile()
    }
    
    func remove(containerID: ContainerIdentification) {
        
        let containerIndex: Int = index(of: containerID, containersArray: localContainerCollection)
        
        if localContainerCollection[containerIndex].isLocked() {
            // Decrement the reviews required by 3.
            for _ in 1...3 {
                localMyUser.removeOneObligatoryReview()
            }
        }
        
        // I need to: also delete the container from localContainers
        localContainerCollection.remove(at: containerIndex)
        
        // Add containerID to undeletedContainers
        undeletedContainers.append(containerID)
        // Refresh containers with the simulated database
        refreshContainers()
        
        // I will also want a method that asks whether they bought/wore the item. This should only activate if the containers was already unlocked.
    }
    
    func addLockedContainer(containerID: ContainerIdentification) {
        // This should only happen if there are not yet any locked containers:
        if obligatoryReviewsToUnlockNextContainer == 0 {
            obligatoryReviewsToUnlockNextContainer = obligatoryReviewsPerContainer
        }
        
        lockedContainers.append(containerID)
    }
    
    func removeOneObligatoryReview() {
        if obligatoryReviewsToUnlockNextContainer > 0 {
            obligatoryReviewsToUnlockNextContainer =  obligatoryReviewsToUnlockNextContainer - 1
            if obligatoryReviewsToUnlockNextContainer == 0 {
                unlockOneContainer()
            }
        }
        // if it's not greater than zero, that means it should be at zero, meaning we don't have to do anything because there shouldn't be any locked containers
    }
    
    func reviewsRequiredToUnlock(containerID: ContainerIdentification) -> Int {
        // tells how many reviews user has to do before getting access to a specific container
        if indexOf(containerID: containerID, in: lockedContainers) == -1 {
            return 0 //in this case, the container is not in the list and is therefore already unlocked. We return 0 to indicate that. 
        }
        return (obligatoryReviewsPerContainer * indexOf(containerID: containerID, in: lockedContainers)) + obligatoryReviewsToUnlockNextContainer
    }
    
    // We will get rid of this soon:
    // we don't need container number. We just need username and timePosted
    func lowestAvailableContainerIDNumber() -> Int {
        var IDNumbers: [Int] = []
        for container in containerIDCollection {
            IDNumbers.append(container.containerNumber)
        }
        // sort IDNumbers in ascending order
        IDNumbers = IDNumbers.sorted { $0 < $1 }
        var index: Int = 0
        for thisNumber in IDNumbers {
            switch thisNumber {
            case index: // if index == thisNumber, then the number is already taken and cannot be used as a new container's ID number
                index += 1 // increment index by 1,
                continue   //  then look at the next number to see if it is equal to the new index value
            default:
                print("index = \(index), thisNumber = \(thisNumber)")
                return index // if index != thisNumber, that means the number is available
            }
        }
        // if we get to this point without returning an Int yet, it means the array
        //  had no gaps in it and the lowest number available is the next one in sequence (higher than any of the existing ones).
        return index // at this point index is one number higher than the highest value so we return it.
    }
    
    /* objects that still need to be created:
    var defaultSendSettings:

    var displaySettings:
    var privacySettings:
    var friendCollection
    //also FB login settings? Not sure how to do that..
    */ 
}

public struct TargetDemo {
    var minAge: Int
    var maxAge: Int
    var straightWomenPreferred: Bool
    var straightMenPreferred: Bool
    var gayWomenPreferred: Bool
    var gayMenPreferred: Bool
    
    init(){
        // A target demo defaults to accepting everyone upon creation
        // User can adjust their settings later as appropriate
        minAge = 18
        maxAge = 150
        straightWomenPreferred = true
        straightMenPreferred = true
        gayWomenPreferred = true
        gayMenPreferred = true
    }
    
    init(minAge: Int, maxAge: Int, straightWomenPreferred: Bool, straightMenPreferred: Bool, gayWomenPreferred: Bool, gayMenPreferred: Bool){
        // In this initializer we can create a specific TargetDemo
        self.minAge = minAge
        self.maxAge = maxAge
        self.straightWomenPreferred = straightWomenPreferred
        self.straightMenPreferred = straightMenPreferred
        self.gayWomenPreferred = gayWomenPreferred
        self.gayMenPreferred = gayMenPreferred
    }
    
}

public struct PublicInfo { //this will always be implemented as a part of a User
    var userName: String
    var displayName: String
    var profilePicture: UIImage?
    var birthday: Date
    var age: Int { return ageIfBorn(on: birthday) }
    var orientation: orientation
    var signUpDate: Date
    var reviewsRated: Int
    var reviewerScore: Double
    
    init(userName: String, displayName: String, profilePicture: UIImage?, birthday: String, orientation: orientation){
        
        self.userName = userName
        self.displayName = displayName
        
        if let thisProfilePicture = profilePicture {
            self.profilePicture = thisProfilePicture
        } else {
            self.profilePicture = #imageLiteral(resourceName: "generic_user")
        }
        
        // convert the string birthday into a date birthday and store to user's properties:
        formatter.dateFormat = "MMM dd, yyyy"
        if let thisBirthday: Date = formatter.date(from: birthday) {
            self.birthday = thisBirthday // just set their birthday to right now instead - this is going to need tweaking
        } else {
            print("ageIfBorn(on birthday: String): -- Cannot compute age. Birthday passed in incorrect format.")
            // not sure if we should throw some kind of error here.
            self.birthday = Date() // just set their birthday to right now instead - this is going to need tweaking
        }

        self.orientation = orientation
        
        signUpDate = Date() // aka right now
        reviewsRated = 0 // because the user is brand new
        reviewerScore = 0.0 // because the user is brand new
    }
}



public struct imageBeingEdited {
    var iBEtitle: String
    var iBEcaption: Caption
    var iBEimageCleanUncropped: UIImage
    var iBEimageBlurredUncropped: UIImage
    var iBEimageBlurredCropped: UIImage
    var iBEContentOffset: CGPoint
    var iBEZoomScale: CGFloat
    var blursAdded: Bool = false
    
}

public enum compareImageState: String {
    case noPhotoTaken          // state 0
    case firstPhotoTaken       // state 1
    case secondPhotoTaken      // state 2
    case reEditingFirstPhoto   // state 3
    case reEditingSecondPhoto  // state 4
}



public struct compareBeingEdited {
    var isAsk: Bool
    var imageBeingEdited1: imageBeingEdited?
    var imageBeingEdited2: imageBeingEdited?
    var creationPhase: compareImageState = .noPhotoTaken //intializing here is kind of pointless, the auto generated intialiizer method forces us to store something new again to it anyway
}






























