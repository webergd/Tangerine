//
//  CompareViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/22/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class CompareViewController: UIViewController, UIScrollViewDelegate {
    
    
    /////////////////
    // Outlets still needed for status bars
    /////////////////
    
    @IBOutlet weak var compareView: UIView!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var topScrollView: UIScrollView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var topCaptionTextField: UITextField!
    @IBOutlet weak var topCaptionTextFieldTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var bottomImageView: UIImageView!
    @IBOutlet weak var bottomCaptionTextField: UITextField!
    @IBOutlet weak var bottomCaptionTextFieldTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var votes1Label: UILabel!
    @IBOutlet weak var votes2Label: UILabel!
    
    @IBOutlet weak var timeRemainingLabel: UILabel!
  
    @IBOutlet weak var breakdown2Button: UIButton!

    @IBOutlet weak var winnerImageTop: UIImageView!
    @IBOutlet weak var winnerImageBottom: UIImageView!
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var container: Container? {
        didSet {
            // Update the view.
            self.configureView()
            print("configureView called in var container")
        }
    }

   func configureView() -> Void {
        print("configuring compare view")
        // unwraps the compare that the tableView sent over:
        guard let thisCompare = self.container?.question as! Compare? else {
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
                thisLabel.text = "\(thisCompare.timeRemaining)"
            }
    
            // In the future, there will need to be a way to tell this method which data to pull based on 
            //  the user's preferred display type, be it target demo or friend, or maybe even all.
            // For now, we will use target demo.
            // It should be just a simple if statement or two to set values that go into this.
            let targetDemoDataSet = self.container?.reviewCollection.pullConsolidatedCompareData(from: myTargetDemo.minAge, to: myTargetDemo.maxAge, straightWomen: myTargetDemo.straightWomenPreferred, straightMen: myTargetDemo.straightMenPreferred, gayWomen: myTargetDemo.gayWomenPreferred, gayMen: myTargetDemo.gayMenPreferred, friendsOnly: false)

    
    
            if let thisDataSet = targetDemoDataSet,
                let thisTopScoreLabel = self.votes1Label,
                let thisBottomScoreLabel = self.votes2Label {
                    thisTopScoreLabel.text = "\(thisDataSet.percentTop) %"
                    thisBottomScoreLabel.text = "\(thisDataSet.percentBottom) %"
            }

    
            // For some reason, I had to unwrap the tangerine images from this same ViewController in order to
            // modify thier attributes inside an if-then or switch-case:
            if let topFruitFlag = winnerImageTop, let bottomFruitFlag = winnerImageBottom {
                switch thisCompare.winner {
                    case CompareWinner.photo1Won.rawValue:
                        topFruitFlag.isHidden = false
                        bottomFruitFlag.isHidden = true
                    case CompareWinner.photo2Won.rawValue:
                        topFruitFlag.isHidden = true
                        bottomFruitFlag.isHidden = false
                    case CompareWinner.itsATie.rawValue:
                        topFruitFlag.isHidden = false
                        bottomFruitFlag.isHidden = false
                    default:
                        print("issue with compare switch statement in CompareViewController - selected default")
                }
            }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        topScrollView.delegate = self
        bottomScrollView.delegate = self
        
        let swipeViewGesture = UISwipeGestureRecognizer(target: self, action: #selector(CompareViewController.userSwiped))
        compareView.addGestureRecognizer(swipeViewGesture)
        
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(CompareViewController.userSwiped))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(CompareViewController.userSwiped))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // If we show the captions in an earlier method like viewDidLoad, autolayout has not yet modfied the size of the imageViews
        //  to work without the status bar or something, so the captions get placed in the wrong spot.
        // It is still a little choppy with the captions appearing a split second after so we probably should either fade them in
        //  or get to the bottom of why the image size is changing when the view loads, or at the very least being able to predict the 
        //  size that the images will be once they load so that we can calculate an accurate caption location.
        
        guard let thisCompare = self.container?.question as! Compare? else {
            print("the compare is nil")
            return
        }
        
        

        // shouldn't this technically use the helper view's frame.height rather than the imageView?
        if let thisCaptionTopConstraint = self.topCaptionTextFieldTopConstraint {
            thisCaptionTopConstraint.constant = calcCaptionTextFieldTopConstraint(imageViewFrameHeight: topImageView.frame.height, captionYLocation: thisCompare.compareCaption1.yLocation)
            
            print("topView frame height: \(topView.frame.height), topScrollView frame height: \(topScrollView.frame.height)")
            print("topImage frame height: \(topImageView.frame.height), caption y Loc is: \(thisCompare.compareCaption1.yLocation)")
            print("top caption top constraint set to: \(topCaptionTextFieldTopConstraint.constant)")
        }
        
  
        
        if let thisCaptionTextField = self.topCaptionTextField {
            
            thisCaptionTextField.text = thisCompare.compareCaption1.text
            thisCaptionTextField.isHidden = !thisCompare.compareCaption1.exists
            
        }
        
        
        if let thisCaptionTopConstraint = self.bottomCaptionTextFieldTopConstraint {
            thisCaptionTopConstraint.constant = bottomImageView.frame.height * thisCompare.compareCaption2.yLocation
            
            print("bottomImage frame height: \(bottomImageView.frame.height), caption y Loc is: \(thisCompare.compareCaption2.yLocation)")
            print("bottom caption top constraint set to: \(bottomCaptionTextFieldTopConstraint.constant)")
        }
        
        if let thisCaptionTextField = self.bottomCaptionTextField {
            thisCaptionTextField.isHidden = !thisCompare.compareCaption2.exists
            thisCaptionTextField.text = thisCompare.compareCaption2.text
        }

    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Allows the user to zoom within the scrollView that the user is manipulating at the time.
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if scrollView == topScrollView {
            return self.topImageView
        } else {
            return self.bottomImageView
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        topScrollView.setZoomScale(1.0, animated: true)
        bottomScrollView.setZoomScale(1.0, animated: true)
    }
 
    func userSwiped(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            if swipeGesture.direction == UISwipeGestureRecognizerDirection.right {
                self.navigationController?.popViewController(animated: true)
            } else if swipeGesture.direction == UISwipeGestureRecognizerDirection.left {
                // sets the graphical view controller with the storyboard ID" comparePreviewViewController to nextVC
                let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "compareBreakdownViewController") as! CompareBreakdownViewController
                // pushes askBreakdownViewController onto the nav stack
                nextVC.container = self.container
                self.navigationController?.pushViewController(nextVC, animated: true)
            }
            
            
        }
        
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare for segue called in CompareViewController")
        let controller = segue.destination as! CompareBreakdownViewController
        // Pass the selected object to the new view controller:
        controller.container = self.container
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
