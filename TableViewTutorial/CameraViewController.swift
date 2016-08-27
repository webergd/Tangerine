//
//  CameraViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 8/3/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    let imagePicker = UIImagePickerController()
    var titleHasBeenTapped: Bool = false
    
    // I'm trying to make this a reference corner for the image to be cropped

    
    enum Error: ErrorType {
        case NoName
    }
    
    // MARK: Camera Needed    - > need to create and implement a camera option
    
    
    
    
    
    //This happens when the user clicks on the use camera roll bar button
    //Realistically I'd rather not ever use this except for testing since this
    //should be an app where users are in the moment and using pics they are taking
    //themselves. Like snapchap does.
    @IBAction func useCameraRoll(sender: AnyObject) {

            imagePicker.allowsEditing = false
            imagePicker.sourceType = .PhotoLibrary
            
            presentViewController(imagePicker, animated: true, completion: nil)
        }
    
        // MARK: DELETE THIS this is just so that the sample image will keep loading for testing:
    override func viewDidAppear(animated: Bool) {
        //currentImage = UIImage(named: "NumberedColorGrid")!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = currentImage
        titleHasBeenTapped = false
        imagePicker.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
            
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    
    
    /*func otherCrop(screenshot: UIImage) -> UIImage {
    
        var scale = 1 / scrollView.zoomScale
        var visibleRect = CGRectMake(scrollView.contentOffset.x * scale, scrollView.contentOffset.y*scale, scrollView.bounds.size.width*scale, scrollView.bounds.size.height*scale)
    
        var ref:CGImageRef = CGImageCreateWithImageInRect(screenshot.CGImage, visibleRect)!
    
        var croppedImage:UIImage = UIImage(CGImage: ref)
        
        return croppedImage
    
    } */
    
    func cropImage(storedImage: UIImage) -> UIImage {
        var origX: CGFloat // = 0.0
        var origY: CGFloat // = 0.0
        
        // sets up the "squareSideLength" of the little square that we will use to punch a hole out of the big square:
        let squareSideLength = storedImage.size.width / scrollView.zoomScale
        print("imageView width: \(imageView.bounds.size.width)")
        print("screen width: \(UIScreen.mainScreen().bounds.size.width)")
        print("actual image width: \(storedImage.size.width)")
        
        //the next two lines take away the built in effect of zoomScale on the content offset:
        let unzoomedOffsetX = scrollView.contentOffset.x / scrollView.zoomScale
        let unzoomedOffsetY = scrollView.contentOffset.y / scrollView.zoomScale
        //this stores the width of the actual displayed UIImage on the iPhone screen:
        let displayedImageWidth = UIScreen.mainScreen().bounds.size.width
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
        let crop = CGRectMake(origX,origY, squareSideLength, squareSideLength)
        if let cgImage = CGImageCreateWithImageInRect(storedImage.CGImage, crop) {
            let image:UIImage = UIImage(CGImage: cgImage) //convert it from a CGImage to a UIImage
            return image
        } else {
            print("cropping failed - image was nil")
            //let alertController = UIAlertController(title: "Cropping Failed", message: nil, preferredStyle: .Alert)
            //presentViewController(alertController, animated: true, completion: nil)
            return currentImage
        }
    }
    
        // MARK: - UIImagePickerControllerDelegate Methods
        
        func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                imageView.contentMode = .ScaleAspectFit
                imageView.image = pickedImage
                currentImage = pickedImage
            }
            
            dismissViewControllerAnimated(true, completion: nil)
        }
        
        func imagePickerControllerDidCancel(picker: UIImagePickerController) {
            dismissViewControllerAnimated(true, completion: nil)
        }
    
    
    //Not using this right now
    @IBAction func userTappedDownTextField(sender: AnyObject) {
    }

    
    @IBAction func titleTextFieldBeginEditing(sender: AnyObject) {
        if titleHasBeenTapped == false {
            titleTextField.text = ""
            titleTextField.textColor = UIColor.blackColor()
            titleHasBeenTapped = true
        }
    }
    
    func createAsk (){
        // create a new Ask using the photo, title, and timestamp
        
        let newAsk = Ask(title: currentTitle, photo: currentImage, timePosted: NSDate())
        // MARK: caption - will also need to initialize a caption string (using the photo editor)
        
        print("New Ask Created! title: \(newAsk.askTitle), timePosted: \(newAsk.timePosted)")
        
        // Once the Ask is created it is appended to the main array:
        mainArray.append(newAsk)
        
        let testAsk = mainArray.last as! Ask
        print("Test Ask Created! title: \(testAsk.askTitle), timePosted: \(testAsk.timePosted)")
     
        // The main array will be sorted by time stamp by the AskTableViewController prior to being displayed in the table view.
    }
    
    
    
    
    @IBAction func publishButtonTapped(sender: AnyObject) {
        print("publish button tapped")

        
        // check to see if the text box is empty

        do {
            if let title = titleTextField.text {
                if title == "" || titleHasBeenTapped == false {
                    throw Error.NoName
                } else {
                    currentTitle = title
                    createAsk()
                    self.navigationController?.popViewControllerAnimated(true) //rtn to main page
                }
            
            }
        } catch Error.NoName {
            let alertController = UIAlertController(title: "Title Not Provided", message: "Publish your photo without a title?", preferredStyle: .Alert)
            let actionYes = UIAlertAction(title: "Proceed With No Title", style: .Default) {
                UIAlertAction in
                print("Proceed with no title clicked")
                currentTitle = "(no title)"
                self.createAsk()
                self.navigationController?.popViewControllerAnimated(true)
                }
            alertController.addAction(actionYes)
            let actionNo = UIAlertAction(title: "Whoops Let Me Enter One", style: .Default, handler: nil) //no handler closure req'd bc we just go right back to the original view
            alertController.addAction(actionNo)
            
            presentViewController(alertController, animated: true, completion: nil)
        } catch let error {
            fatalError("\(error)")
        }
        
        //testing the crop function
        print("cropping image")
        let croppedImage = self.cropImage(currentImage)
        currentImage = croppedImage

        
        
        
    }
    
    
    
}
    
    
    
    
    


