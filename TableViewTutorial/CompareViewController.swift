//
//  CompareViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/22/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class CompareViewController: UIViewController {
    
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var bottomImageView: UIImageView!
    @IBOutlet weak var votes1Label: UILabel!
    @IBOutlet weak var votes2Label: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var breakdown1Button: UIButton!
    @IBOutlet weak var edit1Button: UIButton!
    @IBOutlet weak var breakdown2Button: UIButton!
    @IBOutlet weak var edit2Button: UIButton!
    @IBOutlet weak var winnerImageTop: UIImageView!
    @IBOutlet weak var winnerImageBottom: UIImageView!
    
    

    
    var compare: Compare? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

   func configureView() -> Void {
        print("configuring compare view")
        // unwraps the compare that the tableView sent over:
        guard let thisCompare = self.compare else {
            print("the compare is nil")
            return
        }
            // unwraps images from the compare and sends to IBOutlets
            if let thisImageView = self.topImageView {
                thisImageView.image = thisCompare.comparePhoto1
            }
            if let thisImageView = self.bottomImageView {
                thisImageView.image = thisCompare.comparePhoto2
            }
            // unwraps labels from the compare and sends to IBOutlets
            if let thisLabel = self.votes1Label {
                thisLabel.text = "\(thisCompare.compareVotes1)"
            }
            if let thisLabel = self.votes2Label {
                thisLabel.text = "\(thisCompare.compareVotes2)"
            }
            if let thisLabel = self.timeRemainingLabel {
                thisLabel.text = "\(thisCompare.timePosted)"
            }
            // For some reason, I had to unwrap the tangerine images from this same ViewController in order to 
            // modify thier attributes inside an if-then or switch-case:
            if let topFruitFlag = winnerImageTop, bottomFruitFlag = winnerImageBottom {
                switch thisCompare.winner {
                    case CompareWinner.photo1Won.rawValue:
                        topFruitFlag.hidden = false
                        bottomFruitFlag.hidden = true
                    case CompareWinner.photo2Won.rawValue:
                        topFruitFlag.hidden = true
                        bottomFruitFlag.hidden = false
                    case CompareWinner.itsATie.rawValue:
                        topFruitFlag.hidden = false
                        bottomFruitFlag.hidden = false
                    default:
                        print("issue with compare switch statement in CompareViewController - selected default")
                }
            }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! CompareBreakdownViewController
        // Pass the selected object to the new view controller:
        controller.compare = self.compare
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
