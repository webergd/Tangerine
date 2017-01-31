//
//  AVCameraViewController.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 1/28/17.
//  Copyright © 2017 Freedom Electric. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices // enables us to usekUTTypeImage

// I need to change this to take still photos



class AVCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    let imagePicker = UIImagePickerController()
    var justFinishedPicking: Bool = false
    
    enum flashState: String {
        case flashOn
        case flashAuto
        case flashOff
    }
    // sets the flash enum to off as the first default
    var avCameraFlash: flashState = .flashOff
    
    
    
    @IBOutlet weak var avCameraView: UIView!
    @IBOutlet weak var avImageView: UIImageView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var photoLibraryButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    
    //@IBOutlet var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = UIScreen.main.bounds // for some reason using avCameraView.bounds created a L and R buffer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPreset1280x720
        
        var backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        //var error : NSError?
        //var input = AVCaptureDeviceInput(device: backCamera) throws -> error
        
        //var input = AVCaptureDeviceInput(device: backCamera, error: &error)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print("Error thrown when trying to read from backCamera")
            print(error!.localizedDescription)
        }
        
        
        
        if (error == nil && captureSession?.canAddInput(input) != nil && justFinishedPicking == false){
            
            captureSession?.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            
            if (captureSession?.canAddOutput(stillImageOutput) != nil){
                captureSession?.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait
                
                // The key to getting the layer in below the buttons is somewhere in here:
                avCameraView.layer.insertSublayer(previewLayer!, below: self.takePhotoButton.layer)
                // the question is, what layer are the buttons on so I can pass that layer in the below parameter?
                
                //avCameraView.layer.addSublayer(previewLayer!)
                captureSession?.startRunning()
                
                
            }
            
            
        }
        
        
        
    }
    

    
    @IBAction func takePhoto(_ sender: Any) {
        // Snaps a picture
        if let videoConnection = stillImageOutput!.connection(withMediaType: AVMediaTypeVideo) {
            stillImageOutput?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (sampleBuffer, error) -> Void in
                // ...
                // Process the image data (sampleBuffer) here to get an image file we can put in our captureImageView
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProvider(data: imageData as! CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.defaultIntent)
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                    // ...
                    // Add the image to avImageView here...
                    self.previewLayer?.isHidden = true
                    self.avImageView.isHidden = false
                    self.avImageView.image = image
                }
            })
        }
        
        hideCameraIcons()

        
    }
    
    // gets rid of all the unnecessary buttons 
    // designed to be called after a photo is picked or taken
    func hideCameraIcons() {
        photoLibraryButton.isHidden = true
        takePhotoButton.isHidden = true
        flashButton.isHidden = true
    }
    
    // not implemented yet
    func showCameraIcons() {
        photoLibraryButton.isHidden = false
        takePhotoButton.isHidden = false
        flashButton.isHidden = false
    }
    
    
    @IBAction func selectFromPhotoLibrary(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeImage as String] //supposedly this prevents the user from taking videos
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            justFinishedPicking = true
            avImageView.contentMode = .scaleAspectFit
            print("just picked the image")
            self.previewLayer?.isHidden = true
            self.avImageView.isHidden = false
            self.avImageView.image = pickedImage
            hideCameraIcons()
            
            // I'm not sure if AVFoundation rotates these the same as the original camera but we may have to implement
            // some form of the below instructions:
            //currentImage = self.fixOrientation(img: pickedImage)
            //currentImage = self.sFunc_imageFixOrientation(img: pickedImage)

            
            
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func toggleFlash(_ sender: Any) {

            // so what I'm not sure about is whether it will still turn on the flash even if it's in selfie mode
            for case let (device as AVCaptureDevice) in AVCaptureDevice.devices()  {
                if device.hasFlash && device.isFlashAvailable {
                    // this is saying: if it can turn on a flash, switch it to the next configuration
                    if device.isFlashModeSupported(.on) {
                        do {
                            try device.lockForConfiguration()
                                switch avCameraFlash {
                                case .flashOff:
                                    avCameraFlash = .flashAuto
                                    device.flashMode = .auto
                                    flashButton.setImage(#imageLiteral(resourceName: "auto-flash"), for: UIControlState.normal)
                                    print("flash mode set to off")
                                case .flashAuto:
                                    avCameraFlash = .flashOn
                                    device.flashMode = .on
                                    flashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControlState.normal)
                                    print("flash mode set to auto")
                                case .flashOn:
                                    avCameraFlash = .flashOff
                                    device.flashMode = .off
                                    flashButton.setImage(#imageLiteral(resourceName: "no-flash"), for: UIControlState.normal)
                                    print("flash mode set to auto")
                                    
                            }
                            device.unlockForConfiguration()
                        
                        
                        } catch {
                            print("Error: Could not change flash mode.")
                        }
                    }
                }
            }
            
            
            
            
            
            
            
        
        

        
        
    }
    
    
    
    // This has something to do with adding a circle "button". May or may not use:
    /*
     override func viewDidLoad() {
     super.viewDidLoad()
 
     let button = UIButton(type: .Custom)
     button.frame = CGRect(x: 160, y: 100, width: 50, height: 50)
     button.layer.cornerRadius = 0.5 * button.bounds.size.width
     button.clipsToBounds = true
     button.setImage(UIImage(named:"thumbsUp.png"), forState: .Normal)
     button.addTarget(self, action: #selector(thumbsUpButtonPressed), forControlEvents: .TouchUpInside)
     view.addSubview(button)
     }
 
     func thumbsUpButtonPressed() {
     print("thumbs up button pressed")
     }
     */
 
 
}
