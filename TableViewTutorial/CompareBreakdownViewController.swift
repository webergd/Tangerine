//
//  CompareBreakdownViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/26/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class CompareBreakdownViewController: UIViewController {

    //IBOutlets go here
    @IBOutlet weak var compareBreakdownView: UIView!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var title1Label: UILabel!
    @IBOutlet weak var title2Label: UILabel!

    
    @IBOutlet weak var straightWomenVotes4OneLabel: UILabel!
    @IBOutlet weak var straightWomenVotes4TwoLabel: UILabel!
    @IBOutlet weak var straightMenVotes4OneLabel: UILabel!
    @IBOutlet weak var straightMenVotes4TwoLabel: UILabel!
    @IBOutlet weak var gayWomenVotes4OneLabel: UILabel!
    @IBOutlet weak var gayWomenVotes4TwoLabel: UILabel!
    @IBOutlet weak var gayMenVotes4OneLabel: UILabel!
    @IBOutlet weak var gayMenVotes4TwoLabel: UILabel!
    
    @IBOutlet weak var straightWomenAvgAgeLabel: UILabel!
    @IBOutlet weak var straightMenAvgAgeLabel: UILabel!
    @IBOutlet weak var gayWomenAvgAgeLabel: UILabel!
    @IBOutlet weak var gayMenAvgAgeLabel: UILabel!
    
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        let swipeViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(CompareBreakdownViewController.userSwiped))
        compareBreakdownView.addGestureRecognizer(swipeViewGesture)
    }
    
    var container: Container? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        print("configuring ask view")
        
        // unwraps the ask that the tableView sent over:
        if let thisCompare = self.container?.question as! Compare? {
            let compareSW = thisCompare.breakdown.straightWomen as! CompareDemo
            let compareSM = thisCompare.breakdown.straightMen as! CompareDemo
            let compareGW = thisCompare.breakdown.gayWomen as! CompareDemo
            let compareGM = thisCompare.breakdown.gayMen as! CompareDemo
            
            // unwraps the ratingLabel from the IBOutlet and stores the demo rating to it (rounded)
            if let thisLabel = self.straightWomenVotes4OneLabel {
                thisLabel.text = "\(compareSW.votesForOne)"
            }
            if let thisLabel = self.straightWomenVotes4TwoLabel {
                thisLabel.text = "\(compareSW.votesForTwo)"
            }
            if let thisLabel = self.straightMenVotes4OneLabel {
                thisLabel.text = "\(compareSM.votesForOne)"
            }
            if let thisLabel = self.straightMenVotes4TwoLabel {
                thisLabel.text = "\(compareSM.votesForTwo)"
            }
            if let thisLabel = self.gayWomenVotes4OneLabel {
                thisLabel.text = "\(compareGW.votesForOne)"
            }
            if let thisLabel = self.gayWomenVotes4TwoLabel {
                thisLabel.text = "\(compareGW.votesForTwo)"
            }
            if let thisLabel = self.gayMenVotes4OneLabel {
                thisLabel.text = "\(compareGM.votesForOne)"
            }
            if let thisLabel = self.gayMenVotes4TwoLabel {
                thisLabel.text = "\(compareGM.votesForTwo)"
            }
            
            
            // unwraps the imageView from the IBOutlet
            if let thisImageView = self.imageView1 {
                thisImageView.image = thisCompare.comparePhoto1
            }
            if let thisImageView = self.imageView2 {
                thisImageView.image = thisCompare.comparePhoto2
            }
            
            if let thisLabel = self.title1Label {
                thisLabel.text = "\(thisCompare.compareTitle1)"
            }
            if let thisLabel = self.title2Label {
                thisLabel.text = "\(thisCompare.compareTitle2)"
            }
            
            // load the Avg Age labels
            if let thisLabel = self.straightWomenAvgAgeLabel {
                thisLabel.text = "\(compareSW.avgAge)"
            }
            if let thisLabel = self.straightMenAvgAgeLabel {
                thisLabel.text = "\(compareSM.avgAge)"
            }
            if let thisLabel = self.gayWomenAvgAgeLabel {
                thisLabel.text = "\(compareGW.avgAge)"
            }
            if let thisLabel = self.gayMenAvgAgeLabel {
                thisLabel.text = "\(compareGM.avgAge)"
            }
            
            
        } else {
            print("Looks like ask is nil")
        }
    
    }
    
    

    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userSwiped() {
        print("user swiped**********")
        self.navigationController?.popViewController(animated: true)
        
    }


    
}
