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

public enum demo: String {
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
public let assignedQuestionsBufferSize: Int = 3
// We will use the above constant to set the length of the assignQuestions array.
// The name of the method that references it will be below and called loadAssignedQuestions()

// This will hold the containerID of Questions that the user created but has not performed the requisite number of reviews
//  yet in order to be allowed to view the results.
public var lockedContainers: [ContainerIdentification] = []
// We will have to check in AskTableView whether the container has been unlocked before we can display the results


// OBLIGATORY REVIEWS
// This keeps track of how many reviews need to be performed to open the next container:
public var obligatoryReviewsToUnlockNextContainer: Int = 0

// Sets the number of reviews required to unlock a container:
public let obligatoryReviewsPerContainer: Int = 3

public var obligatoryReviewsRemaining: Int {
    // The reason for the minus one is because obligatoryReviewsToUnlockNextContainer adds the reviews for the first container
    var additionalContainers: Int = lockedContainers.count - 1
    // If additionalContainers were allowed to drop below zero, we would get a negative value for obligatoryReviewsRemaining
    if additionalContainers < 0 { additionalContainers = 0 }
    return obligatoryReviewsToUnlockNextContainer + (additionalContainers * obligatoryReviewsPerContainer)
}
// There is also a function in DataModels that adds more obligatory reviews when a new Question is created.

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
    
    func dismissKeyboard() {
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

// calculates the caption's autolayout constraint for its distance from the top of the imageView it is being displayed over.
// Normally this constraint will actually be within a View that is acting as a container for the imageView, scrollView, and captionTextField
public func calcCaptionTextFieldTopConstraint(imageViewFrameHeight: CGFloat, captionYLocation: CGFloat) -> CGFloat {
    return imageViewFrameHeight * captionYLocation
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


public func demoToText(userDemo: demo) -> String {
    switch userDemo {
    case .straightWoman: return "Straight Woman"
    case .straightMan: return "Straight Man"
    case .gayWoman: return "Gay Woman"
    case .gayMan: return "Gay Man"
    }
}



// an awesome website for color conversion is: http://uicolor.xyz/#/hex-to-ui
public func demoSpecificColor(userDemo: demo) -> UIColor {
    switch userDemo {
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
    return ContainerIdentification(userID: myUser.publicInfo.userName,
                                   containerNumber: myUser.lowestAvailableContainerIDNumber())
}

public func unlockOneContainer() {
    // Take the first container off the locked list
    lockedContainers.removeFirst()
    // reset the number of reviews required to unlock the next one
    obligatoryReviewsToUnlockNextContainer = obligatoryReviewsPerContainer
}

public func addLockedContainer(containerID: ContainerIdentification) {
    // This should only happen if there are not yet any locked containers:
    if obligatoryReviewsToUnlockNextContainer == 0 {
        obligatoryReviewsToUnlockNextContainer = obligatoryReviewsPerContainer
    }
    
    lockedContainers.append(containerID)
}

public func removeOneObligatoryReview() {
    if obligatoryReviewsToUnlockNextContainer > 0 {
        obligatoryReviewsToUnlockNextContainer =  obligatoryReviewsToUnlockNextContainer - 1
        if obligatoryReviewsToUnlockNextContainer == 0 {
            unlockOneContainer()
        }
    }
    
    // if it's not greater than zero, that means it should be at zero, meaning we don't have to do anything because there shouldn't be any locked containers

}

public func loadAssignedQuestions() {
    // pull the first element off of the array because we may have already reviewed it
    assignedQuestions.removeFirst()
    for question in assignedQuestions {
        // Need to do this first:
        // check the age of the question here and throw it out if it's too old, then continue, i.e. start the loop over
        // We will use the "question" local variable here. Don't change it to a _
        
        // checks the assignedQuestions array size and trims off the front or adds to the back. A queue essentially.
        switch assignedQuestions.count {
        case Int.min..<assignedQuestionsBufferSize: assignedQuestions.append(fetchNewQuestion())
        case assignedQuestionsBufferSize..<Int.max: assignedQuestions.removeFirst()
        default: print("assignedQuestions loaded new question(s) and is the appropriate size")
        }
    }
    
}

// This counter is only for use with dummy Questions. It allows us to keep iterating through them.
var questionCounter: Int = 0

public func fetchNewQuestion() -> Question {
    // This will have to pull info from the database. For now we will just use dummy questions.
    if questionCounter > 4 {
        questionCounter = 0 // we only have 5 sample questions so we need to go back to the start of the array
    }
    return sampleContainers[questionCounter].question
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

// These settings will be toggled by the user, eventually
public let myTargetDemo = TargetDemo(minAge: 25, maxAge: 38, straightWomenPreferred: true, straightMenPreferred: false, gayWomenPreferred: false, gayMenPreferred: true)


public protocol Question { //this really should be isQuestion
    var type: askOrCompare {get set}
    var timePosted: Date {get set}
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
    var reviewCollection: ReviewCollection
    var numReports: Int 
    
    init(question q: Question, reviewCollection r: ReviewCollection) {
        question = q
        reviewCollection = r
        numReports = 0
    }
 
    // If we call this on a container, it will update its tracker of how many of its reviews are inappropriate content reports.
    func updateNumReports(){
        var reports: Int = 0
        for review in self.reviewCollection.reviews {
            if review.reported != .none {
                reports += 1
            }
        }
        self.numReports = reports
    }

}

public struct ContainerIdentification {
    var userID: String
    var containerNumber: Int
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

        // This switch statement checks which demo the reviewer was, and if we are
        //  trying to pull from that demo, it returns true (since we already know they 
        //  are in the appropriate age range)

        switch thisReview.reviewerDemo {
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
        // the reviewer was in the age range but was not in any of my preferred demo's
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
                if self.isTargetDemo(index: index, targetDemo: myTargetDemo) {
                    print("appending a \(String(describing: review.reviewerDemo)) to the array")
                    filteredReviewsArray.append(review)
                }
                index += 1
            }
        case .friends:
            print("filtering for friends")
            for review in reviews {
                if self.isFriend(index: index, targetDemo: myTargetDemo) {
                    filteredReviewsArray.append(review)
                }
                index += 1
            }
        }
        
        return filteredReviewsArray
    }
    // Returns aggregated data within the age and demographic specified in the arguments:
    func pullConsolidatedAskData(from lowestAge: Int, to highestAge: Int, straightWomen: Bool, straightMen: Bool, gayWomen: Bool, gayMen: Bool, friendsOnly: Bool)-> ConsolidatedAskDataSet {
        
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
            
            
            // This switch statement checks which demo the reviewer was, and if we aren't
            //  trying to pull from that demo, we go back to the beginning of the for loop.
            // If we are trying to pull from that demo, we increment that demo's count and move on.
            switch review.reviewerDemo {
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
    
    func pullConsolidatedCompareData(from lowestAge: Int, to highestAge: Int, straightWomen: Bool, straightMen: Bool, gayWomen: Bool, gayMen: Bool, friendsOnly: Bool)-> ConsolidatedCompareDataSet {
        
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
            
            
            // This switch statement checks which demo the reviewer was, and if we aren't
            //  trying to pull from that demo, we go back to the beginning of the for loop.
            // If we are trying to pull from that demo, we increment that demo's count and move on.
            switch review.reviewerDemo {
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
                                          percentStrongNoTop: Int(100 * countStrongNoTop / countReviews),
                                          percentStrongNoBottom: Int(100 * countStrongNoBottom / countReviews),
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
                                              percentStrongNoTop: 0,
                                              percentStrongNoBottom: 0,
                                              averageAge: 0,// consider returning -1 or some indicator for label to display NA
                                              percentSW: 0,
                                              percentSM: 0,
                                              percentGW: 0,
                                              percentGM: 0,
                                              numReviews: 0)
        }

    }
}

public struct ConsolidatedAskDataSet {
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
}




public struct ConsolidatedCompareDataSet {
    let percentTop: Int
    var percentBottom: Int { return 100 - percentTop }
    let percentStrongYesTop: Int
    let percentStrongYesBottom: Int
    let percentStrongNoTop: Int
    let percentStrongNoBottom: Int
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
}

// an "Ask" is an object containing a single image to be rated
// (and its associated values)

open class Ask: Question {
    
    var askTitle: String
    //var askRating: Double
    let askPhoto: UIImage
    open var type: askOrCompare = .ask
    open var timePosted: Date
    let askCaption: Caption
    public var containerID: ContainerIdentification // it seems stupid that this has to be public but the compiler is forcing me to make it that way
    
    // This loads breakdown with 4 fully initialized AskDemo objects because they don't require parameters to initialize
    let breakdown = Breakdown(straightWomen: AskDemo(), straightMen: AskDemo(), gayWomen: AskDemo(), gayMen: AskDemo())
    
    // uses the timePosted to return a string of the timeRemaining
    var timeRemaining: String {
        return calcTimeRemaining(timePosted)
    }
    
    var askRating: Double {
        
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

    init(title: String, photo: UIImage,caption: Caption, timePosted time: Date) {
        askTitle = title
        askPhoto = photo
        timePosted = time
        askCaption = caption
        containerID = createContainerID() //automatically creates a containerID when you make a new Ask
        print("containerID created for ask. userID: \(containerID.userID), containerNumber: \(containerID.containerNumber)")
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
    
    open var timePosted: Date
    let breakdown = Breakdown(straightWomen: CompareDemo(), straightMen: CompareDemo(), gayWomen: CompareDemo(), gayMen: CompareDemo())
    
    // uses the timePosted to return a string of the timeRemaining
    var timeRemaining: String {
        return calcTimeRemaining(timePosted)
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

    init(title1: String, photo1: UIImage, caption1: Caption, title2: String, photo2: UIImage, caption2: Caption, timePosted time: Date) {
        
        compareTitle1 = title1
        comparePhoto1 = photo1
        compareCaption1 = caption1
        compareTitle2 = title2
        comparePhoto2 = photo2
        compareCaption2 = caption2
        timePosted = time
        containerID = createContainerID()
        print("containerID created for compare. userID: \(containerID.userID), containerNumber: \(containerID.containerNumber)")
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

protocol isAReview {  // I am still undecided whether to attach the whole user object to a review or just the username and some simple info
    // The big thing to decide is whether to attach the reviewing user's picture to the review because that's more memory
    // Maybe just reference the picture from the server if the user de
    var reviewerName: String {get} // this might need to be displayName instead
    var reviewerDemo: demo {get}
    var reviewerAge: Int {get}
    var comments: String {get set}
    var reviewerInfo: PublicInfo {get set}
    var reported: reportType {get set}
}


// move this to the top after integrating into Reviews
public enum reportType: String {
    case nudity
    case demeaning
    case notRelevant
    case other
    case none
}

// an "AskReview" is a review of an Ask from a single individual
// AskReviews are held in an array of AskReviews that is part of the Ask.
// This array is known as the Ask's "reviewCollection"

public struct AskReview: isAReview {
    var selection: yesOrNo
    var strong: yesOrNo?
    var reviewerInfo: PublicInfo
    var reviewerName: String {return reviewerInfo.displayName }
    var reviewerDemo: demo { return reviewerInfo.orientation }
    var reviewerAge: Int { return reviewerInfo.age }
    var comments: String
    var reported: reportType
    
    init(selection sel: yesOrNo, strong strg: yesOrNo?, comments c: String) {
        selection = sel
        strong = strg
        comments = c
        reviewerInfo = myUser.publicInfo
        reported = .none // default report type is none
    }
    
    // this only exists to facilitate dummy reviews:
    // Normally we would never create a review for someone else, only for ourselves aka myUser
    init(selection sel: yesOrNo, strong strg: yesOrNo?, reviewerInfo p: PublicInfo, comments c: String) {
        selection = sel
        strong = strg
        comments = c
        reviewerInfo = p
        reported = .none // default report type is none
    }
}

// a "CompareReview" is a review of an Compare from a single individual
// CompareReviews are held in an array of CompareReviews that is part of the Compare.
// This array is known as the Compare's "reviewCollection"

public struct CompareReview: isAReview {
    var selection: topOrBottom
    var strongYes: Bool
    var strongNo: Bool
    var reviewerInfo: PublicInfo
    var reviewerName: String {return reviewerInfo.displayName }
    var reviewerDemo: demo { return reviewerInfo.orientation }
    var reviewerAge: Int { return reviewerInfo.age }
    var comments: String
    var reported: reportType = .none
    
    init(selection sel: topOrBottom, strongYes strgY: Bool, strongNo strgN: Bool, comments c: String) {
        selection = sel
        strongYes = strgY
        strongNo = strgN
        comments = c
        reviewerInfo = myUser.publicInfo
        reported = .none // default report type is none
    }
    
    // this only exists to facilitate dummy reviews:
    // Normally we would never create a review for someone else, only for ourselves aka myUser
    init(selection sel: topOrBottom, strongYes strgY: Bool, strongNo strgN: Bool, reviewerInfo p: PublicInfo, comments c: String) {
        selection = sel
        strongYes = strgY
        strongNo = strgN
        comments = c
        reviewerInfo = p
        reported = .none // default report type is none
    }
    
}

public struct User {
    var password: String
    var emailAddress: String
    var publicInfo: PublicInfo // this is the information that gets appended to reviews that the user makes
    var targetDemo: TargetDemo
    var containerCollection: [Container]
    
    func lowestAvailableContainerIDNumber() -> Int {
        var IDNumbers: [Int] = []
        for thisContainer in containerCollection {
            IDNumbers.append(thisContainer.containerID.containerNumber)
        }
        // sort IDNumbers in ascending order
        IDNumbers = IDNumbers.sorted { $0 < $1 }
        var index: Int = 0
        for thisNumber in IDNumbers {
            switch thisNumber {
            case index: // if index == thisNumber, then the number is taken
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
}

public struct PublicInfo { //this will always be implemented as a part of a User
    var userName: String
    var displayName: String
    var profilePicture: UIImage? 
    var age: Int // this should actually be birthday and then have a method to calculate age
    var orientation: demo
    var signUpDate: Date
    var reviewsRated: Int
    var reviewerScore: Double
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


  /////////////////////////////////
 /////     DUMMY VALUES:    //////
/////////////////////////////////

// this is just for the dummy reviewers

public var usersArray: [User] = []

public func loadSampleUsers(){     
    usersArray = []
    
    let genericTargetDemo: TargetDemo = TargetDemo(minAge: 0, maxAge: 100, straightWomenPreferred: true, straightMenPreferred: true, gayWomenPreferred: true, gayMenPreferred: true)
    
    let user1: User = User(password: "123", emailAddress: "yut@yut.com",
                           publicInfo: PublicInfo(userName: "guido", displayName: "Guido", profilePicture: #imageLiteral(resourceName: "guido"), age: 37, orientation: .straightMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 4.8), targetDemo: genericTargetDemo, containerCollection: [])
    let user2: User = User(password: "123", emailAddress: "yut@yut.com",
                           publicInfo: PublicInfo(userName: "beast", displayName: "Beast", profilePicture: #imageLiteral(resourceName: "beast"), age: 32, orientation: .straightMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 3.3), targetDemo: genericTargetDemo, containerCollection: [])
    let user3: User = User(password: "123", emailAddress: "yut@yut.com",
                           publicInfo: PublicInfo(userName: "uncleDanny", displayName: "Uncle Danny", profilePicture: nil, age: 69, orientation: .straightMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 1.0), targetDemo: genericTargetDemo, containerCollection: [])
    let user4: User = User(password: "123", emailAddress: "yut@yut.com",
                           publicInfo: PublicInfo(userName: "melissa", displayName: "Melissa", profilePicture: #imageLiteral(resourceName: "melissa"), age: 32, orientation: .straightWoman, signUpDate: Date(), reviewsRated: 10, reviewerScore: 4.0), targetDemo: genericTargetDemo, containerCollection: [])
    let user5: User = User(password: "123", emailAddress: "yut@yut.com",
                           publicInfo: PublicInfo(userName: "zeenat", displayName: "Zeenat", profilePicture: #imageLiteral(resourceName: "zeenat"), age: 29, orientation: .straightWoman, signUpDate: Date(), reviewsRated: 10, reviewerScore: 2.2), targetDemo: genericTargetDemo, containerCollection: [])
    let user6: User = User(password: "123", emailAddress: "yut@yut.com",
                           publicInfo: PublicInfo(userName: "morgan", displayName: "Morgan", profilePicture: #imageLiteral(resourceName: "morgan"), age: 26, orientation: .gayWoman, signUpDate: Date(), reviewsRated: 10, reviewerScore: 2.9), targetDemo: genericTargetDemo, containerCollection: [])
    let user7: User = User(password: "123", emailAddress: "yut@yut.com",
                           publicInfo: PublicInfo(userName: "ian", displayName: "Ian", profilePicture: #imageLiteral(resourceName: "ian"), age: 21, orientation: .gayMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 1.2), targetDemo: genericTargetDemo, containerCollection: [])
    let user8: User = User(password: "123", emailAddress: "yut@yut.com",
                           publicInfo: PublicInfo(userName: "countryBear", displayName: "Country Bear", profilePicture: nil, age: 33, orientation: .straightMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 3.8), targetDemo: genericTargetDemo, containerCollection: [])
    let user9: User = User(password: "123", emailAddress: "yut@yut.com",
                           publicInfo: PublicInfo(userName: "bob", displayName: "Bob", profilePicture: nil, age: 23, orientation: .gayMan, signUpDate: Date(), reviewsRated: 10, reviewerScore: 2.6), targetDemo: genericTargetDemo, containerCollection: [])
    
    // I put the reviewers in an array to avoid having to explicitly declare each user at the class level.
    // This way I just declared an empty (but not nil) array at the class level and then add to it within this method.
    usersArray.append(user1)
    usersArray.append(user2)
    usersArray.append(user3)
    usersArray.append(user4)
    usersArray.append(user5)
    usersArray.append(user6)
    usersArray.append(user7)
    usersArray.append(user8)
    usersArray.append(user9)
    
    // dummy value as usual, we will keep friendsArray though.
    friendsArray = usersArray
    
    
}

/* to load dummy values for the new data model, I need dummy asks and compares, as well as sample reviews.
 I should be able to modfiy the loadSampleAsks and loadSampleCompares methods to work within the Container paradigm.
 At that point I then just need to create the sample reviews from scratch and then load them into the ReviewCollection for the specific Questions - DONE */

// this is temporary code

public enum Shoes: String {
    case redReeboks
    case whiteConverse
    case violetVans
    case brownShiny
    case brownTooled
}

public enum Jeans: String {
    case carmenJeansLight
    case carmenJeansDark
}

let myPublicInfo: PublicInfo = PublicInfo(userName: "wyatt", displayName: "Wyatt", profilePicture: #imageLiteral(resourceName: "wyatt"), age: 33, orientation: .straightMan, signUpDate: Date(), reviewsRated: 0, reviewerScore: 5.0)
public var myUser: User = User(password: "", emailAddress: "kabar3@gmail.com", publicInfo: myPublicInfo, targetDemo: myTargetDemo, containerCollection: [])


public var sampleContainers: [Container] = []

public func loadSampleAsks() {
    
    sampleContainers = [] // this clears out sampleContainers so that each time this method runs, more copies of the same containers aren't appended to it
    
    formatter.dateFormat = "yyyy/MM/dd HH:mm"
    
    let photo1 = UIImage(named: "\(Shoes.redReeboks)")!
    let caption1 = Caption(text: "", yLocation: 0.0)
    let time1 = formatter.date(from: "2016/08/09 00:01")! //force unwrap bc it's temp anyway
    let ask1 = Ask(title: "Red Reeboks", photo: photo1, caption: caption1, timePosted: time1)
    let ask1SW = ask1.breakdown.straightWomen as! AskDemo
    let ask1GM = ask1.breakdown.gayMen as! AskDemo
    ask1SW.rating = 5
    ask1SW.numVotes = 1
    ask1GM.rating = 6
    ask1GM.numVotes = 10
    
    let container1 = Container(question: ask1, reviewCollection: ReviewCollection(type: .ask))
    
    let photo2 = UIImage(named: "\(Shoes.whiteConverse)")!
    let caption2 = Caption(text: "", yLocation: 0.0)
    let time2 = formatter.date(from: "2016/08/09 00:11")!
    let ask2 = Ask(title: "White Converse", photo: photo2,caption: caption2, timePosted: time2)
    let ask2GW = ask2.breakdown.gayWomen as! AskDemo
    ask2GW.rating = 6
    ask2GW.numVotes = 5
    let container2 = Container(question: ask2, reviewCollection: ReviewCollection(type: .ask))
    
    let photo3 = UIImage(named: "\(Shoes.violetVans)")!
    let caption3 = Caption(text: "", yLocation: 0.0)
    let time3 = formatter.date(from: "2016/08/09 00:06")!
    let ask3 = Ask(title: "Violet Vans", photo: photo3, caption: caption3, timePosted: time3)
    let ask3SM = ask3.breakdown.straightMen as! AskDemo
    ask3SM.rating = 9.8
    ask3SM.numVotes = 90
    let container3 = Container(question: ask3, reviewCollection: ReviewCollection(type: .ask))
    
    //I think this is a pointless line of code:
    //asks += [ask1,ask2,ask3]  //+= just appends them, I believe
    //print("Asks: \(asks)")
    sampleContainers.append(container1)
    sampleContainers.append(container2)
    sampleContainers.append(container3)
}


public func loadSampleCompares() {
    
    //create a sample Jeans compare object
    let title1 = "Light Carmens"
    let photo1 = UIImage(named: "\(Jeans.carmenJeansLight)")!
    let caption1 = Caption(text: "", yLocation: 0.0)
    
    let title2 = "Dark Carmens"
    let photo2 = UIImage(named: "\(Jeans.carmenJeansDark)")!
    let caption2 = Caption(text: "", yLocation: 0.0)
    
    let time1 = formatter.date(from: "2016/08/09 00:04")!
    
    let compare1 = Compare(title1: title1, photo1: photo1, caption1: caption1, title2: title2, photo2: photo2, caption2: caption2, timePosted: time1)
    let compare1SW = compare1.breakdown.straightWomen as! CompareDemo
    let compare1SM = compare1.breakdown.straightMen as! CompareDemo
    let compare1GW = compare1.breakdown.gayWomen as! CompareDemo
    let compare1GM = compare1.breakdown.gayMen as! CompareDemo
    
    compare1SW.votesForOne = 10
    compare1SW.votesForTwo = 12
    compare1SM.votesForOne = 6
    compare1SM.votesForTwo = 33
    compare1GW.votesForOne = 3
    compare1GW.votesForTwo = 16
    compare1GM.votesForOne = 60
    compare1GM.votesForTwo = 77
    
    let container4 = Container(question: compare1, reviewCollection: ReviewCollection(type: .compare))
    
    
    //create another sample Shoes compare object
    
    let title1a = "Brown Shiny"
    let photo1a = UIImage(named: "\(Shoes.brownShiny)")!
    let caption1a = Caption(text: "", yLocation: 0.0)
    
    let title2a = "Brown Tooled"
    let photo2a = UIImage(named: "\(Shoes.brownTooled)")!
    let caption2a = Caption(text: "", yLocation: 0.0)
    
    let time2 = formatter.date(from: "2016/08/09 00:08")!
    
    let compare2 = Compare(title1: title1a, photo1: photo1a, caption1: caption1a, title2: title2a, photo2: photo2a, caption2: caption2a, timePosted: time2)
    let compare2SW = compare2.breakdown.straightWomen as! CompareDemo
    let compare2SM = compare2.breakdown.straightMen as! CompareDemo
    
    compare2SW.votesForOne = 100
    compare2SW.votesForTwo = 100
    compare2SM.votesForOne = 550
    compare2SM.votesForTwo = 550
    
    let container5 = Container(question: compare2, reviewCollection: ReviewCollection(type: .compare))
    
    
    
    sampleContainers.append(container4)
    sampleContainers.append(container5)
    
    
    
}



// requires loadSampleAsks() to be called first in order to work.
public func loadSampleAskReviews() {
    
    loadSampleUsers() // this ensures that the reviewersArray values are not nil
    
    let askReview1 = AskReview(selection: .no, strong: nil, reviewerInfo: usersArray[0].publicInfo, comments: "raising eyebrows rapidly")
    
    let askReview2 = AskReview(selection: .no, strong: nil, reviewerInfo: usersArray[1].publicInfo, comments: "I can dream a hell of a lot")
    
    let askReview3 = AskReview(selection: .no, strong: nil, reviewerInfo: usersArray[2].publicInfo, comments: "Goooooooo")
    
    let askReview4 = AskReview(selection: .no, strong: .yes, reviewerInfo: usersArray[3].publicInfo, comments: "Go team WML")
    
    let askReview5 = AskReview(selection: .no, strong: nil, reviewerInfo: usersArray[4].publicInfo, comments: "I like beet juice")
    
    let askReview6 = AskReview(selection: .no, strong: nil, reviewerInfo: usersArray[5].publicInfo, comments: "Oregon is the best")
    
    let askReview7 = AskReview(selection: .no, strong: nil, reviewerInfo: usersArray[6].publicInfo, comments: "Wanna act something out silently?")
    
    let askReview8 = AskReview(selection: .yes, strong: nil, reviewerInfo: usersArray[7].publicInfo, comments: "You suck at preflighting")
    
    let askReview9 = AskReview(selection: .yes, strong: .yes, reviewerInfo: usersArray[8].publicInfo, comments: "My name is Bob?")
    
    // this loop adds all the reviews to each ask container since 0 through 2 are Asks
    //  we only know this because we loaded 0 through 2 as asks
    for x in 0...2  {
        sampleContainers[x].reviewCollection.reviews.append(askReview1)
        sampleContainers[x].reviewCollection.reviews.append(askReview2)
        sampleContainers[x].reviewCollection.reviews.append(askReview3)
        sampleContainers[x].reviewCollection.reviews.append(askReview4)
        sampleContainers[x].reviewCollection.reviews.append(askReview5)
        sampleContainers[x].reviewCollection.reviews.append(askReview6)
        sampleContainers[x].reviewCollection.reviews.append(askReview7)
        sampleContainers[x].reviewCollection.reviews.append(askReview8)
        sampleContainers[x].reviewCollection.reviews.append(askReview9)
    }
    
    
}

// requires loadSampleCompares() to be called first in order to work.

public func loadSampleCompareReviews() {
    let compareReview1 = CompareReview(selection: .bottom, strongYes: true, strongNo: false, reviewerInfo: usersArray[0].publicInfo, comments: "raising eyebrows rapidly")
    
    let compareReview2 = CompareReview(selection: .top, strongYes: true, strongNo: false, reviewerInfo: usersArray[1].publicInfo, comments: "I can dream a hell of a lot")
    
    let compareReview3 = CompareReview(selection: .top, strongYes: true, strongNo: false, reviewerInfo: usersArray[2].publicInfo, comments: "Gooooooo")
    
    let compareReview4 = CompareReview(selection: .top, strongYes: true, strongNo: false, reviewerInfo: usersArray[3].publicInfo, comments: "Go team WML")
    
    let compareReview5 = CompareReview(selection: .top, strongYes: true, strongNo: false, reviewerInfo: usersArray[4].publicInfo, comments: "I like beet juice")
    
    let compareReview6 = CompareReview(selection: .top, strongYes: true, strongNo: false, reviewerInfo: usersArray[5].publicInfo, comments: "Oregon is the best")
    
    let compareReview7 = CompareReview(selection: .top, strongYes: true, strongNo: false, reviewerInfo: usersArray[6].publicInfo, comments: "Wanna act something out silently?")
    
    // this loop adds all the reviews to each compare container since 3 through 4 are Compares
    for x in 3...4  {
        sampleContainers[x].reviewCollection.reviews.append(compareReview1)
        sampleContainers[x].reviewCollection.reviews.append(compareReview2)
        sampleContainers[x].reviewCollection.reviews.append(compareReview3)
        sampleContainers[x].reviewCollection.reviews.append(compareReview4)
        sampleContainers[x].reviewCollection.reviews.append(compareReview5)
        sampleContainers[x].reviewCollection.reviews.append(compareReview6)
        sampleContainers[x].reviewCollection.reviews.append(compareReview7)
    }
}




























