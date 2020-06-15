//
//  CustomSegues.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 9/15/17.
//  Copyright © 2017 Freedom Electric. All rights reserved.
//

import Foundation
import UIKit

class SegueFromLeft: UIStoryboardSegue
{
    override func perform()
    {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: -src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25,
                                   delay: 0.0,
                                   //options: UIViewAnimationOptions.CurveEaseInOut,
                                   animations: {
                                    dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
                                    
                                    
        },
                                   completion: { finished in
                                   src.present(dst, animated: false, completion: nil)

        }
        )
    }
}

class SegueFromRight: UIStoryboardSegue
{
    override func perform()
    {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        // The only difference for this one is the lack of minus sign in front of src
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       //options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
                
                
        },
            completion: { finished in
                src.present(dst, animated: false, completion: nil)
                
        }
        )
    }
    
}


class SegueOverContextFromRight: UIStoryboardSegue
{
    override func perform()
    {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        // The only difference for this one is the lack of minus sign in front of src
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       //options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
                
                
        },
            completion: { finished in
                dst.modalPresentationStyle = .overCurrentContext
                src.present(dst, animated: false, completion: nil)
                
        }
        )
    }
    
}


// This is a work in progress that I hopefully won't need
/*
class SegueDismissToLeft: UIStoryboardSegue
{
    override func perform()
    {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        // The only difference for this one is the lack of minus sign in front of src
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       //options: UIViewAnimationOptions.CurveEaseInOut,
            animations: {
                dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
                
                
        },
            completion: { finished in
                dst.modalPresentationStyle = .overCurrentContext
                src.present(dst, animated: false, completion: nil)
                
        }
        )
    }
    
}
*/

public func dismissLeft(thisVC: UIViewController) {
    let transition: CATransition = CATransition()
    transition.duration = 0.25
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    transition.type = CATransitionType.reveal
    transition.subtype = CATransitionSubtype.fromLeft
    thisVC.view.window!.layer.add(transition, forKey: nil)
    thisVC.dismiss(animated: false, completion: nil)
}












