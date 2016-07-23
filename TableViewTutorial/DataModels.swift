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

enum RowType: String {
    case isSingle
    case isDual
}


protocol Query {
    var rowType: String {get set}
    var timePosted: Int {get set}
    
    // MARK: Will also need to set up a timePosted requirement so the array of these objects can be sorted according to that
}





class Ask: Query {
    
    var askTitle: String
    var askRating: Double
    let askPhoto: UIImage
    var rowType: String = "\(RowType.isSingle)"
    var timePosted: Int

    
    init(title: String, photo: UIImage, timePosted time: Int) {
        askTitle = title
        askRating = 0.0
        askPhoto = photo
        timePosted = time
    }
}

//  a "Compare" is an object holding the two images to compare
//  and thier associated values

enum CompareWinner: String {
    case photo1Won
    case photo2Won
    case itsATie
}

class Compare: Query {
    //first image (displayed on top or left)
    var compareTitle1: String
    var compareVotes1: Int
    let comparePhoto1: UIImage

    
    //second image (displayed on bottom or right)
    var compareTitle2: String
    var compareVotes2: Int
    let comparePhoto2: UIImage
    
    var timePosted: Int

    
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
    
    var rowType: String = "\(RowType.isDual)"
    
    // MARK: Also need to implement a timePosted value *********************
    
    init(title1: String, photo1: UIImage, title2: String, photo2: UIImage, timePosted time: Int) {
        
        compareTitle1 = title1
        compareVotes1 = 0 //initialize this object with zero votes
        comparePhoto1 = photo1
        
        compareTitle2 = title2
        compareVotes2 = 0 //initialize this obejct with zero votes also
        comparePhoto2 = photo2
        
        timePosted = time
    }
}






















