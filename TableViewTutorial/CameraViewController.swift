//
//  CameraViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 8/3/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit
import MobileCoreServices


class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UITextFieldDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var mirrorSwitch: UISwitch!
    @IBOutlet weak var captionTextFieldTopConstraint: NSLayoutConstraint!
    

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
    var captionFrameRect: CGRect = CGRect()
    var captionTextFieldHeight: CGFloat = 0.0
    var scrollViewFrameRect: CGRect = CGRect()
    var scrollViewHeight: CGFloat = 0.0
    var screenHeight: CGFloat = 0.0
    var screenWidth: CGFloat = 0.0
    var captionTopLimit: CGFloat = 0.0
    var captionBottomLimit: CGFloat = 0.0
    var captionLocationToSet: CGFloat = 0.0
    
    
    
    // I'm trying to make this a reference corner for the image to be cropped

    
    enum CameraError: Swift.Error {
        case noName
    }
    
    // MARK: Camera Needed    - > need to create and implement a camera option
    
    @IBAction func useCamera(_ sender: AnyObject) {
        // makes sure we have a camera, aka this is not the simulator
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera //I'm assuming the default is the back camera which is what we want
        } else {
            imagePicker.sourceType = .photoLibrary // if we're in the simulator it just redirects to the photo library
        }

        present(imagePicker, animated: true, completion: nil)
    
    }
    
    
    
    
    //This happens when the user clicks on the use camera roll bar button
    //Realistically I'd rather not ever use this except for testing since this
    //should be an app where users are in the moment and using pics they are taking
    //themselves. Like snapchap does.
    @IBAction func useCameraRoll(_ sender: AnyObject) {

        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeImage as String] //supposedly this prevents the user from taking videos
        
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
        // MARK: DELETE THIS this is just so that the sample image will keep loading for testing:
    override func viewDidAppear(_ animated: Bool) {
        //currentImage = UIImage(named: "NumberedColorGrid")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = currentImage
        titleHasBeenTapped = false
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
        self.captionFrameRect = self.captionTextField.frame
        self.captionTextFieldHeight = captionFrameRect.height
        // This gets the height of the screen for spacing things out later
        self.screenHeight = UIScreen.main.bounds.height
        
        // This will move the caption text box out of the way when the keyboard pops up:
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // This will move the caption text box back down when the keyboard goes away:
        NotificationCenter.default.addObserver(self, selector: #selector(CameraViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // This gets us the height of the caption text field to be used later for spacing things out correctly
        self.captionTextFieldHeight = self.captionTextField.frame.height
        
        // This gets us the height of the title text field to be used later for spacing things out correctly
        self.titleTextFieldHeight = self.titleTextField.frame.height
        
        // This sets up the min and max values that the caption's top contstraint can have and still be over the image
        self.captionTopLimit = self.topLayoutGuide.length + self.titleTextFieldHeight
        
        //self.scrollViewHeight = self.scrollView.frame.height
        print("scrollView height is: \(scrollViewHeight)")
        print("self.screenHeight is: \(self.screenHeight)")
        print("self.screenWidth is: \(UIScreen.main.bounds.width)")
        self.screenWidth = UIScreen.main.bounds.width
        
        
        // This gets the actual height of the image, not just as it is displayed but the actual file's height dimension:
        /*var imageHeight: CGFloat = 200 //magic number, fucking fix this
        if let iH = imageView.image?.size.height {
            imageHeight = iH
            print("stored image height is \(imageHeight)")
        } else {
            print("no image exists")
        }*/
        self.captionBottomLimit = self.captionTopLimit + screenWidth - self.captionTextFieldHeight
        
        

        
        //Enables tap on image to show caption (1 of 2):
        let tapImageGesture = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.userTappedImage(_:)))
        imageView.addGestureRecognizer(tapImageGesture)
        imageView.isUserInteractionEnabled = true
  
        //Enables user to drag caption around (1 of 2):
        let dragCaptionGesture = UIPanGestureRecognizer(target: self, action: #selector(CameraViewController.userDragged(_:)))
        captionTextField.addGestureRecognizer(dragCaptionGesture)
        captionTextField.isUserInteractionEnabled = true
            
    }
    //Enables tap on image to show caption (2 of 2):
    func userTappedImage(_ tapImageGesture: UITapGestureRecognizer){
        print("user tapped image")
        captionTextField.translatesAutoresizingMaskIntoConstraints = false
        tappedLoc = tapImageGesture.location(in: self.view)
        print("User tapped: \(tappedLoc)")
        
        
        //print("captionTextField.center.y = \(self.captionTextField.center.y)")
        
        if captionTextField.isHidden == true && titleTextField.isEditing == false {
            // Show the captionTextField:
            captionTextField.isHidden = false
            // Position the captionTextField where the user tapped:
            self.captionTextFieldTopConstraint.constant = tappedLoc.y - self.topLayoutGuide.length - (0.5 * captionTextFieldHeight)
            captionTextField.becomeFirstResponder()
            //self.captionTextField.center.y = tappedLoc.y
            
        } else {
            // if the caption is displayed and the user taps the image, dismiss the keyboard
            view.endEditing(true)
            print("back inside userTappedImage function")
            print("captionTextField.center.y= \(self.captionTextField.center.y)")
            print("end of userTappedImage function")
        }
    }
    
    //Enables user to drag caption around (2 of 2):
    func userDragged(_ dragCaptionGesture: UIPanGestureRecognizer){
        tappedLoc = dragCaptionGesture.location(in: self.view)
        captionLocationToSet = tappedLoc.y - self.topLayoutGuide.length - (0.5 * captionTextFieldHeight)
        self.captionTextFieldTopConstraint.constant = setCaptionTopConstraint(captionLocationToSet)
        
        //self.captionTextField.center.y = tappedLoc.y
        //This is more efficient: self.captionTextField.center.y = dragCaptionGesture.location(in: self.view).y
        print("tappedLoc.y: \(tappedLoc.y)")
    }
    
    
    // This determines whether the caption y value is within the prescribed limits within the bounds of the imageView and if it is not, returns the limit that it has crossed.
    func setCaptionTopConstraint(_ desiredLocation: CGFloat) -> CGFloat {
        
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
        if self.captionTextField.isEditing == true {
            //get the height of the keyboard that will show and then shift the text field up by that amount
            if let userInfoDict = notification.userInfo, let keyboardFrameValue = userInfoDict [UIKeyboardFrameEndUserInfoKey] as? NSValue {

                let keyboardFrame = keyboardFrameValue.cgRectValue
            
                //this makes the text box movement animated so it looks smoother:
                UIView.animate(withDuration: 0.8, animations: {
                    //this moves the text box based on how big the keyboard is:
                    //print("caption before: \(self.captionTextFieldBottomConstraint.constant)")
                    //This ends up sending the caption out of view behind the keyboard
                    //self.captionYValue = self.captionTextField.center.y
                    
                    // Save the captionTextField's Location so we can restore it after editing:
                    self.captionYValue = self.captionTextFieldTopConstraint.constant
                    
                    
                    print("should be setting captionTextFieldBottomConstraint.constant. KB frame height is: \(keyboardFrame.size.height)")
                    //self.captionTextFieldBottomConstraint.constant = keyboardFrame.size.height
                    self.captionTextFieldTopConstraint.constant = self.screenHeight - keyboardFrame.size.height - self.topLayoutGuide.length - self.captionTextFieldHeight
                
                    //print("caption after: \(self.captionTextFieldBottomConstraint.constant)")
                
                    //saves the old location of the caption:
                    //self.captionYValue = self.captionTextField.center.y
                    //moves the caption out of the way of the keyboard:
                    //This one doesn't seem to do anything:
                    //self.captionTextField.center.y = keyboardFrame.size.height - 10
                
                
                
                    self.view.layoutIfNeeded()
                })
   
            }
        }
    }
    
    
    // Am I ever even calling this?
    /*func textFieldShouldReturn(textField: UITextField!) -> Bool {
        captionTextField.resignFirstResponder()
        print("tFSR 1 called")
        return true
    }*/
    
    func keyboardWillHide(_ notification: Notification) {
        //get the height of the keyboard that will show and then shift the text field down by that amount
        
        if self.captionTextField.text == "" {
            self.captionTextField.isHidden = true
        }
        
            //this makes the text box movement animated so it looks smoother:
            UIView.animate(withDuration: 1.0, animations: {
                //this moves the text box back to its original location

                
                //moves the caption back to its old location:

                
                self.captionTextFieldTopConstraint.constant = self.captionYValue
                
                //print("keyboard hiding now. tappedLoc.y = \(self.tappedLoc.y)")
                //self.captionTextField.center.y = self.tappedLoc.y
                //print("captionTextField.center.y= \(self.captionTextField.center.y)")
                //self.captionTextField.center.y = self.captionYValue
            })
                //self.captionTextFieldBottomConstraint.constant = 0
        // If the user has entered no text in the titleTextField, reset it to how it was originally:
        if self.titleTextField.text == "" {
            self.titleTextField.text = "Enter a Private Title for Your Photo Here"
            self.titleTextField.textColor = UIColor.gray
            self.titleHasBeenTapped = false
        }
            self.view.layoutIfNeeded()
            



    }
    
    // This dismisses the keyboard when the user clicks the DONE button on the keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    
    

    
    
    func cropImage(_ storedImage: UIImage) -> UIImage {
        var origX: CGFloat
        var origY: CGFloat
        
        // sets up the "squareSideLength" of the little square that we will use to punch a hole out of the big square:
        let squareSideLength = storedImage.size.width / scrollView.zoomScale
        print("imageView width: \(imageView.bounds.size.width)")
        print("screen width: \(UIScreen.main.bounds.size.width)")
        print("actual image width: \(storedImage.size.width)")
        
        //the next two lines take away the built in effect of zoomScale on the content offset:
        let unzoomedOffsetX = scrollView.contentOffset.x / scrollView.zoomScale
        let unzoomedOffsetY = scrollView.contentOffset.y / scrollView.zoomScale
        //this stores the width of the actual displayed UIImage on the iPhone screen:
        let displayedImageWidth = UIScreen.main.bounds.size.width
        //this stores the size of the actual image that is in memory (and currently being resized to fit on the iPhone screen):
        let underlyingImageWidth = storedImage.size.width
        //this determines the "scale" as far as how many times bigger or smaller the displayed image is to the actual size of the stored image in memory (fuck the height, we don't care about that for this):
        let underlyingToDisplayedRatio = (underlyingImageWidth / displayedImageWidth)
        //the next two lines store the x and y coordinates that the system will use to go to the underlying stored image and use as the upper left corner of the square that it crops from it:
        origX = unzoomedOffsetX * underlyingToDisplayedRatio
        origY = unzoomedOffsetY * underlyingToDisplayedRatio

        // zoomScale tells us how far we are zoomed in at a given moment
        print("zoomscale: \(scrollView.zoomScale)")
        print("content offset x, y: \(scrollView.contentOffset.x), \(scrollView.contentOffset.y)")
        print("origin: \(origX), \(origY)")
        
        //let imageOrigin = scrollView.bounds.origin
        let crop = CGRect(x: origX,y: origY, width: squareSideLength, height: squareSideLength)
        if let cgImage = storedImage.cgImage?.cropping(to: crop) {
            let image:UIImage = UIImage(cgImage: cgImage) //convert it from a CGImage to a UIImage
            return image
        } else {
            print("cropping failed - image was nil")
            //let alertController = UIAlertController(title: "Cropping Failed", message: nil, preferredStyle: .Alert)
            //presentViewController(alertController, animated: true, completion: nil)
            return currentImage
        }
    }
    
        // MARK: - UIImagePickerControllerDelegate Methods
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                imageView.contentMode = .scaleAspectFit
                imageView.image = pickedImage
                currentImage = pickedImage
            }
            
            dismiss(animated: true, completion: nil)
        }
        
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
        titleHasBeenTapped = self.resetTextField(titleTextField, tappedYet: titleHasBeenTapped)
    }
 

    @IBAction func titleTextFieldValueChanged(_ sender: AnyObject) {
        //self.captionTextField.center.y = tappedLoc.y
    }
    //this sets the text field that we pass in to no text and black text, as long as we have a variable to track whether it has been tapped already:
    func resetTextField(_ textField: UITextField, tappedYet: Bool) -> Bool {
        if tappedYet == false {
            textField.text = ""
            textField.textColor = UIColor.black
        }
        return true
    }
    
    func createAsk (){
        // create a new Ask using the photo, title, and timestamp
        
        let newAsk = Ask(title: currentTitle, photo: currentImage, timePosted: Date())
        // MARK: caption - will also need to initialize a caption string (using the photo editor)
        
        print("New Ask Created! title: \(newAsk.askTitle), timePosted: \(newAsk.timePosted)")
        
        // Once the Ask is created it is appended to the main array:
        mainArray.append(newAsk)
        
        let testAsk = mainArray.last as! Ask
        print("Test Ask Created! title: \(testAsk.askTitle), timePosted: \(testAsk.timePosted)")
     
        // The main array will be sorted by time stamp by the AskTableViewController prior to being displayed in the table view.
    }
    
    @IBAction func publishButtonTapped(_ sender: AnyObject) {
        print("publish button tapped")
        // check to see if the text box is empty

        do {
            if let title = titleTextField.text {
                if title == "" || titleHasBeenTapped == false {
                    throw CameraError.noName
                } else {
                    currentTitle = title
                    createAsk()
                    self.navigationController?.popViewController(animated: true) //rtn to main page
                }
            
            }
        } catch CameraError.noName {
            let alertController = UIAlertController(title: "Title Not Provided", message: "Publish your photo without a title?", preferredStyle: .alert)
            let actionYes = UIAlertAction(title: "Proceed With No Title", style: .default) {
                UIAlertAction in
                print("Proceed with no title clicked")
                currentTitle = "(no title)"
                self.createAsk()
                self.navigationController?.popViewController(animated: true)
                }
            alertController.addAction(actionYes)
            let actionNo = UIAlertAction(title: "Whoops Let Me Enter One", style: .default, handler: nil) //no handler closure req'd bc we just go right back to the original view
            alertController.addAction(actionNo)
            
            present(alertController, animated: true, completion: nil)
        } catch let error {
            fatalError("\(error)")
        }
        
        //testing the crop function
        print("cropping image")
        let croppedImage = self.cropImage(currentImage)
        currentImage = croppedImage
        
        
        
    }
    
    
    
}
    
    
    
    
    


