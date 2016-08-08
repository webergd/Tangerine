//
//  CameraViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 8/3/16.
//  Copyright © 2016 Freedom Electric. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    let imagePicker = UIImagePickerController()
    var titleHasBeenTapped: Bool = false
    
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
        
        override func viewDidLoad() {
            super.viewDidLoad()
            imageView.image = currentImage
            titleHasBeenTapped = false
            
            imagePicker.delegate = self
            print("date: \(NSDate())")
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
    
    @IBAction func userTappedDownTextField(sender: AnyObject) {
        print("tapped down")


    }

    
    @IBAction func titleTextFieldBeginEditing(sender: AnyObject) {
        if titleHasBeenTapped == false {
            titleTextField.text = ""
            titleTextField.textColor = UIColor.blackColor()
            titleHasBeenTapped = true
        }
    }
    
    
    
    
    
    @IBAction func publishButtonTapped(sender: AnyObject) {
        print("publish button tapped")

        
        // check to see if the text box is empty

        do {
            if let title = titleTextField.text {
                if title == "" || titleHasBeenTapped == false {
                    throw Error.NoName
                } else {
                
                    // should I create the ask object here? It might be nice to send all the info to another swift file that does that shit for me. Maybe create the methods in a different file and reference them here. Is that what my DataModels file is? Perhaps...
                    currentTitle = title
                    self.navigationController?.popViewControllerAnimated(true)
                }
            
            }
        } catch Error.NoName {
            let alertController = UIAlertController(title: "Title Not Provided", message: "Publish your photo without a title?", preferredStyle: .Alert)
            let actionYes = UIAlertAction(title: "Proceed With No Title", style: .Default) {
                UIAlertAction in
                print("Proceed with no title clicked")
                
                self.navigationController?.popViewControllerAnimated(true)
                
            }
            alertController.addAction(actionYes)
            let actionNo = UIAlertAction(title: "Whoops Let Me Enter One", style: .Default, handler: nil)
            alertController.addAction(actionNo)
            
            // I need a function for each alert action or at least for the NO action
            
            presentViewController(alertController, animated: true, completion: nil)
        } catch let error {
            fatalError("\(error)")
        }
        
        
        
    }
    
    
    
}
    
    
    
    
    


