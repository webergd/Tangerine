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
        
        
    }
    
    
    
}
    
    
    
    
    


