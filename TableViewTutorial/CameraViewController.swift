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
        
        print("currentImage orientation is upright \(currentImage.imageOrientation == UIImageOrientation.up)")
        
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
        //print("tappedLoc.y: \(tappedLoc.y)")
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
                    // Save the captionTextField's Location so we can restore it after editing:
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
        }
        
            //this makes the text box movement animated so it looks smoother:
            UIView.animate(withDuration: 1.0, animations: {
                //moves the caption back to its original location:
                self.captionTextFieldTopConstraint.constant = self.captionYValue

            })
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
        
        /*
        var croppedImage:UIImage
        
        // This is the code I got from this website:
        // http://timrichardson.co/2015/03/cropping-an-image-from-uiscrollview-using-swift/
        // It had to be updated for Swift 3.0 and I'm not sure if I converted it all right.
        // There are also some force unwrapped optional values in here that need to be addressed
        // Not to mention that this code does not correctly crop the image
        // Double check that it's not just an issue with what value I am returning or the value I am storing to currentImage
        let scale = 1 / scrollView.zoomScale
        let visibleRect = CGRect(x: scrollView.contentOffset.x * scale, y: scrollView.contentOffset.y * scale, width: scrollView.bounds.size.width * scale, height: scrollView.bounds.size.height * scale)
        
        if let ref:CGImage = storedImage.cgImage!.cropping(to: visibleRect) {
        
            croppedImage = UIImage(cgImage: ref)
            print("image cropped")
        } else {
            croppedImage = currentImage
            print("************************Cropping Failed**************************************")
        }
        
        return croppedImage
        */
        

        // This was the original cropping code. It may be closer to what I need than the above:
        
        var origX: CGFloat
        var origY: CGFloat
        
        var squareSideLength: CGFloat {
            if storedImage.size.width < storedImage.size.height {
                return storedImage.size.width / scrollView.zoomScale
            } else {
                return storedImage.size.height / scrollView.zoomScale
            }
        }
        
        // sets up the "squareSideLength" of the little square that we will use to punch a hole out of the big square:
        //let squareSideLength = storedImage.size.width / scrollView.zoomScale
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
        let crop = CGRect(x: origX,y: origY, width: squareSideLength * 2, height: squareSideLength)
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
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                imageView.contentMode = .scaleAspectFit
                print("just picked the image")
                self.printImageOrientations(passedImage: pickedImage)
                //currentImage = self.fixOrientation(img: pickedImage)
                currentImage = self.sFunc_imageFixOrientation(img: pickedImage)
                imageView.image = currentImage
                
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
        
        print("currentImage orientation before ask is created \(currentImage.imageOrientation.rawValue)")
        // Begin experimentation ************************
        /*
        // Here I am attempting to rotate currentImage before saving it to the Ask:
        // (for testing purposes only - this is the opposite of what I really want to do)
        // A CGAffineTransform is a weird ass thing that I don't understand...
        var transform:CGAffineTransform = CGAffineTransform.identity
        // I think this is saying that we will flip the image upside down:
        transform = transform.rotated(by: CGFloat(M_PI))
        // From what I can gather, the CGContext is some kind of blank canvas in which we will draw our newly rotated image, this line seems to add our old image to it so at the end of the operation, we have an exact copy of the original image, now contained within the CGContext
        let ctx:CGContext = CGContext(data: nil, width: Int(currentImage.size.width), height: Int(currentImage.size.height),
                                      bitsPerComponent: currentImage.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                      space: currentImage.cgImage!.colorSpace!,
                                      bitmapInfo: currentImage.cgImage!.bitmapInfo.rawValue)!
        // Lastly, I believe this concatenation spins the image around the amount specified in the variable 'transform'
        ctx.concatenate(transform)
        // Now it's fitting the image into a rectangle...?
        ctx.draw(currentImage.cgImage!, in: CGRect(x:0,y:0,width:currentImage.size.height,height:currentImage.size.width))
        
        let cgimg:CGImage = ctx.makeImage()!
        let imgEnd:UIImage = UIImage(cgImage: cgimg)
        
        */
        // End experimentation **********************
        print("currentImage orientation before Ask is created:")
        self.printImageOrientations(passedImage: currentImage)
        
        let imageToCreateAskWith: UIImage = self.sFunc_imageFixOrientation(img: currentImage)
        
        currentImage = imageToCreateAskWith
        print("currentImage just updated with unfucked image")
        
        
        // To fix back to normal, replace imageToCreateAskWith with currentImage in the next line:
        let newAsk = Ask(title: currentTitle, photo: imageToCreateAskWith, timePosted: Date())
        
        // So the next step here is to upload the app to the iphone and see if the unfucking method that I pasted at the bottom of this file works as advertized and flips it back to normal before storing it to the ask
        // If it is still messed up even after I have applied the unfucking method, it is probably because the system is rotating the image later on, perhaps right after it creates the Ask. If this is the case, I need to apply the unfucking method to the actual image property of the Ask I just created and see if I can rotate that. Hopefully that's not the issue becuase the unfucking method basically just stores a rotated copy of the image to the Ask anyway so the mechanism that is flipping it will probably just flip it again, counteracting the best efforts of the unfucking method.
        // I don't think the above is the problem since the images are just stored rotated because the camera doesn't rotate. There's something else going on here. Also, if this is the issue, perhaps I can set up the unfucker to rotate the image 180 deg so that when it gets put back 90 deg, it will be in the right orientation.
        
        
        
        print("currentImage orientation:")
        self.printImageOrientations(passedImage: currentImage)
        print("new askPhoto orientation:")
        self.printImageOrientations(passedImage: newAsk.askPhoto)
        
        // MARK: caption - will also need to initialize a caption string (using the photo editor)
        
        print("New Ask Created! title: \(newAsk.askTitle), timePosted: \(newAsk.timePosted)")

        // Once the Ask is created it is appended to the main array:
        mainArray.append(newAsk)
        
        let testAsk = mainArray.last as! Ask
        print("New Ask now appended to mainArray. Last Ask in the Array is title: \(testAsk.askTitle), timePosted: \(testAsk.timePosted)")
     
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
                    currentImage = self.cropImage(currentImage)
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
                currentImage = self.cropImage(currentImage)
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
        /* 
        print("cropping image")
        let croppedImage = self.cropImage(currentImage)
        currentImage = croppedImage
        */
        
        
    }
    
    func sFunc_imageFixOrientation(img:UIImage) -> UIImage {
        
        print("inside the beginning of the rotation unfucker")
        // No-op if the orientation is already correct

        if (img.imageOrientation == UIImageOrientation.up) {
            print("returning original image")
            return img;
        }

        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform:CGAffineTransform = CGAffineTransform.identity
      
        if (img.imageOrientation == UIImageOrientation.down
            || img.imageOrientation == UIImageOrientation.downMirrored) {
            
            transform = transform.translatedBy(x: img.size.width, y: img.size.height)
            transform = transform.rotated(by: CGFloat(M_PI)) //seems to be the number of radians we rotate the image
        }
        
        if (img.imageOrientation == UIImageOrientation.left
            || img.imageOrientation == UIImageOrientation.leftMirrored) {
            print("image is left or left mirrored")
            transform = transform.translatedBy(x: img.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
        }
        
        if (img.imageOrientation == UIImageOrientation.right
            || img.imageOrientation == UIImageOrientation.rightMirrored) {
            print("image is right or right mirrored")
            transform = transform.translatedBy(x: 0, y: img.size.height);
            transform = transform.rotated(by: CGFloat(-M_PI_2));
        }
        
        if (img.imageOrientation == UIImageOrientation.upMirrored
            || img.imageOrientation == UIImageOrientation.downMirrored) {
            print("image is upMirrored or downMirrored")
            transform = transform.translatedBy(x: img.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        }
        
        if (img.imageOrientation == UIImageOrientation.leftMirrored
            || img.imageOrientation == UIImageOrientation.rightMirrored) {
            print("image is leftMirrored or rightMirrored")
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
            print("inside the if statement of the rotation unfucker")
            //I'm not sure why there is even an if statement since they perform the same operation in both cases...
            ctx.draw(img.cgImage!, in: CGRect(x:0,y:0,width:img.size.height,height:img.size.width))
            
        } else {
            print("inside the else statement of the rotation unfucker")
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


    
    
    


