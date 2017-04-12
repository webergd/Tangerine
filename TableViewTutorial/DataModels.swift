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

// MARK: MAIN VARIABLES
public var currentImage: UIImage = UIImage(named: "tangerineImage2")!
public var currentTitle: String = "" //realistically this should probably be an optional
public var currentCaption: Caption = Caption(text: "", yLocation: 0.0)
public var mainArray: [Container] = [] // an array of 'Containers' aka it can hold asks and compares
// when this is true, we will use the photo info taken in from user to create a compare instead of a simple ask. The default, as you can see, is false, meaning we default to creating an Ask
public var isCompare: Bool = false

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


//public var whatToCreate: objectToCreate = .ask

public enum objectToCreate: String {
    case ask
    case compare

}




// I'm supposed to change this to round(to places: Int) but to make that work I will also have to change all the places where it is implemented.
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




public protocol Question {
    var rowType: String {get set}
    var timePosted: Date {get set}
    var numVotes: Int {get}
    
    // MARK: Will also need to set up a timePosted requirement so the array of these objects can be sorted according to that
}

// The Container holds the Ask or Compare (aka Question) as well as the associated ReviewCollection
// The reason for not just adding the ReviewCollection as a property of the Question is so that 
//   on the reviewing side, we can send the reviewer Question's without also forcing the device
//   to download all associated reviews in the ReviewCollection, which they will never see or use.
// Essentially, it's an effort to save bandwidth / transmitted data.
public struct Container {
    var containerType: askOrCompare
    var question: Question
    var reviewCollection: ReviewCollection
}

public struct ReviewCollection {
    var reviewCollectionType: askOrCompare
    var reviews: [isAReview]
    
    init(type: askOrCompare) {
        reviews = [] //keep in mind, this is empty, not optional
        reviewCollectionType = type
    }
}



// an "Ask" is an object containing a single image to be rated
// (and its associated values)

open class Ask: Question {
    
    var askTitle: String
    //var askRating: Double
    let askPhoto: UIImage
    open var rowType: String = "\(RowType.isSingle)"
    open var timePosted: Date
    let askCaption: Caption
    
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
        print("inside the Ask initializer method")
        print("currentImage orientation is upright \(currentImage.imageOrientation == UIImageOrientation.up)")
        print("newAsk.image orientation is upright \(askPhoto.imageOrientation == UIImageOrientation.up)")
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
    //first image (displayed on top or left)
    var compareTitle1: String
    let comparePhoto1: UIImage
    let compareCaption1: Caption

    
    //second image (displayed on bottom or right)
    var compareTitle2: String
    let comparePhoto2: UIImage
    let compareCaption2: Caption
    
    open var timePosted: Date
    let breakdown = Breakdown(straightWomen: CompareDemo(), straightMen: CompareDemo(), gayWomen: CompareDemo(), gayMen: CompareDemo())
    
    // uses the timePosted to return a string of the timeRemaining
    var timeRemaining: String {
        return calcTimeRemaining(timePosted)
    }
    
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
    var winner: String {
        if self.compareVotes1 > self.compareVotes2 {
            return CompareWinner.photo1Won.rawValue
        } else if self.compareVotes1 < self.compareVotes2 {
            return CompareWinner.photo2Won.rawValue
        } else if self.compareVotes1 == self.compareVotes2 {
            return CompareWinner.itsATie.rawValue
        }
        else {
            print("Data Models: Something is fucked here dude. Votes are not >,<, or =")
            print("compareVotes1: \(compareVotes1), compareVotes2: \(compareVotes2)")
            fatalError()
        }
    }
    
    open var numVotes: Int {
        let numSW = breakdown.straightWomen as! CompareDemo
        let numSM = breakdown.straightMen as! CompareDemo
        let numGW = breakdown.gayWomen as! CompareDemo
        let numGM = breakdown.gayMen as! CompareDemo
        
        return numSW.numVotes + numSM.numVotes + numGW.numVotes + numGM.numVotes
    }
    
    open var rowType: String = "\(RowType.isDual)"
    
    // MARK: Also need to implement a timePosted value *********************
    // Maybe even a computed value that returns the time remaining using the timePosted
    
    init(title1: String, photo1: UIImage, caption1: Caption, title2: String, photo2: UIImage, caption2: Caption, timePosted time: Date) {
        
        compareTitle1 = title1
        comparePhoto1 = photo1
        compareCaption1 = caption1
        compareTitle2 = title2
        comparePhoto2 = photo2
        compareCaption2 = caption2
        timePosted = time
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

protocol isAReview {
    var userName: String {get set}
    var reviewerDemo: hasOrientation {get set}
    var comments: String {get set}
}



// an "AskReview" is a review of an Ask from a single individual
// AskReviews are held in an array of AskReviews that is part of the Ask.
// This array is known as the Ask's "reviewCollection"

public struct AskReview: isAReview {
    var selection: yesOrNo
    var userName: String
    var reviewerDemo: hasOrientation
    var comments: String
    var strong: yesOrNo?
}

// a "CompareReview" is a review of an Compare from a single individual
// CompareReviews are held in an array of CompareReviews that is part of the Compare.
// This array is known as the Compare's "reviewCollection"

public struct CompareReview: isAReview {
    var selection: topOrBottom
    var userName: String
    var reviewerDemo: hasOrientation
    var comments: String
    var strongYes: Bool
    var strongNo: Bool
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

































