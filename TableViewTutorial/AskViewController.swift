//
//  DetailViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/12/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit



class AskViewController: UIViewController {
    
    
    @IBOutlet weak var askRatingLabel: UILabel!
    @IBOutlet weak var askImageView: UIImageView!
    @IBOutlet weak var askTimeRemainingLabel: UILabel!
    //@IBOutlet weak var detailDescriptionLabel: UILabel!
    
    //var detailText: String = ""
    //var ask: Ask = Ask(title: "blank", rating: 11, photo: UIImage(named: "defaultPhoto")! )
    
    var ask: Ask? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    
    func configureView() {
        print("configuring ask view")

        // unwraps the ask that the tableView sent over:
        if let thisAsk = self.ask {
            
            // unwraps the ratingLabel from the IBOutlet
            if let thisLabel = self.askRatingLabel {
                thisLabel.text = "\(thisAsk.askRating.roundToPlaces(1))"
            }
            // unwraps the imageView from the IBOutlet
            if let thisImageView = self.askImageView {
                thisImageView.image = thisAsk.askPhoto
            }
            // unwraps the timeRemaining from the IBOutlet
            if let thisTimeRemaining = self.askTimeRemainingLabel {
                thisTimeRemaining.text = "\(thisAsk.timePosted)"
            }
            
        } else {
            print("Looks like ask is nil")
        }
            
    }
    
        


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! AskBreakDownViewController
        // Pass the selected object to the new view controller:
        controller.ask = self.ask
    }
    
    
    
    
    
}

