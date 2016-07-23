//
//  CompareViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/22/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class CompareViewController: UIViewController {
    
    //Need UI outlets for images and Label
    
    
    var compare: Compare? {
        didSet {
            // Update the view.
            //self.configureView()
        }
    }
    
   /* func configureView() {
        print("configuring view")
        // unwraps the ask that the tableView sent over:
        if let thisCompare = self.compare {
            // unwraps the ratingLabel from the IBOutlet
            if let thisLabel = self.askRatingLabel {
                print("passed rating is: \(thisAsk.askRating)")
                thisLabel.text = "\(thisAsk.askRating)"
            }
            // unwraps the imageView from the IBOutlet
            if let thisImageView = self.askImageView {
                thisImageView.image = thisAsk.askPhoto
            }
            
        } else {
            print("Looks like ask is nil")
        }
        
    } */

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
