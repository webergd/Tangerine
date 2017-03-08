//
//  AskBreakDownViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/16/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class AskBreakDownViewController: UIViewController {
    @IBOutlet weak var askImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var straightWomenRatingLabel: UILabel!
    @IBOutlet weak var straightMenRatingLabel: UILabel!
    @IBOutlet weak var gayWomenRatingLabel: UILabel!
    @IBOutlet weak var gayMenRatingLabel: UILabel!

    @IBOutlet weak var straightWomenVotesLabel: UILabel!
    @IBOutlet weak var straightMenVotesLabel: UILabel!
    @IBOutlet weak var gayWomenVotesLabel: UILabel!
    @IBOutlet weak var gayMenVotesLabel: UILabel!
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }

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
            let askSW = thisAsk.breakdown.straightWomen as! AskDemo
            let askSM = thisAsk.breakdown.straightMen as! AskDemo
            let askGW = thisAsk.breakdown.gayWomen as! AskDemo
            let askGM = thisAsk.breakdown.gayMen as! AskDemo
            
            // unwraps the ratingLabel from the IBOutlet and stores the demo rating to it (rounded)
            if let thisLabel = self.straightWomenRatingLabel {
                thisLabel.text = "\(askSW.rating.roundToPlaces(1))"
            }
            if let thisLabel = self.straightMenRatingLabel {
                thisLabel.text = "\(askSM.rating.roundToPlaces(1))"
            }
            if let thisLabel = self.gayWomenRatingLabel {
                thisLabel.text = "\(askGW.rating.roundToPlaces(1))"
            }
            if let thisLabel = self.gayMenRatingLabel {
                thisLabel.text = "\(askGM.rating.roundToPlaces(1))"
            }
            
            // unwraps the votesLabel from the IBOutlet and stores the demo vote quantity to it
            if let thisLabel = self.straightWomenVotesLabel {
                thisLabel.text = "\(askSW.numVotes) Votes"
            }
            if let thisLabel = self.straightMenVotesLabel {
                thisLabel.text = "\(askSM.numVotes) Votes"
            }
            if let thisLabel = self.gayWomenVotesLabel {
                thisLabel.text = "\(askGW.numVotes) Votes"
            }
            if let thisLabel = self.gayMenVotesLabel {
                thisLabel.text = "\(askGM.numVotes) Votes"
            }
            
            if let thisLabel = self.titleLabel {
                thisLabel.text = "\(thisAsk.askTitle)"
            }
            
            // unwraps the imageView from the IBOutlet
            if let thisImageView = self.askImage {
                thisImageView.image = thisAsk.askPhoto
            }

            
        } else {
            print("Looks like ask is nil")
        }
        
    }

    
    
    
    
    
    // MARK: Need to store values to IBOutlet Labels!
    
    
    
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


