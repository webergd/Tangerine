//
//  CameraViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 7/27/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit
import MobileCoreServices //what does this do?

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    var newMedia: Bool?
    

    @IBAction func useCamera(sender: AnyObject) {
        print("useCamera clicked")
        //first checks that the device has a camera
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            //creates a UIImagePicker Instance
            let imagePicker = UIImagePickerController()
            
            //assigns the camera view controller as the delegate for the object
            imagePicker.delegate = self
            
            //define the media source as the camera
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
            //set the newMedia flag to true to indicate the image is new and is not an existing image from the camera roll
            newMedia = true
        }
    }
    

 
    //almost the same as above except we pick the image from the camera roll vice direct from the camera:
    @IBAction func useCameraRoll(sender: AnyObject) {
        print("useCameraRoll clicked")
        // 1.Source Type is saved photos album
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType =
                UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true,
                                       completion: nil)
            // 2. This is set to false because we are using old media that was already stored
            newMedia = false
        }

        
        // this is called when the user has finished taking or selecting an image
        // The code in this delegate method dismisses the image picker view and identifies the type of media passed from the image picker controller. If it is an image it is displayed on the view image object of the user interface. If this is a new image it is saved to the camera roll.
        func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            
            print("didFinishPickingMediaWithInfo called")
            
            let mediaType = info[UIImagePickerControllerMediaType] as! String
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
            if mediaType == String(kUTTypeImage as String) {
                let image = info[UIImagePickerControllerOriginalImage]
                    as! UIImage
                
                imageView.image = UIImage(named: "redRebooks")
                imageView.image = image
                
                if (newMedia == true) {
                    UIImageWriteToSavedPhotosAlbum(image, self,Selector("image:didFinishSavingWithError:contextInfo:"), nil)
                } else if mediaType == String(kUTTypeMovie as String) {
                    // Code to support video here
                }
                
            }
        }
        // finishedSavingWithError method is configured to be called when the save operation is complete. If an error occurred it is reported to the user via an alert box.
        func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafePointer<Void>) {
            
            if error != nil {
                let alert = UIAlertController(title: "Save Failed",
                                              message: "Failed to save image",
                                              preferredStyle: UIAlertControllerStyle.Alert)
                
                let cancelAction = UIAlertAction(title: "OK",
                                                 style: .Cancel, handler: nil)
                
                alert.addAction(cancelAction)
                self.presentViewController(alert, animated: true,
                                           completion: nil)
            }
        }
        
        //It is also necessary to implement the imagePickerControllerDidCancel delegate method which is called if the user cancels the image picker session without taking a picture or making an image selection. In most cases all this method needs to do is dismiss the image picker:
        func imagePickerControllerDidCancel(picker: UIImagePickerController) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
 
    }
 
    
    
    
    
    
    
}
