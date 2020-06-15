//
//  File.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 3/8/17.
//  Copyright © 2017 Freedom Electric. All rights reserved.
//


// This is not being used right now.

// Later on I'd like to implement something like this in order to make swiping between view controllers look better

// It should make the transition look more like snapchat or instagram

// It's from this website: http://stackoverflow.com/questions/36972102/how-to-perform-a-segue-with-a-swipe-right-gesture

/*
import UIKit

class fromLeftToRightSegue: UIStoryboardSegue {
    override func perform() {
        
        let firstVC = self.sourceViewController.view as UIView!
        let secondVC = self.destinationViewController.view as UIView!
        
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        
        secondVC.frame = CGRectMake(-screenWidth, 0, screenWidth, screenHeight)
        
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(secondVC, aboveSubview: firstVC)
        
        // Animate the transition.
        UIView.animateWithDuration(0.3, animations: { () -> Void in // set animation duration
            
            firstVC.frame = CGRectOffset(firstVC.frame, 0.0, 0.0) // old screen stay
            
            secondVC.frame = CGRectOffset(secondVC.frame, screenWidth, 0.0) // new screen strave from left to right
            
        }) { (Finished) -> Void in
            self.sourceViewController.presentViewController(self.destinationViewController as UIViewController,
                                                            animated: false,
                                                            completion: nil)
        }
    }
    
}
*/
