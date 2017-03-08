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

public var justFinishedPicking: Bool = false //when it's false, the camera will load upon loading the view. When true, it will show the imageView instead.

@available(iOS 10.0, *) // so I guess this means users are out of luck if they don't update their phones
class AVCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
    
    //var stillImageOutput: AVCaptureStillImageOutput?
    
    
    //belongs to the pre-iOS10 av camera (but I think also to the new one)
    var captureSession: AVCaptureSession! //these 3 might need to be question marks instead of  exclamation points
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
 
    
    let imagePicker = UIImagePickerController()
    //public var justFinishedPicking: Bool = false
    var capturedImage: UIImage = #imageLiteral(resourceName: "tangerineImage2")
    var photoSampleBufferContainer: CMSampleBuffer?
    //let settings = AVCapturePhotoSettings() // controls the camera device's settings, referenced in takePhoto()
    var cameraPosition: cameraPositionType = .standard // sets the default camera position to standard (vice selfie)
    //var device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) //set default device to standard camera
    //var previewLayerAlreadyLoadedOnce: Bool = false

    //var device = AVCaptureDevice.

    // var previewPhotoSampleBuffer: CMSampleBuffer?  //an option that we can enable if we start using thumbnails from the camera

    enum flashState: String {
        case flashOn
        case flashAuto
        case flashOff
    }
    // sets the flash enum to off as the first default
    var avCameraFlash: flashState = .flashOff
    var lastFlashSettingForBackCamera: flashState = .flashOff // remembers what the setting was before user switches to selfie camera
    
    enum cameraPositionType: String {
        case standard
        case selfie
    }

    
    
    @IBOutlet weak var avCameraView: UIView! //this is where the preview layer should show up
    @IBOutlet weak var avImageView: UIImageView! //we use this to display the image after it has been taken
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var photoLibraryButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var cameraFlipButton: UIButton!
    @IBOutlet weak var cancelPhotoButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var blackView: UIView!
    
    
    //@IBOutlet weak var flashButton: UIButton!
    
    //@IBOutlet var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        print("avCameraViewController viewDidLoad executed")

        
        
        //blackView.isHidden = true
        //print("viewDidLoad, blackView is hidden")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* // This is another suggested option for setting the frame for the preview layer. Probably unnecessary at this point.
     override func viewDidLayoutSubviews() {
     super.viewDidLayoutSubviews()
     previewLayer.frame = cameraView.bounds
     }
    */
    
    /*
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // May need to recreate the preview layer if the new swift 3 av camera doesn't do it automatically:
        previewLayer?.frame = UIScreen.main.bounds // for some reason using avCameraView.bounds created a L and R buffer
    }
     */
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("at the beginning of viewWillAppear, avImageView.image is: \(avImageView.image)")
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        previewLayer?.isHidden = true
        blackView.isHidden = false
        //avImageView.isHidden = false
        
        // this happens if we are returning to the camera to take a second photo for the compare
        // we want the camera to display
        if whatToCreate == .compare2 {
            clearCapturedImagePreview()
        }
        
        // when we show the view again after opening the image library, we just want to show the picture selected, not the camera
        if justFinishedPicking == true { // not sure if this should go here or in reload camera
            print("inside view will appear,  returning without reloading camera")
            justFinishedPicking = false
            return
        }
        
        showCameraIcons()
        
        print("reloading camera from inside viewWillAppear")
        reloadCamera()
        


        
        /* // Belongs to then old pre-iOS10 av camera
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPreset1280x720
        
        var backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
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
        */
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    // This is literally only in here to unhide the nav bar after this view goes away, it's debatible whether I need it or not.
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        
    }
    
    func reloadCamera() {
        print("reloadCamera() Called ****************")
        print("at the beginning of reloadCamera, avImageView.image is: \(avImageView.image)")
        captureSession = AVCaptureSession()
        // we may want to change the AVCaptureSessionPreset____ to a different resolution to save space.
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto//AVCaptureSessionPresetPhoto
        cameraOutput = AVCapturePhotoOutput()
        
        // default to back camera
        var device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        print("camera loaded in standard mode (back camera)")
        // unless we have switched our enum to selfie, then use that
        if cameraPosition == .selfie {
            print("camera loaded in selfie mode")
            device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
        }
        
        if let input = try? AVCaptureDeviceInput(device: device) {
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                if (captureSession.canAddOutput(cameraOutput)) {
                    captureSession.addOutput(cameraOutput)
                    
                    /*
                    if let connection = previewLayer?.connection  {
                        if connection.isVideoOrientationSupported {
                                connection.videoOrientation = AVCaptureVideoOrientation.portrait
                                print("portrait mode set for AVCamera")
                            }
                    }
                    */
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    
                    // This causes the preview layer to take up the whole screen:
                    let previewLayerBounds: CGRect = self.view.layer.bounds
                    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                    previewLayer?.bounds = previewLayerBounds
                    previewLayer?.position = CGPoint(x: previewLayerBounds.midX, y: previewLayerBounds.midY)
                    
                    //previewLayer.frame = avCameraView.bounds // if the line below this works, take this line out and see what happens
                    //previewLayer.frame = UIScreen.main.bounds // for some reason using avCameraView.bounds created a L and R buffer
                    
                    // This inserts the previewLayer underneath the buttons
                    //if previewLayerAlreadyLoadedOnce == false {
                    
                    avCameraView.layer.insertSublayer(previewLayer!, below: self.blackView.layer)
                    blackView.isHidden = true
                    
                    //avCameraView.layer.insertSublayer(previewLayer!, below: self.takePhotoButton.layer)
                    
                    //previewLayerAlreadyLoadedOnce = true
                    //}
                    captureSession.startRunning()
                }
            } else {
                print("Issue encountered inside captureSession.canAddInput")
            }
            
        } else {
            print("Issue encountered when reloading camera.")
        }
        
        print("at the beginning of reloadCamera, avImageView.image is: \(avImageView.image)")
    }

    
    @IBAction func takePhoto(_ sender: Any) {
        print("snap")
        // Snaps a picture
        
        // New AVCapturePhotoOutput code goes here:
        //reloadCamera()
        
        
        let settings = AVCapturePhotoSettings()
        
        switch avCameraFlash {
        case .flashAuto: settings.flashMode = .auto
        case .flashOff: settings.flashMode = .off
        case .flashOn: settings.flashMode = .on
        }
        
        
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160, //no clue what these numbers mean
                             kCVPixelBufferHeightKey as String: 160,
                             ]
        settings.previewPhotoFormat = previewFormat
        self.cameraOutput.capturePhoto(with: settings, delegate: self)
        
        //capturedImage = whatever the fuck goes here
        
        
        
        
        /* // Old stillImage stuff
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (sampleBuffer, error) -> Void in

                // Process the image data (sampleBuffer) here to get an image file we can put in our captureImageView
                if sampleBuffer != nil {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    let dataProvider = CGDataProviderCreateWithCFData(imageData)
                    let cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    let image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    // Add the image to captureImageView here...
                    
                }
            })
        }
        */
        

        
        /*
        
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
        
        
        */
        
        hideCameraIcons()
        

        
    }
    
    //Maybe a better simpler version of the capture method?:
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        print("inside capture")
        if let error = error {
            print(error.localizedDescription)
        }
        
        print("captured image before: \(capturedImage)")
        
        
        
        
        if let sampleBuffer = photoSampleBuffer,
           let previewBuffer = previewPhotoSampleBuffer,
           let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            print("re-storing capturedImage")
            
            
            
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
            
            
            self.capturedImage = sFunc_imageFixOrientation(img: image)
            
            
            
            
            
            
            //capturedImage = UIImage(data: dataImage)!
            
            //self.photoSampleBufferContainer = photoSampleBuffer
            
        }
        
        print("captured image after: \(capturedImage)")
        
        avImageView.image = capturedImage
        
        print("image stored to avImageView.image: \(avImageView.image)")
        
        previewLayer.isHidden = true // for some reason these 2 statements don't execute until the end of this method
        avImageView.isHidden = false

        
        // I don't even know if I need this:
    //    self.photoSampleBufferContainer = photoSampleBuffer
        // self.previewPhotoSampleBuffer = previewPhotoSampleBuffer  // enable if using thumbnails from the camera - currently unnecessary
        
        
        
    }
    
    
    // gets rid of all the unnecessary buttons 
    // designed to be called after a photo is picked or taken
    func hideCameraIcons() {
        
        // These 2 lines prevent the image from being distorted when displayed 
        //  (since the aspect ratio of the screen is not the same aspect ratio as the camera)
        avImageView.autoresizingMask = UIViewAutoresizing.flexibleBottomMargin
        avImageView.contentMode = UIViewContentMode.scaleAspectFit
        
        //hide the camera control buttons
        photoLibraryButton.isHidden = true
        takePhotoButton.isHidden = true
        flashButton.isHidden = true
        menuButton.isHidden = true
        cameraFlipButton.isHidden = true
        
        //show the next set of processing buttons
        cancelPhotoButton.isHidden = false
        continueButton.isHidden = false
        blackView.isHidden = false
    }
    
    // not implemented yet
    func showCameraIcons() {
        //hide the camera control buttons
        photoLibraryButton.isHidden = false
        takePhotoButton.isHidden = false
        menuButton.isHidden = false
        cameraFlipButton.isHidden = false
        
        // Don't show the flash if we're in selfie mode
        if cameraPosition == .standard {
            flashButton.isHidden = false
        }
        
        //show the next set of processing buttons
        cancelPhotoButton.isHidden = true
        continueButton.isHidden = true
        blackView.isHidden = true
    }
    
    
    @IBAction func selectFromPhotoLibrary(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeImage as String] //supposedly this prevents the user from taking videos
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        print("insideImagePickerController, avImageView.image before storing pickedImage to it is: \(avImageView.image)")
        
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            print("insideImagePickerController, pickedImage is: \(pickedImage)")
            
            
            justFinishedPicking = true
            avImageView.contentMode = .scaleAspectFit
            print("just picked the image")
            self.previewLayer?.isHidden = true
            self.avImageView.isHidden = false
            capturedImage = pickedImage
            self.avImageView.image = pickedImage
            
            print("insideImagePickerController, avImageView.image AFTER storing pickedImage to it is: \(avImageView.image)")
            
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
                            try device.lockForConfiguration() // I'm not sure if I need to lock for configuration any more
                                switch avCameraFlash {
                                case .flashOff:
                                    turnFlashAuto()
                                case .flashAuto:
                                    turnFlashOn()
                                case .flashOn:
                                    turnFlashOff()
                            }
                            device.unlockForConfiguration()

                        } catch {
                            print("Error: Could not change flash mode.")
                        }
                    }
                }
            }
        
    }
    
    func turnFlashAuto() {
        avCameraFlash = .flashAuto
        //settings.flashMode = .auto
        //device.flashMode = .auto //deprecated
        flashButton.setImage(#imageLiteral(resourceName: "auto-flash_white"), for: UIControlState.normal)
        print("flash mode set to auto")
    }
    func turnFlashOn() {
        avCameraFlash = .flashOn
        //settings.flashMode = .on
        //device.flashMode = .on //deprecated
        flashButton.setImage(#imageLiteral(resourceName: "flash_white"), for: UIControlState.normal)
        print("flash mode set to on")
    }
    func turnFlashOff() {
        avCameraFlash = .flashOff
        //settings.flashMode = .off
        //device.flashMode = .off //deprecated
        flashButton.setImage(#imageLiteral(resourceName: "no-flash_white"), for: UIControlState.normal)
        print("flash mode set to off")
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
 
    @IBAction func menuButtonTapped(_ sender: Any) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        
    }
    @IBAction func cameraFlipButtonTapped(_ sender: Any) {
        // just switches the value to the opposite of what it was
        
        switch cameraPosition {
        case .standard: // if it's standard SWITCH TO SELFIE (.front)
            cameraPosition = .selfie
            lastFlashSettingForBackCamera = avCameraFlash //stores the user's last setting for the flash
            turnFlashOff() //disables the flash since the selfie cam doesn't have one
            flashButton.isHidden = true
            cameraFlipButton.setImage(UIImage(named: "CameraFlip3_white"), for: .normal)
            
            //device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
            print("camera instructed to switch to selfie mode")
        case .selfie: // if it's selfie SWITCH TO STANDARD (.back)
            cameraPosition = .standard
            cameraFlipButton.setImage(UIImage(named: "CameraFlip2_white"), for: .normal)
            
            // Checks which setting the flash was before the user switched over to the selfie camera
            //  and returns the flash to that state.
            switch lastFlashSettingForBackCamera {
            case .flashOff:
                turnFlashOff()
            case .flashAuto:
                turnFlashAuto()
            case .flashOn:
                turnFlashOn()
            }
            flashButton.isHidden = false
            
            //device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            print("camera instructed to switch to standard mode")
        }
        
        
        reloadCamera()
        //viewWillAppear(true)
    }
    
    @IBAction func cancelPhotoButtonTapped(_ sender: Any) {
        clearCapturedImagePreview()
        //viewWillAppear(true)
        print("inside cancelPhotoButtonTapped, avImageView.image is: \(avImageView.image)")
    
    }
    
    func clearCapturedImagePreview() {
        previewLayer.isHidden = false
        avImageView.isHidden = true
        showCameraIcons()
        reloadCamera()
    }
    

    @IBAction func continueButtonTapped(_ sender: Any) {
        currentImage = capturedImage
        // sets the default zoomScale of CameraViewController's scrollview to fill the whole square of the UIImageView
        initialZoomScale = currentImage.size.height / currentImage.size.width

        
        
        // Tapping this button also segues to CameraViewController
        
    }
    
 
}















