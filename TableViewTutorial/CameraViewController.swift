//
//  CameraViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 8/3/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

// In truthfulness, this file should be renamed to PhotoEditorViewController

import UIKit
import MobileCoreServices


class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var captionTextFieldTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var otherImageThumbnail: UIButton! // this is a button but in terms of being an outlet we will use it as an imageView
    @IBOutlet var longPressTap: UILongPressGestureRecognizer! //MARK: did this unlink itself?
    @IBOutlet weak var clearBlursButton: UIButton!
    @IBOutlet weak var enableBlurringButton: UIButton!
    //@IBOutlet weak var returnToZoomButton: UIButton!
    @IBOutlet weak var blurringInProgressLabel: UILabel!
    @IBOutlet weak var addCompareButton: UIButton! // appears as 2
    @IBOutlet weak var reduceToAskButton: UIButton! // appears as a 1
    @IBOutlet weak var mirrorCaptionButton: UIButton!
    @IBOutlet weak var centerFlexibleSpace: UIBarButtonItem!
    
    
    
    /*@IBOutlet weak var captionTextFieldBottomConstraint: NSLayoutConstraint!*/
    
    // I need some kind of event that sees when the value of mirrorSwitch.on is changed. Then I can adjust the captionTextField as appropriate.
    // In user settings I could have another switch that sets a default value for mirrorSwitch, depending on user preferences

    
    
    
    // many of these are 0.0 becuase I didn't want to bother with an initializer method since they all get set before use anyway.
    let imagePicker = UIImagePickerController()
    var titleHasBeenTapped: Bool = false
    var captionHasBeenTapped: Bool = false
    var tappedLoc: CGPoint = CGPoint(x: 0.0, y: 0.0)
    var captionYValue: CGFloat = 0.0 //this is an arbitrary value to be reset later
    var activeTextField = UITextField()
    var titleFrameRect: CGRect = CGRect()
    var titleTextFieldHeight: CGFloat = 0.0
    var captionTextFieldHeight: CGFloat = 0.0
    var scrollViewFrameRect: CGRect = CGRect()
    var scrollViewHeight: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    var screenWidth: CGFloat = 0.0
    var captionTopLimit: CGFloat = 0.0
    var captionBottomLimit: CGFloat = 0.0
    //var captionLocationToSet: CGFloat = 0.0
    var imageScreenSize: CGFloat = 0.0 // this is the height of the image in terms of screen units (pixels or whatever they are)
    // We don't use blurColor anymore
    let blurColor = UIColor(red: 172/255, green: 132/255, blue: 76/255, alpha: 0.05)
    var blurringEnabled: Bool = false
    var blurFace: BlurFace = BlurFace(image: currentImage)
    var pressStartTime: TimeInterval = 0.0
    public let phoneScreenWidth: CGFloat = UIScreen.main.bounds.size.width
    var blurRadiusMultiplier: CGFloat = 0.0
    var unblurredImageSave: UIImage = currentImage
    var blursAddedByEditor: Bool = false
    var zoomScaleToLoad: CGFloat =  initialZoomScale
    var contentOffsetToLoad: CGPoint = initialContentOffset
    let enterTitleConstant: String = "Enter a Private Title for Your Photo Here"
    
    var titleTextFieldIsBlank: Bool {
        print("Checking to see if the user entered a title")
        if titleTextField.text == enterTitleConstant
            || titleTextField.text == "(no title)"
            || titleTextField.text == "" {
            print("title is blank")
            return true
        } else {
            print("title is not blank")
            return false
        }
    }
    
    // These are modified later but needed a higher scope for finishEditing to work correctly
    var actionYes = UIAlertAction(title: "", style: .default, handler: nil)
    var actionNo = UIAlertAction(title: "", style: .default, handler: nil)
    
    // should prevent the status bar from displaying at the top of the screen
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    enum CameraError: Swift.Error {
        case noName
    }
    
    enum oneOrTwo: String {
        case one
        case two
    }
    

    /* enabled the old camera button on CameraViewController
    @IBAction func useCamera(_ sender: AnyObject) {
        // makes sure we have a camera, aka this is not the simulator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera //I'm assuming the default is the back camera which is what we want
        } else {
            imagePicker.sourceType = .photoLibrary // if we're in the simulator it just redirects to the photo library
        }
        present(imagePicker, animated: true, completion: nil)
    }
    */

    //This happens when the user clicks on the use camera roll bar button
    
    /* enabled the old camera roll button on CameraViewController
    @IBAction func useCameraRoll(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeImage as String] //supposedly this prevents the user from taking videos
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
    }
    */
    
        // MARK: DELETE THIS this is just so that the sample image will keep loading for testing:
    override func viewDidAppear(_ animated: Bool) {
        print("CameraViewController.viewDidAppear called")
        //currentImage = UIImage(named: "NumberedColorGrid")!
        

        // the zoom needs to be set in here when reloading for editing
        
        // this is in here so that it happens a little after the view loaded and the user can see the animation,
        // as well as watch the blur button appear to draw attention that there are blurs. <- not sure..hmmm
        
        //if this could animate at twice the speed, it would look better (and be less annoying when switching between thumbnails that are zoomed in far)
        scrollView.setZoomScale(zoomScaleToLoad, animated: true)
        print("zoomScale set to: \(scrollView.zoomScale)")
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("CameraViewController.viewWillAppear called")
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        //Now we check to see which image to display
    
        switch currentCompare.creationPhase {
            
        case .firstPhotoTaken:
            print("calling load(image) on next line")
            load(image: .one)
            print("titleTextField before reset: \(titleTextField.text)")
            resetTitleTextField()
            titleHasBeenTapped = false
            addCompareButton.isHidden = false // give the user the option to create a compare
            reduceToAskButton.isHidden = true
            otherImageThumbnail.isHidden = true //if it's a single image, there will be no other image to show a thumbnail of
            
            print("inside case .firstPhotoTaken")

            
        case .secondPhotoTaken:
            load(image: .two)
            resetTitleTextField()
            titleHasBeenTapped = false
            addCompareButton.isHidden = true
            reduceToAskButton.isHidden = false
            otherImageThumbnail.isHidden = true //we want them to focus on making image2 right now, no thumbnail
            print("ready to create the second half of the compare")
            
            print("inside case .secondPhotoTaken")

            
        case .reEditingFirstPhoto:
            load(image: .one)
            addCompareButton.isHidden = true
            reduceToAskButton.isHidden = false
            otherImageThumbnail.isHidden = false //displays the thumbnail
            
            print("inside case .reEditingFirstPhoto")

            
        case .reEditingSecondPhoto:
            load(image: .two)
            addCompareButton.isHidden = true
            reduceToAskButton.isHidden = false
            otherImageThumbnail.isHidden = false //displays the thumbnail
            
            print("inside case .reEditingSecondPhoto")
  
            
        case .noPhotoTaken: //this should never happen
            print("Error in CameraViewController.ViewWillAppear: creationPhase is .noPhotoTaken, something went wrong.")
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("CameraViewController.viewDidLoad() called")
        
        //centerFlexibleSpace.isEnabled = false
        
        /*
        print("Content Offset on load is: \(scrollView.contentOffset.y)")
        
        scrollView.setZoomScale(1.0, animated: true)
        print("zoomScale is: \(scrollView.zoomScale)")
        
        let point = CGPoint(x: 100.0, y: 100.0)
        scrollView.setContentOffset(point, animated: true)
        print("Content Offset on load is: \(scrollView.contentOffset.y)")
        */
        
        
        //scrollView.zoomScale = 2.0
        //print("zoomScale is: \(scrollView.zoomScale)")
        
        //justFinishedPicking = true //prevents AVCameraViewController from reloading camera upon navigating back to it
        
        //imageView.image = currentImage
        titleHasBeenTapped = false
        
        otherImageThumbnail.imageView?.contentMode = UIViewContentMode.scaleAspectFit

        
        
        self.enableBlurringButton.isHidden = false
        self.clearBlursButton.isHidden = !blursAddedByEditor
        
        // blurRadiusMultiplier = phoneScreenWidth / 3.0
        //print("setting blur radius mutliplier using phone screen width (psw/3)")
        //print("phoneScreenWidth is: \(phoneScreenWidth)")
        //print("blur radius multiplier is: \(blurRadiusMultiplier)")
        
        imagePicker.delegate = self
        captionTextField.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        // Hides keyboard when user taps outside of text field
        self.hideKeyboardWhenTappedAround()
        
        // This gives a done key but requires other code to dismiss the keyboard
        self.captionTextField.returnKeyType = UIReturnKeyType.done
        
        // This gives a done key but requires other code to dismiss the keyboard
        self.titleTextField.returnKeyType = UIReturnKeyType.done

        // This gets us the height of the caption text field to be used later for spacing things out correctly
        self.captionTextFieldHeight = self.captionTextField.frame.height
        print("captionTextFieldHeight = \(captionTextFieldHeight)")

        
        // This will move the caption text box out of the way when the keyboard pops up:
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // This will move the caption text box back down when the keyboard goes away:
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // This gets the height of the screen for spacing things out later
        // Used only for determining where to move the caption when the keyboard pops up
        self.screenHeight = UIScreen.main.bounds.height
        
        // screenWidth is the same as displayed imageView height since imageView is a square
        self.screenWidth = UIScreen.main.bounds.width
        print("screenWidth = \(screenWidth)")
        
        // ^^^^ These are literally the same value. One needs to be find and replaced with the other at some point for simplification. VVVV
        
        // calculates the height of the image in terms of screen units to be used for capturing the caption location
        //print("imageView.frame.height = \(imageView.frame.height)-------")
        //self.imageScreenSize = imageView.frame.height//screenWidth//self.captionBottomLimit - self.captionTopLimit
        //print("viewDidLoad stored imageScreenSize as: \(imageView.frame.height)-------")
        
        
        // This gets us the height of the title text field to be used later for spacing things out correctly
        // Shouldn't need this anymore now that title is below imageView
        self.titleTextFieldHeight = self.titleTextField.frame.height
        
        // This sets up the min and max values that the caption's top constraint can have and still be over the image
        self.captionTopLimit = self.topLayoutGuide.length //+ self.titleTextFieldHeight  **********
        
        //self.scrollViewHeight = self.scrollView.frame.height
        //print("scrollView height is: \(scrollViewHeight)")
        //print("self.screenHeight is: \(self.screenHeight)")
        //print("self.screenWidth is: \(UIScreen.main.bounds.width)")
        

        
        // This constrains the caption drag to stay above the bottom of the image
        self.captionBottomLimit = self.captionTopLimit + screenWidth - self.captionTextFieldHeight 
  
        //Enables tap on image to show caption (1 of 2):
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.userTappedImage(_:)))
        imageView.addGestureRecognizer(tapImageGesture)
        imageView.isUserInteractionEnabled = true
  
        //Enables user to drag caption around (1 of 2):
        let dragCaptionGesture = UIPanGestureRecognizer(target: self, action: #selector(CameraViewController.userDragged(_:)))
        captionTextField.addGestureRecognizer(dragCaptionGesture)
        captionTextField.isUserInteractionEnabled = true
        
        
        //Enables user to long press image for blurred circle (1 of 2):
        
        let pressImageGesture = UILongPressGestureRecognizer(target: self, action: #selector(CameraViewController.userPressed(_:) ))
        pressImageGesture.minimumPressDuration = 0.50
        imageView.addGestureRecognizer(pressImageGesture)

        //captionTextField.isUserInteractionEnabled = true
        
    }
    
    
    // The next 3 methods (loadImage and the two unpacks) work together to load the correct properties into the CameraViewController
    func load(image number: oneOrTwo) {
        print("load(image) called")
        
        if currentCompare.imageBeingEdited1 == nil {
            print("imageBeingEdited1 is nil")
        }
        
        if currentCompare.imageBeingEdited2 == nil {
            print("imageBeingEdited2 is nil")
        }
        
        
        if let iBE1 = currentCompare.imageBeingEdited1 {
            
            switch number {
                
            case .one:
                print("inside load(image) case .one")
                unpack(image: iBE1)
                if let iBE2 = currentCompare.imageBeingEdited2 { unpack(thumbnail: iBE2) }

            case .two:
                print("inside load(image) case .two")
                if let iBE2 = currentCompare.imageBeingEdited2 { unpack(image: iBE2) }
                unpack(thumbnail: iBE1)

            }
        } else {
            print("Error: images did not unpack")
        }
        
        imageView.image = currentImage
        titleTextField.text = currentTitle; print("title set to \(currentTitle)")
        captionTextField.text = currentCaption.text
        captionTextFieldTopConstraint.constant = screenWidth * currentCaption.yLocation
        //scrollView.setContentOffset(contentOffsetToLoad, animated: false)
        scrollView.setZoomScale(zoomScaleToLoad, animated: false)
        scrollView.setContentOffset(contentOffsetToLoad, animated: false)

        
        
        
        print("-------------------------------------------------")
        print("* inside load(image number: oneOrTwo) *")
        print("creation phase is: \(currentCompare.creationPhase) PHASE")
        print("contentOffsetToLoad: \(contentOffsetToLoad)")
        print("scrollView.contentOffset is: \(scrollView.contentOffset)")
        print("scrollView.zoomScale is: \(scrollView.zoomScale) = ")
        print("-------------------------------------------------")
        
        
        
        
    }
    
    func unpack(image iBE: imageBeingEdited) {
        currentImage = iBE.iBEimageBlurredUncropped
        currentTitle = iBE.iBEtitle
        currentCaption = iBE.iBEcaption
        captionTextField.isHidden = !iBE.iBEcaption.exists //hide captionTextField if caption doesn't exist, otherwise, show it.
        unblurredImageSave = iBE.iBEimageCleanUncropped
        blursAddedByEditor = iBE.blursAdded
        contentOffsetToLoad = iBE.iBEContentOffset
        zoomScaleToLoad = iBE.iBEZoomScale
        print("unpacked zoomScale: \(iBE.iBEZoomScale); unpacked contentOffset: \(iBE.iBEContentOffset)")
        
        
    }
    
    func unpack(thumbnail iBE: imageBeingEdited) {
        otherImageThumbnail.setImage(iBE.iBEimageBlurredCropped, for: .normal)
    }
    
    

    
    

    
    
    
    
    
    
    
    
    //Enables tap on image to show caption (2 of 2):
    func userTappedImage(_ tapImageGesture: UITapGestureRecognizer){
        print("user tapped image")
        captionTextField.translatesAutoresizingMaskIntoConstraints = false
        tappedLoc = tapImageGesture.location(in: self.view)
        print("User tapped: \(tappedLoc)")

        if captionTextField.isHidden == true && titleTextField.isEditing == false {
            // Show the captionTextField:
            captionTextField.isHidden = false
            // Position the captionTextField where the user tapped:
            self.captionTextFieldTopConstraint.constant = tappedLoc.y - self.topLayoutGuide.length - (0.5 * captionTextFieldHeight)
            captionTextField.becomeFirstResponder()
            //self.captionTextField.center.y = tappedLoc.y
            if titleTextField.text == enterTitleConstant {
                mirrorCaptionButton.isHidden = false
                centerFlexibleSpace.isEnabled = true
            }
            
        } else {
            // if the caption is displayed and the user taps the image, dismiss the keyboard
            if captionTextField.text == "" {
                mirrorCaptionButton.isHidden = true
                centerFlexibleSpace.isEnabled = false
            }
            view.endEditing(true)
            //print("back inside userTappedImage function")
            //print("captionTextField.center.y= \(self.captionTextField.center.y)")
            //print("end of userTappedImage function")
        }
    }
    
    //Enables user to drag caption around (2 of 2):
    func userDragged(_ dragCaptionGesture: UIPanGestureRecognizer){
        let draggedLoc: CGPoint = dragCaptionGesture.location(in: self.view)
        let captionLocationToSet = draggedLoc.y - self.topLayoutGuide.length - (0.5 * captionTextFieldHeight)
        self.captionTextFieldTopConstraint.constant = vetCaptionTopConstraint(captionLocationToSet)
        
        // added: 2/13/17
        self.captionYValue = self.captionTextFieldTopConstraint.constant
        
        //self.captionTextField.center.y = draggedLoc.y
        //This is more efficient: self.captionTextField.center.y = dragCaptionGesture.location(in: self.view).y
        //print("draggedLoc.y: \(draggedLoc.y)")
    }
    
    
    // This determines whether the caption y value is within the prescribed limits within the bounds of the imageView and if it is not, returns the limit that it has crossed.
    func vetCaptionTopConstraint(_ desiredLocation: CGFloat) -> CGFloat {
        // The varible (declared at the top) captionTopConstraint basically just holds the caption's distance from the top of the main View.
        // It is an outlet from Interface Builder, referring to an Interface Builder constraint.
        // The reason it has topConstraint in the name is because that is the Interface Builder constraint we are manipulating.
        if desiredLocation < captionTopLimit {
            print("returning captionTopLimit: \(captionTopLimit)")
            return captionTopLimit
        } else if desiredLocation > captionBottomLimit {
            print("returning captionBottomLimit: \(captionBottomLimit)")
            return captionBottomLimit
            
        } else {
            return desiredLocation
        }
    }

    // This is called in the viewDidLoad section in our NSNotificationCenter command
    func keyboardWillShow(_ notification: Notification) {
        // Basically all this shit is for moving the caption out of the way of the keyboard while we're editing it:
        if self.captionTextField.isEditing == true { //aka if the title is editing, don't do any of this
            //get the height of the keyboard that will show and then shift the text field up by that amount
            if let userInfoDict = notification.userInfo, let keyboardFrameValue = userInfoDict [UIKeyboardFrameEndUserInfoKey] as? NSValue {

                let keyboardFrame = keyboardFrameValue.cgRectValue
            
                //this makes the text box movement animated so it looks smoother:
                UIView.animate(withDuration: 0.8, animations: {
                    // Save the captionTextField's Location so we can restore it after editing:
                    // Ensures that the saved captionYValue will be within the top and bottom limit.
                    
                    
                    //self.captionYValue = self.vetCaptionTopConstraint(self.captionTextFieldTopConstraint.constant)
                    
                    
                    self.captionYValue = self.captionTextFieldTopConstraint.constant
                    
                    
                    
                    //self.captionTextFieldBottomConstraint.constant = keyboardFrame.size.height
                    self.captionTextFieldTopConstraint.constant = self.screenHeight - keyboardFrame.size.height - self.topLayoutGuide.length - self.captionTextFieldHeight
                    self.view.layoutIfNeeded()
                })
   
            }
        }
    }

    func keyboardWillHide(_ notification: Notification) {
        //get the height of the keyboard that will show and then shift the text field down by that amount
        
        if self.captionTextField.text == "" {
            self.captionTextField.isHidden = true
            mirrorCaptionButton.isHidden = true
            centerFlexibleSpace.isEnabled = false
        }
        
            //this makes the text box movement animated so it looks smoother:
            UIView.animate(withDuration: 1.0, animations: {
                //moves the caption back to its original location:
                self.captionTextFieldTopConstraint.constant = self.vetCaptionTopConstraint(self.captionYValue)
                

            })
        // If the user has entered no text in the titleTextField, reset it to how it was originally:
        if self.titleTextField.text == "" {
            self.titleTextField.text = enterTitleConstant
            self.titleTextField.textColor = UIColor.gray
            self.titleHasBeenTapped = false
            
            if captionTextField.text != "" {
                mirrorCaptionButton.isHidden = false
                centerFlexibleSpace.isEnabled = true
            }
        } else if titleTextField.text != enterTitleConstant  {
            mirrorCaptionButton.isHidden = true
            centerFlexibleSpace.isEnabled = false
        }
            self.view.layoutIfNeeded()
        
        //This is here because the title was somehow getting lost between it displaying correctly in the text field, and the publish button being tapped.
        print("titleTextField value at the end of hiding the keyboard is: \(titleTextField.text!)")

    }
    
    // This dismisses the keyboard when the user clicks the DONE button on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    

    @IBAction func mirrorCaptionButtonTapped(_ sender: Any) {
        
        // code in here should make the text in the caption equal the text in the title.
        // if it's too long it should truncate and then pop up with a message that says "title text shortened" or something like that.
        
        titleTextField.text = captionTextField.text
        titleTextField.textColor = UIColor.black
        
    }
    
    func resetTitleTextField() {
        self.titleTextField.text = enterTitleConstant
        self.titleTextField.textColor = UIColor.gray
        currentTitle = ""
    }
    
    
    @IBAction func otherImageThumbnailTapped(_ sender: Any) {
        
        switch currentCompare.creationPhase {
            
        case .reEditingFirstPhoto:
            currentCompare.imageBeingEdited1 = createImageBeingEdited()
            currentCompare.creationPhase = .reEditingSecondPhoto
            
            
        case .reEditingSecondPhoto:
            currentCompare.imageBeingEdited2 = createImageBeingEdited()
            currentCompare.creationPhase = .reEditingFirstPhoto
            
        default:
            print("Error in CameraViewController.otherImageThumbnailTapped: unexpected enum value for currentCompare.creationPhase")
        }
        
        self.viewWillAppear(false)
        self.viewDidLoad()
        self.viewDidAppear(false)
    }
    
    
    
    // this should be renamed to autoBlurFaces
    @IBAction func enableBlurring(_ sender: UIButton) {
        //self.lockScrollView()
        blurringInProgressLabel.isHidden = false
        self.enableBlurringButton.isHidden = true
        self.clearBlursButton.isHidden = false
        //self.returnToZoomButton.isHidden = false
        self.blurringEnabled = true
        //the next 2 lines blur detected faces but don't set the blurred image to currentImage yet
        
        currentImage = imageView.image! //this saves a copy of the unblurred image
        
        blurFace.setImage(image: imageView.image)
        imageView.image = blurFace.blurFaces()
        if numFaces < 1 {
            noFacesDetectedMessage()
            self.enableBlurringButton.isHidden = false
            self.clearBlursButton.isHidden = true
        }
        
        blurringInProgressLabel.isHidden = true
        
        //currentImage = pixellate(image: currentImage)
        //imageView.image = currentImage
        // What I will ultimately need to do is only modify imageView.image and then store that image to currentImage when
        // the user clicks publish, that way I can revert back to the non-blurred image at any moment by 
        // reassigning currentImage to the imageView.image
    }
    
    public func noFacesDetectedMessage() {
        let alertController = UIAlertController(title: "Tangerine Detected No Faces!", message: "Press and hold each face to manually blur.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    /*
    @IBAction func returnToZoom(_ sender: Any) {
        self.returnToZoomButton.isHidden = true
        self.clearBlurs()
        self.unlockScrollView()
        self.enableBlurringButton.isHidden = false
        self.clearBlursButton.isHidden = true
        self.blurringEnabled = false
    
    }
    */
    
    
    //Enables user to long press image for flesh colored transluscent circle (2 of 2):
    
    func manualBlur(location: CGPoint, radius: CGFloat) {
        //blurringInProgressLabel.isHidden = false
        
        
        
        
        blurFace.setImage(image: imageView.image)
        
        //I need a way to pass the tapped location on the image rather than on the screen
        
        // ways to convert it:
        // take zoomscale into account
        // take scrollview offset into account
        // take image's actual size in comparision to its apparent size in imageView into account.

        
        imageView.image = blurFace.manualBlurFace(at: location, with: radius)
        //self.drawCircle(tappedLoc)
        

        
        //if blurringEnabled == true {
            //self.drawCircle(tappedLoc)
        //} else {
            // this is where the label need to be made to appear to tell the user to leave cropping mode before trying to blur.
        //}
        //blurringInProgressLabel.isHidden = true
    }
    
    // This calls code in ImageMethods.swift, and manually blurs a location using a radius that depends on press time duration (in seconds).
    // Press less than 1.5 sec = small radius. Press more than 1.5 sec = large radius.
    func userPressed(_ pressImageGesture: UILongPressGestureRecognizer){
        
        
        
        if (pressImageGesture.state == UIGestureRecognizerState.began) {
            print("Long press detected.")
            
            // a cool thing to have here would be a bar that gets bigger on the screen the longer the user holds down
            // in order to give them a visual indication of how big the blur radius is going to be, but alas,
            // perhaps for an updated version later on.
            
            blurringInProgressLabel.text = ":: setting blur radius ::"
            blurringInProgressLabel.isHidden = false
            // we have to call this in order to "start the stopwatch" so we can measure how long the user presses down:
            handleRecognizer(gesture: pressImageGesture)
            
            

            
            
            
            
            return
        } else if (pressImageGesture.state == UIGestureRecognizerState.ended) {
            print("Long press ended.")
            blurringInProgressLabel.text = ":: blurring in progress ::"
            //blurringInProgressLabel.isHidden = true

 
            print("userPressed activated.")
            //userPressedCounter = 0

            clearBlursButton.isHidden = false
            
            
            // So far this is the most natural ratio I've been able to determine as far as hold down time to blur size ratio multiplier
            // The idea seems to be around 130 radius size units for every second of hold down, on a 1000 units wide scree
            blurRadiusMultiplier = computeUnderlyingToDisplayedRatio(passedImage: currentImage, screenWidth: screenWidth) * 40

            print("setting blurRadiusMultiplier to: \(blurRadiusMultiplier)")

            
        
            // This takes the amount of time the user held down, multiplies by the blurRadiusMultiplier to get the radius
            let blurRadiusToBePassed: CGFloat = blurRadiusMultiplier * CGFloat(handleRecognizer(gesture: pressImageGesture))
            // This takes the radius from above as well as the location where the user pressed and blurs an oval shaped area
            // print("scrollView hieght is: \(imageView.bounds.height)")

        
            //print("converting point...")
            //print("starting point was: \(pressImageGesture.location(in: imageView))")
            //print("scrollView content offset is: \(scrollView.contentOffset)")
        
            // We pass these two values in for contentOffset and zoomScale because our coordinate point info is coming from the image itself
            //  which is oblivious to what the scrollView is doing. The point come directly from the image,
            //  regardless of how it looks in the scrollView.
            let zeroContentOffset: CGPoint = CGPoint(x: 0, y: 0)
            let noZoom: CGFloat = 1.0
        
            // This line translates the coordinates from the UIImageView to the coordinates on the underlying image.
            var convertedPointToBeBlurred: CGPoint = computeOrig(passedImage: currentImage, pointToConvert: pressImageGesture.location(in: imageView), screenWidth: phoneScreenWidth, contentOffset: zeroContentOffset, zoomScale: noZoom)
        
        
        
            // We reverse the y coordindate because the mask image that will be blurred is a CIImage.
            // CIImage coordinates start from with the origin at the bottom left vice the top left.
            convertedPointToBeBlurred.y = currentImage.size.height - convertedPointToBeBlurred.y //+ (blurRadiusToBePassed/2)

        
            //print("converted point is: \(convertedPointToBeBlurred)")
    
            //pressImageGesture.location(in: self.view)
        
            manualBlur(location: convertedPointToBeBlurred, radius: blurRadiusToBePassed)
        
        
        
            /*
             if handleRecognizer(gesture: pressImageGesture) < 1.5 {
             //manualBlur(radius: 150.0, location: pressImageGesture.location(in: self.view))
             print("user pressed location: \(pressImageGesture.location(in: self.imageView))")
             manualBlur(radius: 150.0, location: pressImageGesture.location(in: self.view))
            
             } else {
                manualBlur(radius: 300.0, location: pressImageGesture.location(in: self.view))
             }
             */
        
            blurringInProgressLabel.isHidden = true
        }
    }
    
    // This method allows us to find out how long the user has been pressing on the screen for an extended duration
    // It returns that duration in seconds. We use it in userPressed() to determine what the blur radius should be.
    func handleRecognizer(gesture: UILongPressGestureRecognizer) -> Double {
        var duration: TimeInterval = 0
        
        
        switch (gesture.state) {
        case .began:
            //Keeping start time...
            self.pressStartTime = NSDate.timeIntervalSinceReferenceDate
            
        case .ended:
            //Calculating duration
            duration = NSDate.timeIntervalSinceReferenceDate - self.pressStartTime
            //Note that NSTimeInterval is a double value...
            print("Duration : \(duration)")
            
        default:
            break;
        }
        
        return duration
    }
    
    /*
    let pressImageGesture = UILongPressGestureRecognizer(target: self, action: #selector(CameraViewController.userPressed(_:) ))
    imageView.addGestureRecognizer(pressImageGesture)
    
    let longPressImageGesture = UILongPressGestureRecognizer(target: self, action: #selector(CameraViewController.userLongPressed(_:)))
    imageView.addGestureRecognizer(longPressImageGesture)
    */
    
    // this is just here for testing purposes right now (to see where user tapped for blur)
    // And it doesn't really even work. Can be deleted.
    func drawCircle(_ circleCenter: CGPoint) {
        let circlePath = UIBezierPath(arcCenter: circleCenter, radius: CGFloat(20), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        shapeLayer.fillColor = blurColor.cgColor //blurColor is defined at the top of this swift file
        //you can change the stroke color
        shapeLayer.strokeColor = blurColor.cgColor
        //you can change the line width
        shapeLayer.lineWidth = 1.0
        
        view.layer.addSublayer(shapeLayer)
    }
 
    // This clears out all the translucent circles we drew to blur out the face
    /*
    func clearBlurs() {
        for layer: CALayer in self.view.layer.sublayers! {
            if layer is CAShapeLayer {
                layer.removeFromSuperlayer()
            }
            
        }
        
        // This is a closure expression that does the same thing as above minus the if statement
        //self.view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        // There is definitely a sexier way to do this whole thing with closures but the above works
    }
    */
 
    @IBAction func clearBlursTapped(_ sender: UIButton) {
        //self.clearBlurs()
        
        imageView.image = unblurredImageSave
        blurFace = BlurFace(image: unblurredImageSave)
        self.enableBlurringButton.isHidden = false
        self.clearBlursButton.isHidden = true
        self.blurringEnabled = false
        
    }
    
    func lockScrollView() {
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 1.0
        self.scrollView.isScrollEnabled = false
    }
    
    func unlockScrollView() {
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        self.scrollView.isScrollEnabled = true
    }
    
    
    // Rewritten version of flattenViews iterating through all CALayers rather than UIViews
    /*
    func flattenViews() -> UIImage? {
        // Return nil if <allViews> empty
        /*if (allViews.isEmpty) {
            return nil
        }*/
        
        // If here, compose image out of views in <allViews>
        // Create graphics context
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            context.interpolationQuality = CGInterpolationQuality.high
        } else {
            print("UIGraphicsGetCurrentContext() failed, nil image returned")
            return nil
        }
        
        // Draw each view into context
        for layer: CALayer in self.view.layer.sublayers! as UIView {
            curView.drawHierarchy(in: curView.frame, afterScreenUpdates: false)
        }
        
        // Extract image & end context
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Return image
        return image
    }
    
 */
    

    
    
    
    // Flattens <allViews> into single UIImage - not implemented yet
/*    func flattenViews(allViews: [UIView]) -> UIImage? {
        // Return nil if <allViews> empty
        if (allViews.isEmpty) {
            return nil
        }
        
        // If here, compose image out of views in <allViews>
        // Create graphics context
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            context.interpolationQuality = CGInterpolationQuality.high
        } else {
            print("UIGraphicsGetCurrentContext() failed, nil image returned")
            return nil
        }
        
        // Draw each view into context
        for curView in allViews {
            curView.drawHierarchy(in: curView.frame, afterScreenUpdates: false)
        }
        
        // Extract image & end context
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Return image
        return image
    } */
    
    
    
    
    
    
    // Allows the user to zoom within the scrollView
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
 
 

    // Takes an image passed in, uses the zoomscale and offset of the scrollview to crop out the visible
    // portion of the image, and return a new image using only the cropped portion.
    func cropImage(_ storedImage: UIImage) -> UIImage {
 
        // determines whether the image is portrait, landscape, or square. Portraits with different h to w ratios
        // would still be considered portraits. We use this value later to avoid redundant logic statements.
        
        let imageAspectType = computeImageAspectType(passedImage: storedImage)
        
        /*
        var imageAspectType: ImageAspectType {
            if storedImage.size.width < storedImage.size.height { //portrait
                return .isPortrait
            } else if storedImage.size.width > storedImage.size.height { //landscape
                return .isLandscape
            } else { //square image already
                return .isSquare
            }
        }
        */
        
        
        /*
        print("imageView width: \(imageView.bounds.size.width)")
        print("screen width: \(UIScreen.main.bounds.size.width)")
        print("actual image width: \(storedImage.size.width)")
        */
        
        //the next two lines take away the built in effect of zoomScale on the content offset:
        // They are still in the scale of the scrollview though and cannot yet be used to edit the image itself.
        
        
        // 1/16/17:
        //let unzoomedOffsetX = scrollView.contentOffset.x / scrollView.zoomScale
        //let unzoomedOffsetY = scrollView.contentOffset.y / scrollView.zoomScale
              
        
        
        //this stores the width of the actual displayed scrollview/imageview on the iPhone screen:
        // if the image is a square or landscape, then it is also the value of the displayed image width
        // Keep in mind, the real image has been resized to fit into the scrollview though
        // so to manipulate the image itself, we must use values translated by the underlyingToDisplayedRatio (seen below)
        
        //public let phoneScreenWidth = UIScreen.main.bounds.size.width

        //this stores the size of the actual image that is in memory (and currently being resized to fit on the iPhone screen):
        let underlyingImageWidth = storedImage.size.width
        let underlyingImageHeight = storedImage.size.height
        
        //this determines the "scale" as far as how many times bigger or smaller the longest side of the displayed image is to the actual size of the longest side of the stored image in memory:
        
        let underlyingToDisplayedRatio: CGFloat = computeUnderlyingToDisplayedRatio(passedImage: storedImage, screenWidth: phoneScreenWidth)
        
        /*
        var underlyingToDisplayedRatio: CGFloat {
            if imageAspectType == ImageAspectType.isPortrait {
                return underlyingImageHeight / phoneScreenWidth
            } else { //encompasses landscape and square images
                return underlyingImageWidth / phoneScreenWidth
            }
        }
        */
        
        // At and above zoomscale, we are now cutting off some of the height AND width. Below it, we are only cutting off height OR width because it's not zoomed in enough yet for us to need to trim both of the dimensions.
        var zoomThreshold: CGFloat { // follows the form: big/little to get a value > 1
            if imageAspectType == ImageAspectType.isPortrait {
                return underlyingImageHeight / underlyingImageWidth
            } else if imageAspectType == ImageAspectType.isLandscape {
                return underlyingImageWidth / underlyingImageHeight
            } else { //square image already
                return 1.0 //this means we will start cropping both sides at the same time (at a zoomscale of 1)
            }
        }
        
        // This returns the value of the longest side cut down by zoomScale
        var squareSideLength: CGFloat {
            if imageAspectType == ImageAspectType.isPortrait {
                return underlyingImageHeight / scrollView.zoomScale
            } else {
                return underlyingImageWidth / scrollView.zoomScale
            }
        }
        
        var cropSizeWidth: CGFloat {
            if imageAspectType == ImageAspectType.isPortrait && scrollView.zoomScale < zoomThreshold {
                return underlyingImageWidth
            } else {
                return squareSideLength
            }
        }
        
        var cropSizeHeight: CGFloat {
            if imageAspectType == ImageAspectType.isLandscape && scrollView.zoomScale < zoomThreshold {
                return underlyingImageHeight
            } else {
                return squareSideLength
            }
        }

        // This computes the linear value of the white space either to the sides or above and below the non-square image.
        // The actual value returned is only one of the two rectangles, not the total added up space. Hence the "/ 2."
        
        //let whiteSpace: CGFloat = computeWhiteSpace(passedImage: storedImage)
        
        /*
        var whiteSpace: CGFloat {
            if imageAspectType == ImageAspectType.isPortrait {
                return (underlyingImageHeight - underlyingImageWidth) / 2
            } else if imageAspectType == ImageAspectType.isLandscape {
                return (underlyingImageWidth - underlyingImageHeight) / 2
            } else { //it's a square, there is no white space
                return 0.0
            }
        }
        */
        

        //the next two computed properties (origX and origY) store the x and y coordinates that the system will use to go to the underlying stored image and use as the upper left corner of the square that it crops from it
        
        /*
        var origX: CGFloat {
            //if it's not a square, we need to account for the white space.
            //Since we know the photo is centered between the white space, we know that half of the white space
            // is on either side of it. (already factored into the white space value)
            if imageAspectType == ImageAspectType.isPortrait {
                //print("returning \((unzoomedOffsetX * underlyingToDisplayedRatio) - whiteSpace) for origX")
                return (unzoomedOffsetX * underlyingToDisplayedRatio) - whiteSpace
            } else {
                return unzoomedOffsetX * underlyingToDisplayedRatio
            }
        }
    
        var origY: CGFloat {
            if imageAspectType == ImageAspectType.isLandscape {
                //print("returning \((unzoomedOffsetY * underlyingToDisplayedRatio) - whiteSpace) for origY")
                return (unzoomedOffsetY * underlyingToDisplayedRatio) - whiteSpace
            } else {
                return unzoomedOffsetY * underlyingToDisplayedRatio
            }
        }
        */

        // zoomScale tells us how far we are zoomed in at a given moment. 2x zoom = zoomScale of 2.
        //print("zoomscale: \(scrollView.zoomScale)")
        //print("content offset x, y: \(scrollView.contentOffset.x), \(scrollView.contentOffset.y)")
        //print("origin: \(origX), \(origY)")
        
        // we store a copy of the origin (0,0) because that is the point on the scrollview that we want to convert to a point on the image
        // (for cropping). Then we pass it into the converion method computeOrig
        let pointZeroZero: CGPoint = CGPoint(x: 0.0, y: 0.0)
        
        let orig = computeOrig(passedImage: storedImage, pointToConvert: pointZeroZero, screenWidth: phoneScreenWidth, contentOffset: scrollView.contentOffset, zoomScale: scrollView.zoomScale)
        
        
        let crop = CGRect(x: orig.x,y: orig.y, width: cropSizeWidth, height: cropSizeHeight)
        if let cgImage = storedImage.cgImage?.cropping(to: crop) {
            let image:UIImage = UIImage(cgImage: cgImage) //convert it from a CGImage to a UIImage
            return image
        } else {
            print("cropping failed - image was nil")
            //let alertController = UIAlertController(title: "Cropping Failed", message: nil, preferredStyle: .Alert)
            //presentViewController(alertController, animated: true, completion: nil)
            return storedImage
        }
    }
    
    
    
    
        // MARK: - UIImagePickerControllerDelegate Methods
        
        /* enabled the imagePicker in CameraViewController, this is now done in AVCameraViewController
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                imageView.contentMode = .scaleAspectFit
                print("just picked the image")
                //currentImage = self.fixOrientation(img: pickedImage)
                print("fixing image orientation inside imagePickerController delgate method")
                currentImage = self.sFunc_imageFixOrientation(img: pickedImage)
                unblurredImageSave = currentImage
                imageView.image = currentImage
                
                
            }
            
            dismiss(animated: true, completion: nil)
        }
        */
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
    
    
    //Not using this right now:
    @IBAction func userTappedDownTextField(_ sender: AnyObject) {
    }
    
    // Can be deleted later. Just have to unlink the IBAction. Deleting this code will cause SIGABRT otherwise.
    @IBAction func captionTextFieldBeginEditing(_ sender: AnyObject) {
        //captionHasBeenTapped = self.resetTextField(captionTextField, tappedYet: captionHasBeenTapped)
        //self.captionTextField.text = ""
    }

    
    @IBAction func titleTextFieldBeginEditing(_ sender: AnyObject) {
        //self.captionTextField.center.y = tappedLoc.y Not sure why tf this is here
        // This method clears the text field to be ready to be typed in
        //  and it also reverses the value of titleHasBeenTapped
        titleHasBeenTapped = self.resetTextField(titleTextField, tappedYet: titleHasBeenTapped)
    }
    
    @IBAction func titleTextFieldValueChanged(_ sender: AnyObject) {
    }
    //this sets the text field that we pass in to no text and black text, as long as we have a variable to track whether it has been tapped already:
    func resetTextField(_ textField: UITextField, tappedYet: Bool) -> Bool {
        print("resetTextField called")
        if tappedYet == false {
            textField.text = ""
            textField.textColor = UIColor.black
        }
        return true
    }
    
    func createImageBeingEdited() -> imageBeingEdited {
        
        let captionToBePassed = createCaption()
        
        let unblurredImageToBePassed: UIImage = self.sFunc_imageFixOrientation(img: unblurredImageSave)
        currentImage = self.sFunc_imageFixOrientation(img: self.imageView.image!) //sets the current image to the one we're seeing and essentially saves the blurring to the currentImage, it still hasn't been cropped at this point yet though
        let blurredUncroppedToBePassed: UIImage = currentImage
        currentImage = self.cropImage(currentImage) // now we crop it
        let blurredCroppedToBePassed = currentImage // now we store the blurred cropped current image here so we can pass it ino the iBE
        
        // the purpose of savng these values is so that if the user decides to edit one of the compares
        //  after they have been created, we can display the image in CameraViewController as it would have looked right before
        //  cropping, without actually cropping it.
        let contentOffsetToBePassed: CGPoint = scrollView.contentOffset
        let zoomScaleToBePassed: CGFloat = scrollView.zoomScale

        // Create a new imageBeingEdited:
        let iBE = imageBeingEdited(iBEtitle: currentTitle, iBEcaption: captionToBePassed, iBEimageCleanUncropped: unblurredImageToBePassed, iBEimageBlurredUncropped: blurredUncroppedToBePassed, iBEimageBlurredCropped: blurredCroppedToBePassed, iBEContentOffset: contentOffsetToBePassed, iBEZoomScale: zoomScaleToBePassed, blursAdded: blursAddedByEditor)
        
        return iBE
    }
    
    func createAsk() {
        print("titleTextField.text at the beginning of createAsk() is: \(titleTextField.text!)")
        // create a new Ask using the photo, title, and timestamp
        
        currentImage = self.sFunc_imageFixOrientation(img:self.imageView.image!) //sets the current image to the one we're seeing and essentially saves the blurring to the currentImage
        currentImage = self.cropImage(currentImage)
        
        

        print("fixing image orientation inside createAsk() ")
        var imageToCreateAskWith: UIImage = self.sFunc_imageFixOrientation(img: currentImage)
        
        let captionToCreateAskWith = createCaption()

        // To fix back to normal, replace imageToCreateAskWith with currentImage in the next line:
        let newAsk = Ask(title: currentTitle, photo: imageToCreateAskWith, caption: captionToCreateAskWith, timePosted: Date())
        
        // MARK: caption - will also need to initialize a caption string (using the photo editor)
        
        print("New Ask Created! title: \(newAsk.askTitle), timePosted: \(newAsk.timePosted)")

        // Once the Ask is created it is appended to the main array within a Container:
        
        // Creates a new container containing the newAsk and a flag that tells the container it is holding an Ask, as well as a new ReviewCollection that is initialized.
        
        let cont = Container.ContainerIdentification(userID: myUser.publicInfo.userName, containerNumber: myUser.lowestAvailableContainerIDNumber())
        
        let containerToBeAppended = Container(containerID: Container.ContainerIdentification(userID: myUser.publicInfo.userName, containerNumber: myUser.lowestAvailableContainerIDNumber()),
                                              containerType: .ask,
                                              question: newAsk,
                                              reviewCollection: ReviewCollection(type: .ask))
        
        
        // this needs to change to my user's containerCollection
        myUser.containerCollection.append(containerToBeAppended)
        
        //let testAsk = containerCollection.last as! Ask
        //print("New Ask now appended to containerCollection. Last Ask in the Array is title: \(testAsk.askTitle), timePosted: \(testAsk.timePosted)")
        clearOutCurrentCompare()
        self.backTwo() //back to main
     
        // The main array will be sorted by time stamp by the AskTableViewController prior to being displayed in the table view.
    }
    

    @IBAction func publishButtonTapped(_ sender: Any) {
        print("publish button tapped")

        let actionNo = UIAlertAction(title: "Enter a Title", style: .default) {
            UIAlertAction in
            // 'No' selection in this case should do nothing. It just clears the message and takes the user back to editing.
        }
        
        
        if currentCompare.creationPhase == compareImageState.firstPhotoTaken { //aka there is only one image and it should make an Ask
            
            
            actionYes = UIAlertAction(title: "Proceed With No Title", style: .default) {
                UIAlertAction in
                print("Proceed with no title tapped")
                currentTitle = "(no title)"
                self.createAsk()
                
                }
            finishEditing(whatToCreate: .ask)

            //self.navigationController?.popViewController(animated: true) //rtn to main page
            //let arrayOfViewsToBeMerged: [UIView] = [currentImage]
        } else { //aka we are for sure making a compare
            actionYes = UIAlertAction(title: "Proceed With No Title", style: .default) {
                UIAlertAction in
                print("Proceed with no title tapped")
                currentTitle = "(no title)"
                self.createHalfOfCompare()

            }
            finishEditing(whatToCreate: .compare)
        }
    }
    // This is similar to publish except it puts some data on hold and then takes the user back to the avCamera to add a second picture.
    @IBAction func compareButtonTapped(_ sender: Any) {
        
        currentCompare.isAsk = false
        //whatToCreate = .compare1
        
        /*
        let actionNo = UIAlertAction(title: "Whoops Let Me Enter One", style: .default) {
            UIAlertAction in
            // if user elects to go back to editing the image, we need to keep the assumption that they still might create an ask so that we don't take away the createCompare button if they navigate back to the avCamera and reload the view without creating anything
            // I don't think we need this anymore.
            //currentCompare.isAsk = true
            //whatToCreate = .ask
        }
        */
 
 
        actionYes = UIAlertAction(title: "Proceed With No Title", style: .default) {
            UIAlertAction in
            print("Proceed with no title tapped")
            currentTitle = "(no title)"
            
            self.createHalfOfCompare()
            // need code to push compare editor (Pic2) onto the stack and show it
            
        }
        

        
        
        finishEditing(whatToCreate: .compare)

        
        
        //returnToAVCameraViewController()
        
        //self.navigationController?.popViewController(animated: true) //rtn to avCameraViewController
        ////////MARK: NEED MORE CODE HERE TO RESET THE CAMERA TO NORMAL
    }
    
    
    @IBAction func reduceToAskButtonTapped(_ sender: Any) {
        //This button should be hidden at the onset and unhidden when 2 is hidden.
        //Any time the 2 is unhidden, this should be hidden again.
        //Tapping this button should do these things:
        
        
        //-Store the current iBE to currentCompare.imageBeingEdited1
        currentCompare.imageBeingEdited1 = createImageBeingEdited()
        //-Store nil to currentCompare.ImageBeingEdited2
        currentCompare.imageBeingEdited2 = nil
        //-Change the flag to .firstPhotoTaken
        currentCompare.creationPhase = .firstPhotoTaken
        //-Set isAsk to true
        currentCompare.isAsk = true
        //-Reload all three view methods
        viewWillAppear(false)
        viewDidLoad()
        viewDidAppear(false)
        
        // Without this the title text field just resets because 
        //  we called ViewDidAppear after switching the flag to .firstPhotoTaken
        if let iBE = currentCompare.imageBeingEdited1 {
            titleTextField.text = iBE.iBEtitle
            if titleTextFieldIsBlank == false {
                // if the title is not blank, then:
                titleTextField.textColor = .black
            } else { //aka if tTF is one of the 3 blank conditions:
                titleTextField.text = enterTitleConstant
                //titleTextField.textColor should already be gray
            }
            
        }
        
    }
    


        
        
   
    
    
    
    func createCaption() -> Caption {
        // Create a new caption object from what the user has entered at present
        let captionLocationToSet: CGFloat = captionTextFieldTopConstraint.constant/screenWidth

        var newCaption: Caption
        if let captionText = captionTextField.text {
            // recall that if captionText is "", the .exists Bool will return false,
            //   which is functionality that could be replaced by making the caption an optional value.
            newCaption = Caption(text: captionText, yLocation: captionLocationToSet)
        } else { // Occurs if caption text is nil for some reason. This really should never happen.
            newCaption = Caption(text: "", yLocation: captionLocationToSet)
        }
        
        return newCaption
    }
    
    
    
    func createHalfOfCompare() {
 
        let iBE = createImageBeingEdited()
        
        if currentCompare.creationPhase == .firstPhotoTaken {
        currentCompare.imageBeingEdited1 = iBE // Stores the imageBeingEdited (iBE) to the first half of the public value known as currentCompare, then goes back to AVCameraViewController to get the second image
            print("creationPhase is \(currentCompare.creationPhase). Data stored iBE to currentCompare.imageBeingEdited1")
            returnToAVCameraViewController()
            
        } else { //everything after this segues to the ComparePreviewViewController
            if currentCompare.creationPhase == .secondPhotoTaken || currentCompare.creationPhase == .reEditingSecondPhoto {
                currentCompare.imageBeingEdited2 = iBE
                print("stored iBE to currentCompare.imageBeingEdited2")
            } else { //this will only happen if currentCompare.creationPhase == .reEditingFirstPhoto
                currentCompare.imageBeingEdited1 = iBE
                print("stored iBE to currentCompare.imageBeingEdited1")
            }
            // whatToCreate = .ask // The next time CameraViewController loads, it will be ready to create an ask unless user taps compareButton
            
            
            // sets the graphical view controller with the storyboard ID "comparePreviewViewController" to nextVC
            print("Pushing comparePreviewViewController")
            let nextVC = self.storyboard?.instantiateViewController(withIdentifier: "comparePreviewViewController") as! ComparePreviewViewController
            // pushes comparePreviewViewController onto the nav stack
            self.navigationController?.pushViewController(nextVC, animated: true)
            
            //Not sure why this one doesn't work. If it did it would be more elegant:
            //self.navigationController?.pushViewController(ComparePreviewViewController, animated: true)
            
        }
        

    }
    
    func finishEditing(whatToCreate: objectToCreate) {
        
        print("inside finishEditing()")
        print("creation phase is: \(currentCompare.creationPhase)")
        
        /*
 
 if we're in case 1:
         check for title, make an ask
if we're in case 2:
         check for title
         store the recent changes to the current iBE
         segue to cPVC
else that means we're in case 3 or 4
         dont check for title
         store the recent changes to the current iBE
         segue to cPVC
 

 
         */
        
        //This causes the system to bypass the title checker if the user has come back from ComparePreviewViewController to edit
        if currentCompare.creationPhase == .reEditingFirstPhoto || currentCompare.creationPhase == .reEditingSecondPhoto {
            createHalfOfCompare()
            return
        }
        
        if let title = titleTextField.text {
            if titleTextFieldIsBlank == true {
                let alertController = UIAlertController(title: "Title Not Provided", message: "Publish your photo without a title?", preferredStyle: .actionSheet)
                    
                
                let actionNo = UIAlertAction(title: "Enter Title", style: .default) {
                    UIAlertAction in
                        // if user elects to go back to editing the image, we need to keep the assumption that they still might create an ask so that we don't take away the createCompare button if they navigate back to the avCamera and reload the view without creating anything
                        //currentCompare.isAsk = true
                        //whatToCreate = .ask
                }
                alertController.addAction(actionNo)
                alertController.addAction(actionYes)
                present(alertController, animated: true, completion: nil)
            
            } else {
                currentTitle = title
                print("whatToCreate = \(whatToCreate)")
                if whatToCreate == .ask {
                    createAsk()
                } else if whatToCreate == .compare {
                    createHalfOfCompare()
                }
                    
            }
        }
    }
    
    
    func returnToAVCameraViewController() {
        self.navigationController?.popViewController(animated: true)
    }
    
   
    func backTwo() {
        
        print("backTwo() called")
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
        
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {    
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    // Keep in mind, this only fixes an image if the image knows that it is not upright
    // If I store a sideways to another image variable, the new image variable believes that it is upright already and this
    //  method will not work on it. 
    // The key to making this work is to apply it as early on in the data chain as possible.
    // In other words, as close to the raw image either coming in from the camera or photo libary as possible.
    public func sFunc_imageFixOrientation(img:UIImage) -> UIImage {
        
        // No-op if the orientation is already correct

        if (img.imageOrientation == UIImageOrientation.up) {
            return img;
        }

        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransform.identity
      
        if (img.imageOrientation == UIImageOrientation.down
            || img.imageOrientation == UIImageOrientation.downMirrored) {
            
            transform = transform.translatedBy(x: img.size.width, y: img.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi)) //seems to be the number of radians we rotate the image
        }
        
        if (img.imageOrientation == UIImageOrientation.left
            || img.imageOrientation == UIImageOrientation.leftMirrored) {
            transform = transform.translatedBy(x: img.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2))
        }
        
        if (img.imageOrientation == UIImageOrientation.right
            || img.imageOrientation == UIImageOrientation.rightMirrored) {
            transform = transform.translatedBy(x: 0, y: img.size.height);
            transform = transform.rotated(by: CGFloat(-Double.pi / 2));
        }
        
        if (img.imageOrientation == UIImageOrientation.upMirrored
            || img.imageOrientation == UIImageOrientation.downMirrored) {
            transform = transform.translatedBy(x: img.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if (img.imageOrientation == UIImageOrientation.leftMirrored
            || img.imageOrientation == UIImageOrientation.rightMirrored) {
            transform = transform.translatedBy(x: img.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
        }

        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx:CGContext = CGContext(data: nil, width: Int(img.size.width), height: Int(img.size.height),
                                      bitsPerComponent: img.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                      space: img.cgImage!.colorSpace!,
                                      bitmapInfo: img.cgImage!.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        
        if (img.imageOrientation == UIImageOrientation.left
            || img.imageOrientation == UIImageOrientation.leftMirrored
            || img.imageOrientation == UIImageOrientation.right
            || img.imageOrientation == UIImageOrientation.rightMirrored
            ) {
            //I'm not sure why there is even an if statement since they perform the same operation in both cases...
            ctx.draw(img.cgImage!, in: CGRect(x:0,y:0,width:img.size.height,height:img.size.width))
            
        } else {
            ctx.draw(img.cgImage!, in: CGRect(x:0,y:0,width:img.size.width,height:img.size.height))
        }
        
        
        // And now we just create a new UIImage from the drawing context
        let cgimg:CGImage = ctx.makeImage()!
        let imgEnd:UIImage = UIImage(cgImage: cgimg)
        
        return imgEnd
        
    }
    
    //this is for testing the image rotation. May be deleted.
    public func printImageOrientations (passedImage: UIImage) {
        print("newAsk.image orientation is upright \(passedImage.imageOrientation == UIImageOrientation.up)")
        print("newAsk.image orientation is left \(passedImage.imageOrientation == UIImageOrientation.left)")
        print("newAsk.image orientation is right \(passedImage.imageOrientation == UIImageOrientation.right)")
        print("newAsk.image orientation is down \(passedImage.imageOrientation == UIImageOrientation.down)")
    }
    
    // This is set to a generic flesh tone. 
    // A better solution would be to either sample the color underneath where the user pressed
    //  or to use some kind of blurring algorithm to actually shift the pixel colors
    //  around randomly within the bounds of the circle.




    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // This is an alternate, more elegant method for fixing image rotation that I am not currently
    // using. It still runs into the original problem of needing to have the correct metadata.
    // Also, I'm not really sure what UIGraphicsGetImageFromCurrentImageContext() is doing.
    func fixOrientation(img:UIImage) -> UIImage {
        
        if (img.imageOrientation == UIImageOrientation.up) {
            return img;
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        //force unwrapped - may need to fix:
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
        
    }
    
    
}



// This code was pulled from this site: https://github.com/dcordero/BlurFace/commit/8378ba531dbc4ddc4bd07d974f5deb9488a218f8
// It is part of some larger program that detect the faces and then blurs them. Right now I'm just trying to figure out how to use this code to draw a circle on top of the currentImage.
// From there, I should be able to use the coordinates of where the user long taps to draw the circle where they long tapped, thus blurring the face.


/*

public class BlurFace {
    //private let ciDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil ,options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
    private var ciImage: CIImage!
    private var orientation: UIImageOrientation = .up
    //private lazy var features : [AnyObject]! = { self.ciDetector.featuresInImage(self.ciImage) }()
    private lazy var context = { CIContext(options: nil) }()
    
    // MARK: Initializers
    
    public init(image: UIImage!) {
        setImage(image: image)
    }
    public func setImage(image: UIImage!) {
        ciImage = CIImage(image: image)
        orientation = image.imageOrientation
        // features = nil
    }
    

    public func blurFaces() -> UIImage {
        let pixelateFilter = CIFilter(name: "CIPixellate")
        pixelateFilter.setValue(ciImage, forKey: kCIInputImageKey)
        pixelateFilter.setValue(max(ciImage!.extent().width, ciImage.extent().height) / 60.0, forKey: kCIInputScaleKey)
        
        var maskImage: CIImage?
        for feature in featureFaces() {
            let centerX = feature.bounds.origin.x + feature.bounds.size.width / 2.0
            let centerY = feature.bounds.origin.y + feature.bounds.size.height / 2.0
            let radius = min(feature.bounds.size.width, feature.bounds.size.height) / 1.5
            
            let radialGradient = CIFilter(name: "CIRadialGradient")
            radialGradient.setValue(radius, forKey: "inputRadius0")
            radialGradient.setValue(radius + 1, forKey: "inputRadius1")
            radialGradient.setValue(CIColor(red: 0, green: 1, blue: 0, alpha: 1), forKey: "inputColor0")
            radialGradient.setValue(CIColor(red: 0, green: 0, blue: 0, alpha: 0), forKey: "inputColor1")
            radialGradient.setValue(CIVector(x: centerX, y: centerY), forKey: kCIInputCenterKey)
            
            let croppedImage = radialGradient.outputImage.imageByCroppingToRect(ciImage.extent())
            
            let circleImage = croppedImage
            if (maskImage == nil) {
                maskImage = circleImage
            } else {
                let filter =  CIFilter(name: "CISourceOverCompositing")
                filter.setValue(circleImage, forKey: kCIInputImageKey)
                filter.setValue(maskImage, forKey: kCIInputBackgroundImageKey)
                
                maskImage = filter.outputImage
            }
        }
        
        let composite = CIFilter(name: "CIBlendWithMask")
        composite?.setValue(pixelateFilter?.outputImage, forKey: kCIInputImageKey) //I added the force unwrap ?'s
        composite.setValue(ciImage, forKey: kCIInputBackgroundImageKey)
        composite.setValue(maskImage, forKey: kCIInputMaskImageKey)
        
        let cgImage = context.createCGImage(composite.outputImage, fromRect: composite.outputImage.extent())
        return UIImage(CGImage: cgImage, scale: 1, orientation: orientation)!
    }
}
*/





