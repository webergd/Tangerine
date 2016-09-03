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
    
    var winnerFlag: String = WinnerFlag.first.rawValue
    
    enum WinnerFlag: String {
        case first
        case second
        case tie
    }

   func configureView() -> Void {
        //topImageView.hidden = false
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
    
            /*
            if let topTangerine = self.topImageView {
                topTangerine.image = UIImage(named: "tangerineImage1")
                print("stored an image to topTangerine")
            }
            if let bottomTangerine = self.bottomImageView {
                if 1 == 1 {
                bottomTangerine.hidden = true
                }
            }
            */
            // I wonder if an if statement will work instead:

    
            // This part is frustrating as fuck. I can't figure out why the system keeps seeing the winnerImageTop and winnerImageBottom as nil. It doesn't see them as nil outside of configureView().
            // Maybe there is a way to determine who the winner is inside this method, and then change the hidden property of the images outside of this method. Maybe I can set a winner flag or something that another function uses.
            if let topFruitFlag = winnerImageTop, bottomFruitFlag = winnerImageBottom {
            switch thisCompare.winner {
                case CompareWinner.photo1Won.rawValue:
                    winnerFlag = WinnerFlag.first.rawValue
                    print("inside switch - photo 1 won")
                    topFruitFlag.hidden = false
                    bottomFruitFlag.hidden = true
                case CompareWinner.photo2Won.rawValue:
                    //winnerFlag = WinnerFlag.second.rawValue
                    print("inside switch - photo 2 won")
                    //if winnerImageTop == nil {
                    //    print("winnerImageTop is nil")
                    //}
                    // as of now, any instruction I put in here (except for print) seems to throw a optional nil error
                    //unHideTopImage()
                    topFruitFlag.hidden = true
                    bottomFruitFlag.hidden = false
                case CompareWinner.itsATie.rawValue:
                    //winnerFlag = WinnerFlag.tie.rawValue
                    topFruitFlag.hidden = false
                    bottomFruitFlag.hidden = false
                default:
                    print("issue with compare switch statement in CompareViewController - selected default")
            }
            }
        //self.unHideWinnerImage()
    
    }

    func unHideWinnerImage(){
        switch winnerFlag {
        case WinnerFlag.first.rawValue: winnerImageTop.hidden = false; winnerImageBottom.hidden = true
        case WinnerFlag.second.rawValue: print()//winnerImageTop.hidden = true; winnerImageBottom.hidden = false
        case WinnerFlag.tie.rawValue: winnerImageTop.hidden = false; winnerImageBottom.hidden = false
        default: winnerImageTop.hidden = false; winnerImageBottom.hidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //winnerImageTop.image = UIImage(named: "tangerineImage1")
        if 1 == 1 {
        winnerImageBottom.hidden = false
        winnerImageBottom.image = UIImage(named: "tangerineImage1")
        }
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
