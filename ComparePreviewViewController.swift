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
        print("ComparePreviewViewController.viewDidLoad called")
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
        
        topCaptionTextField.isHidden = !topCaption.exists
        topCaptionTextField.text = topCaption.text
        
        bottomCaptionTextField.isHidden = !bottomCaption.exists
        bottomCaptionTextField.text = bottomCaption.text
        
        /*
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
        */
       
        // do some math to place each caption in the right spot
        
        topCaptionTextFieldTopConstraint.constant = calcCaptionTextFieldTopConstraint(imageViewFrameHeight: topImageView.frame.height, captionYLocation: topCaption.yLocation)
 
        bottomCaptionTextFieldTopConstraint.constant = calcCaptionTextFieldTopConstraint(imageViewFrameHeight: bottomImageView.frame.height, captionYLocation: bottomCaption.yLocation)

        
        // For tapping the images to edit:
        let tapTopImageGesture = UITapGestureRecognizer(target: self, action: #selector(ComparePreviewViewController.userTappedTop(_:) ))
        topImageView.addGestureRecognizer(tapTopImageGesture)
        
        let tapBottomImageGesture = UITapGestureRecognizer(target: self, action: #selector(ComparePreviewViewController.userTappedBottom(_:) ))
        bottomImageView.addGestureRecognizer(tapBottomImageGesture)
        
        
  
    }

    func userTappedTop(_ pressImageGesture: UITapGestureRecognizer){
        returnForEditing(editTopImage: true)
    }
    
    func userTappedBottom(_ pressImageGesture: UITapGestureRecognizer){
        returnForEditing(editTopImage: false)
    }
  
    
    func returnForEditing(editTopImage: Bool) {
        
        print("return for editing called")
        
        // set the flag so we know which image to display in CameraViewController
        if editTopImage == true {
            print("flag switched to edit 1st photo")
            currentCompare.creationPhase = .reEditingFirstPhoto
        } else {
            print("flag switched to edit 2nd photo")
            currentCompare.creationPhase = .reEditingSecondPhoto
        }
        
        print("outside if-statement. Should pop viewcontroller now")
        
        self.navigationController?.popViewController(animated: true) //return to CameraViewController
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
                clearOutCurrentCompare() // this is a method is DataModels and will set the flag to .noImageTaken
                    
                }
                print("pop the view controller back to the menu")

                self.navigationController?.popToRootViewController(animated: true)
                

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
            
            
            // This alert view should probably just be replaced with an arrow that appears and lights up or something
            //  Then if the user unlocks one of the locks, the arrow goes away until they lock both again
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
