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

// MARK: MAIN VARIABLES
public var currentImage: UIImage = UIImage(named: "tangerineImage2")!
public var currentTitle: String = "" //realistically this should probably be an optional
public var mainArray: [Query] = [] // an array of 'Queries' aka it can hold asks and compares
// when this is true, we will use the photo info taken in from user to create a compare instead of a simple ask. The default, as you can see, is false, meaning we default to creating an Ask
public var isCompare: Bool = false

//this allows for hard dates to be created for test examples
public let formatter = NSDateFormatter()

// This determines how long the compares and asks will be displayed before they expire.
// It's a var so that we can change it at runtime in the future if we need to.
// 5 hours is 5 * 3600 => 18,000 seconds
public var displayTime: NSTimeInterval = 18000.0


public extension Double {
    /// Rounds the double to decimal places value
    func roundToPlaces(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return round(self * divisor) / divisor
    }
}

// MARK: TIME REMAINING

public func calcTimeRemaining(timePosted: NSDate) -> String {
    let elapsedTime = NSDate().timeIntervalSinceDate(timePosted) //returns a double representing seconds
    let secondsRemaining: NSTimeInterval = displayTime - elapsedTime
    return secondsRemaining.time //applies the below extention to the NSTimeInterval (aka elapsed time, aka seconds converted to an actual time)
}

extension NSTimeInterval { //got this off the internet to convert an NSTimeInterval into a readable time String. NSTI is just a Double.
    var time:String {
        return String(format:"%02d:%02d", Int((self/3600.0)%24), Int((self/60.0)%60))
        //use this way if I want seconds to display also:
        //return String(format:"%02d:%02d:%02d", Int((self/3600.0)%24), Int((self/60.0)%60), Int((self)%60))
    }
}



public protocol Query {
    var rowType: String {get set}
    var timePosted: NSDate {get set}
    var numVotes: Int {get}
    
    // MARK: Will also need to set up a timePosted requirement so the array of these objects can be sorted according to that
}




// an "Ask" is an object containing a single image to be rated
// (and its associated values)

public class Ask: Query {
    
    var askTitle: String
    //var askRating: Double
    let askPhoto: UIImage
    public var rowType: String = "\(RowType.isSingle)"
    public var timePosted: NSDate
    
    // This loads breakdown with 4 fully initialized AskDemo objects because they don't require parameters to initialize
    let breakdown = Breakdown(straightWomen: AskDemo(), straightMen: AskDemo(), gayWomen: AskDemo(), gayMen: AskDemo())
    
    
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
        return numerator/denominator //need some error handling in case the denominator is 0
    }
    
    public var numVotes: Int {
        let numSW = breakdown.straightWomen as! AskDemo
        let numSM = breakdown.straightMen as! AskDemo
        let numGW = breakdown.gayWomen as! AskDemo
        let numGM = breakdown.gayMen as! AskDemo
        
        return numSW.numVotes + numSM.numVotes + numGW.numVotes + numGM.numVotes
    }
    

    init(title: String, photo: UIImage, timePosted time: NSDate) {
        askTitle = title
        askPhoto = photo
        timePosted = time
    }
}

//  a "Compare" is an object holding the two images to compare
//  (and its associated values)

enum CompareWinner: String {
    case photo1Won
    case photo2Won
    case itsATie
}

public func createAsk (){
    // create a new Ask using the photo, title, and timestamp
    // will also need to implement a caption string (using the editor)
    let newAsk = Ask(title: currentTitle, photo: currentImage, timePosted: NSDate())
    
    
    print("New Ask Created! title: \(newAsk.askTitle), timePosted: \(newAsk.timePosted)")
    // Once the Ask is created it is appended to the main array
    
    
    
    
    // The main array will be sorted by time stamp by the AskTableViewController prior to being displayed in the table view.
}


public class Compare: Query {
    //first image (displayed on top or left)
    var compareTitle1: String
    let comparePhoto1: UIImage

    
    //second image (displayed on bottom or right)
    var compareTitle2: String
    let comparePhoto2: UIImage
    
    public var timePosted: NSDate
    let breakdown = Breakdown(straightWomen: CompareDemo(), straightMen: CompareDemo(), gayWomen: CompareDemo(), gayMen: CompareDemo())
    
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
    
    public var numVotes: Int {
        let numSW = breakdown.straightWomen as! CompareDemo
        let numSM = breakdown.straightMen as! CompareDemo
        let numGW = breakdown.gayWomen as! CompareDemo
        let numGM = breakdown.gayMen as! CompareDemo
        
        return numSW.numVotes + numSM.numVotes + numGW.numVotes + numGM.numVotes
    }
    
    public var rowType: String = "\(RowType.isDual)"
    
    // MARK: Also need to implement a timePosted value *********************
    // Maybe even a computed value that returns the time remaining using the timePosted
    
    init(title1: String, photo1: UIImage, title2: String, photo2: UIImage, timePosted time: NSDate) {
        
        compareTitle1 = title1
        comparePhoto1 = photo1
        compareTitle2 = title2
        comparePhoto2 = photo2
        timePosted = time
    }
}

// MARK: BREAKDOWN
// Here we set up the necessary structure to organize and store
// information about the breakdown of votes from various demographics

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






























