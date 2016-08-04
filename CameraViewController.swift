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
        
    //need to create and implement a camera option
    
    
    
    
    
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
            print("first time in tapped down and bool is false")
            titleTextField.text = ""
            titleTextField.textColor = UIColor.blackColor()
            titleHasBeenTapped = true
        }
    }
    
    
    
    
    
    @IBAction func publishButtonTapped(sender: AnyObject) {
        print("publish button tapped")
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    
    
    }
    
    
    
    
    


