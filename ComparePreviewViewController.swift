//
//  ComparePreviewViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 2/18/17.
//  Copyright © 2017 Freedom Electric. All rights reserved.
//

import UIKit

class ComparePreviewViewController: UIViewController, UINavigationControllerDelegate, UIScrollViewDelegate {


    @IBOutlet weak var topScrollView: UIScrollView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var topCaptionTextField: UITextField!
    @IBOutlet weak var topCaptionTextFieldTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topImageLockButton: UIButton!

    

    @IBOutlet weak var bottomScrollView: UIScrollView!
    @IBOutlet weak var bottomImageView: UIImageView!
    @IBOutlet weak var bottomCaptionTextField: UITextField!
    @IBOutlet weak var bottomCaptionTextFieldTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomImageLockButton: UIButton!
    
    var topButtonLocked: Bool = false
    var bottomButtonLocked: Bool = false
    
    // Dummy values loaded into captions to avoid having to write an initializer method.
    var topCaption: Caption = Caption(text: "", yLocation: 0.0) // recall that if text is "", computed exists property returns false
    var bottomCaption: Caption = Caption(text: "", yLocation: 0.0)
    
    // should prevent the status bar from displaying at the top of the screen
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    
    override func viewDidLoad() {
        /*
        print("On load, top caption top constraint is: \(topCaptionTextFieldTopConstraint.constant)")
        print("On load, bottom caption top constraint is: \(bottomCaptionTextFieldTopConstraint.constant)")
        */
        
        super.viewDidLoad()
        topScrollView.delegate = self
        bottomScrollView.delegate = self
        
        if let iE1: UIImage = currentCompare.imageBeingEdited1?.iBEimageBlurredCropped,
            let iE2: UIImage = currentCompare.imageBeingEdited2?.iBEimageBlurredCropped,
            let tCap = currentCompare.imageBeingEdited1?.iBEcaption,
            let bCap = currentCompare.imageBeingEdited2?.iBEcaption {
            topImageView.image = iE1
            bottomImageView.image = iE2
            topCaption = tCap
            bottomCaption = bCap
            
        } else {
            print("Could not unwrap one or both images in ComparePreviewViewController")
        }
        
        if topCaption.exists == false {
            topCaptionTextField.isHidden = true
        } else {
            topCaptionTextField.isHidden = false
            topCaptionTextField.text = topCaption.text
        }
        
        if bottomCaption.exists == false {
            bottomCaptionTextField.isHidden = true
        } else {
            bottomCaptionTextField.isHidden = false
            bottomCaptionTextField.text = bottomCaption.text
        }
    
        

        //print("topImage frame height: \(topImageView.frame.height), caption y Loc is: \(currentCompare.imageBeingEdited1?.iBEcaption.yLocation)")
        
        
       
        // do some math to place each caption in the right spot
        
        topCaptionTextFieldTopConstraint.constant = calcCaptionTextFieldTopConstraint(imageViewFrameHeight: topImageView.frame.height, captionYLocation: topCaption.yLocation)  //topImageView.frame.height * topCaption.yLocation

        bottomCaptionTextFieldTopConstraint.constant = calcCaptionTextFieldTopConstraint(imageViewFrameHeight: bottomImageView.frame.height, captionYLocation: bottomCaption.yLocation) //bottomImageView.frame.height * bottomCaption.yLocation
        
        
        
        /*
        print("top caption top constraint set to: \(topCaptionTextFieldTopConstraint.constant)")
        print("bottom caption top constraint set to: \(bottomCaptionTextFieldTopConstraint.constant)")
        print("bottomImage frame height: \(bottomImageView.frame.height), caption y Loc is: \(currentCompare.imageBeingEdited2?.iBEcaption.yLocation)")
        */
 
        
        
        

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

    @IBAction func topLockButtonTapped(_ sender: Any) {
        if topButtonLocked == false {
            // lock the top image
            topButtonLocked = true
            topImageLockButton.setImage(#imageLiteral(resourceName: "lock_white"), for: .normal)
            checkIfBothImagesAreLocked()
        } else {
            // unlock the image
            topButtonLocked = false
            topImageLockButton.setImage(#imageLiteral(resourceName: "unlock_white"), for: .normal)
        }
    }
    
    
    @IBAction func bottomLockButtonTapped(_ sender: Any) {
        if bottomButtonLocked == false {
            // lock the top image
            bottomButtonLocked = true
            bottomImageLockButton.setImage(#imageLiteral(resourceName: "lock_white"), for: .normal)
            checkIfBothImagesAreLocked()
        } else {
            // unlock the image
            bottomButtonLocked = false
            bottomImageLockButton.setImage(#imageLiteral(resourceName: "unlock_white"), for: .normal)
        }
    }
    
    func checkIfBothImagesAreLocked() {
        if topButtonLocked == true && bottomButtonLocked == true {
            // do stuff to create the compare
            print("both images are locked, time to create a compare!!")
            
            let alertController = UIAlertController(title: "Both Images Locked", message: "Submit for Review?", preferredStyle: .alert)
            let actionYes = UIAlertAction(title: "Publish", style: .default) {
                UIAlertAction in
                
                if let iBE1 = currentCompare.imageBeingEdited1, let iBE2 = currentCompare.imageBeingEdited2 {
                
                let newCompare = Compare(title1: iBE1.iBEtitle, photo1: iBE1.iBEimageBlurredCropped, caption1: iBE1.iBEcaption, title2: iBE2.iBEtitle, photo2: iBE2.iBEimageBlurredCropped, caption2: iBE2.iBEcaption, timePosted: Date())
                    
                    print("new compare created. Title 1 is: \(iBE1.iBEtitle)")
                    
                mainArray.append(newCompare)
                    
                }
                print("pop the view controller")
                //self.navigationController?.popViewController(animated: true)
                self.navigationController?.popToRootViewController(animated: true)
                
                //let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                //self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                
                //make the compare
                //append it to the array
                //go back to main page
                
                
                // create a compare and publish
                //let newAsk = Ask(title: currentTitle, photo: imageToCreateAskWith, timePosted: Date())
                
                // Once the Ask is created it is appended to the main array:
                //mainArray.append(newAsk)
                
                //let testAsk = mainArray.last as! Ask
                //print("New Ask now appended to mainArray. Last Ask in the Array is title: \(testAsk.askTitle), timePosted: \(testAsk.timePosted)")
                
                //self.backTwo() //back to main

            }
            
            
            let actionNo = UIAlertAction(title: "Cancel", style: .default) {
                UIAlertAction in
                self.bottomButtonLocked = false
                self.bottomImageLockButton.setImage(#imageLiteral(resourceName: "unlock_white"), for: .normal)
                self.topButtonLocked = false
                self.topImageLockButton.setImage(#imageLiteral(resourceName: "unlock_white"), for: .normal)
                            }
            
            alertController.addAction(actionNo)
            alertController.addAction(actionYes)
            
            present(alertController, animated: true, completion: nil)
            
            
        } else {
            // do nothing until the user locks both images
            return
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
