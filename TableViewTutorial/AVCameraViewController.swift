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


@available(iOS 10.0, *) // so I guess this means users are out of luck if they don't update their phones
class AVCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
    
    //var stillImageOutput: AVCaptureStillImageOutput?
    
    
    //belongs to the pre-iOS10 av camera (but I think also to the new one)
    var captureSession: AVCaptureSession! //these 3 might need to be question marks instead of  exclamation points
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
 
    
    let imagePicker = UIImagePickerController()
    var justFinishedPicking: Bool = false
    var capturedImage: UIImage = #imageLiteral(resourceName: "tangerineImage2")
    var photoSampleBuffer: CMSampleBuffer?
    // var previewPhotoSampleBuffer: CMSampleBuffer?  //an option that we can enable if we start using thumbnails from the camera
    
    
    enum flashState: String {
        case flashOn
        case flashAuto
        case flashOff
    }
    // sets the flash enum to off as the first default
    var avCameraFlash: flashState = .flashOff
    
    
    
    @IBOutlet weak var avCameraView: UIView! //this is where the preview layer should show up
    @IBOutlet weak var avImageView: UIImageView! //we use this to display the image after it has been taken
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var photoLibraryButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    
    //@IBOutlet weak var flashButton: UIButton!
    
    //@IBOutlet var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
        
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
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // May need to recreate the preview layer if the new swift 3 av camera doesn't do it automatically:
        previewLayer?.frame = UIScreen.main.bounds // for some reason using avCameraView.bounds created a L and R buffer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

        if justFinishedPicking == true {
            return
        }
        
        
        captureSession = AVCaptureSession()
        // we may want to change the AVCaptureSessionPreset____ to a different resolution to save space.
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto//AVCaptureSessionPresetPhoto
        cameraOutput = AVCapturePhotoOutput()
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        if let input = try? AVCaptureDeviceInput(device: device) {
            if (captureSession.canAddInput(input)) {
                captureSession.addInput(input)
                if (captureSession.canAddOutput(cameraOutput)) {
                    captureSession.addOutput(cameraOutput)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    
                    // This causes the preview layer to take up the whole screen:
                    let previewLayerBounds: CGRect = self.view.layer.bounds
                    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                    previewLayer?.bounds = previewLayerBounds
                    previewLayer?.position = CGPoint(x: previewLayerBounds.midX, y: previewLayerBounds.midY)
                    
                    
                    //previewLayer.frame = avCameraView.bounds // if the line below this works, take this line out and see what happens
                    
                    //previewLayer.frame = UIScreen.main.bounds // for some reason using avCameraView.bounds created a L and R buffer
                    avCameraView.layer.insertSublayer(previewLayer!, below: self.takePhotoButton.layer)
                    captureSession.startRunning()
                }
            } else {
                print("issue here : captureSession.canAddInput")
            }
        } else {
            print("some problem here")
        }

        
        
        
        
        
        
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

    
    @IBAction func takePhoto(_ sender: Any) {
        // Snaps a picture
        
        // New AVCapturePhotoOutput code goes here **************
        
        
        let settings = AVCapturePhotoSettings()
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
        previewLayer.isHidden = true
        avImageView.isHidden = false

        
    }
    
    //Maybe a better simpler version of the capture method?:
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            capturedImage = UIImage(data: dataImage)!
            
        }
        
        avImageView.image = capturedImage
        
        // I don't even know if I need this:
        self.photoSampleBuffer = photoSampleBuffer
        // self.previewPhotoSampleBuffer = previewPhotoSampleBuffer  // enable if using thumbnails from the camera - currently unnecessary
        
        
        
    }
    
    
    // This capture function has to be here or an error will be thrown when I try to take the picture.
    // I still haven't figured out why.
    
    /*
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print("error occure : \(error.localizedDescription)")
        }
        
        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            print(UIImage(data: dataImage)?.size as Any)
            
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
            
            self.capturedImage = image
        } else {
            print("some error here")
        }
    }
    */
    
    // gets rid of all the unnecessary buttons 
    // designed to be called after a photo is picked or taken
    func hideCameraIcons() {
        photoLibraryButton.isHidden = true
        takePhotoButton.isHidden = true
        flashButton.isHidden = true
        menuButton.isHidden = true
    }
    
    // not implemented yet
    func showCameraIcons() {
        photoLibraryButton.isHidden = false
        takePhotoButton.isHidden = false
        flashButton.isHidden = false
        menuButton.isHidden = false
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
 
    @IBAction func menuButtonTapped(_ sender: Any) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        
    }
 
}
