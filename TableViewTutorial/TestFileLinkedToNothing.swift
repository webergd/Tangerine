//This is only for pasting shit in so that I can see what it looks like in the editor rather than seeing it in the tiny ass little window on stack overflow.

import UIKit

func sFunc_imageFixOrientation(img:UIImage) -> UIImage {
    
    
    // No-op if the orientation is already correct
    if (img.imageOrientation == UIImageOrientation.up) {
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
        
        transform = transform.translatedBy(x: img.size.width, y: 0)
        transform = transform.rotated(by: CGFloat(M_PI_2))
    }
    
    if (img.imageOrientation == UIImageOrientation.right
        || img.imageOrientation == UIImageOrientation.rightMirrored) {
        
        transform = transform.translatedBy(x: 0, y: img.size.height);
        transform = transform.rotated(by: CGFloat(-M_PI_2));
    }
    
    if (img.imageOrientation == UIImageOrientation.upMirrored
        || img.imageOrientation == UIImageOrientation.downMirrored) {
        
        transform = transform.translatedBy(x: img.size.width, y: 0)
        transform = transform.scaledBy(x: -1, y: 1)
    }
    
    if (img.imageOrientation == UIImageOrientation.leftMirrored
        || img.imageOrientation == UIImageOrientation.rightMirrored) {
        
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
        
        //I'm not sure why there is even an if statemet since they perform the same operation in both cases...
        ctx.draw(img.cgImage!, in: CGRect(x:0,y:0,width:img.size.height,height:img.size.width))
        
    } else {
        ctx.draw(img.cgImage!, in: CGRect(x:0,y:0,width:img.size.width,height:img.size.height))
    }
    
    
    // And now we just create a new UIImage from the drawing context
    let cgimg:CGImage = ctx.makeImage()!
    let imgEnd:UIImage = UIImage(cgImage: cgimg)
    
    return imgEnd
    
    
    
}

//********************************************************
/*
Saving a Processed Photo to the Photo Library

Once the capture is complete, the photo output delegate should receive a call to captureOutput:didFinishProcessingPhotoSampleBuffer:previewPhotoSampleBuffer:resolvedSettings:bracketSettings:error: which delivers a CMSampleBuffer containing the compressed image data in photoSampleBuffer, and possibly also a previewPhotoSampleBuffer. At this stage the photo capture sequence hasn’t fully completed, so it’s best to hang on to the sample buffer(s) and wait for captureOutput:didFinishCaptureForResolvedSettings:error: before doing any further processing. Once captureOutput:didFinishCaptureForResolvedSettings:error: has been called, and assuming that no error is reported, the data in the sample buffer(s) can be processed.

This is shown in Listing 1-17. The captured sample buffer is saved to the Photo Library using the saveSampleBufferToPhotoLibrary(…) function from Listing 1-18.

Listing 1-17  AVCapturePhotoCaptureDelegate implementation for a processed photo */
/*

var photoSampleBuffer: CMSampleBuffer?
var previewPhotoSampleBuffer: CMSampleBuffer?

func capture(_ captureOutput: AVCapturePhotoOutput,
             didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?,
             previewPhotoSampleBuffer: CMSampleBuffer?,
             resolvedSettings: AVCaptureResolvedPhotoSettings,
             bracketSettings: AVCaptureBracketedStillImageSettings?,
             error: Error?) {
    guard error == nil, let photoSampleBuffer = photoSampleBuffer else {
        print("Error capturing photo: \(error)")
        return
}
*/
/*

Capturing an Uncompressed Photo

If you wish to process the captured image data in some way—perhaps to apply a filter or to use image recognition algorithms—then you can request uncompressed capture to give you a pixel buffer in a number of uncompressed formats. This should not be confused with RAW capture: the uncompressed pixel data you receive has still undergone substantial processing after having been captured from the sensor—it’s just not compressed.

To capture an uncompressed photo:

1) Create an AVCapturePhotoSettings object and
    specify a kCVPixelBufferPixelFormatTypeKey
        in the format dictionary with a value of
            one of the availableRawPhotoPixelFormatTypes,
 for example, kCVPixelFormatType_32BGRA.

2) Check that the pixel format type is in the capture output’s availablePhotoPixelFormatTypes.

3) Call capturePhotoWithSettings:delegate: to initiate the photo capture.

Listing 1-19 
Capturing into a pixel buffer:
*/
/* no bottom to this one
 
 
 
let pixelFormatType = NSNumber(value: kCVPixelFormatType_32BGRA)

// seems like step 2
guard capturePhotoOutput.availablePhotoPixelFormatTypes.contains(pixelFormatType) else { return }

// seems like step 1
let photoSettings = AVCapturePhotoSettings(format: [
    kCVPixelBufferPixelFormatTypeKey as String : pixelFormatType
    ])

capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
/*Your photo output delegate should receive a call to captureOutput:didFinishProcessingPhotoSampleBuffer:previewPhotoSampleBuffer:resolvedSettings:bracketSettings:error: which delivers a CMSampleBuffer in its photoSampleBuffer parameter, containing the uncompressed pixel data in a CVPixelBuffer. Listing 1-20 shows the uncompressed pixel data being passed to a function that applies a Core Image filter, before saving the filtered image to the Photo Library.*/

/* Listing 1-20
 
 AVCapturePhotoCaptureDelegate implementation for an uncompressed photo
 */
var photoSampleBuffer: CMSampleBuffer?
var previewPhotoSampleBuffer: CMSampleBuffer?

func capture(_ captureOutput: AVCapturePhotoOutput,
             didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?,
             previewPhotoSampleBuffer: CMSampleBuffer?,
             resolvedSettings: AVCaptureResolvedPhotoSettings,
             bracketSettings: AVCaptureBracketedStillImageSettings?,
             error: Error?) {
    guard error == nil, let photoSampleBuffer = photoSampleBuffer else {
        print("Error capturing photo: \(error)")
        return
    }
    
    self.photoSampleBuffer = photoSampleBuffer
    self.previewPhotoSampleBuffer = previewPhotoSampleBuffer
}

func capture(_ captureOutput: AVCapturePhotoOutput,
               didFinishCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings,
               error: Error?)
    guard error == nil else {
        print("Error in capture process: \(error)")
        return
    }

    if let photoSampleBuffer = self.photoSampleBuffer {
        applyFilterAndSaveToPhotoLibrary(photoSampleBuffer,
                                         videoOrientation: previewView.videoPreviewLayer.connection.videoOrientation,
                                         completionHandler: { success, error in
                                            if success {
                                                print("Added filtered JPEG photo to library.")
                                            } else {
                                                print("Error adding filtered JPEG photo to library: \(error)")
                                            }
        })
    }
}
Once you have a CVPixelBuffer it’s trivial to create a CIImage from it: all the power of the Core Image framework is then at your disposal. As an example, Listing 1-21 shows how to create a CIImage, apply a Core Image filter to it, convert the result to a CGImage, and finally obtain a JPEG representation so the filtered image can be saved to the Photo Library.

/* Listing 1-21
 
 Applying a Core Image filter before saving to the Photo Library     
 */
func applyFilterAndSaveToPhotoLibrary(_ sampleBuffer: CMSampleBuffer,
                                      videoOrientation: AVCaptureVideoOrientation,
                                      completionHandler: ((_ success: Bool, _ error: Error?) -> Void)?) {
    self.checkPhotoLibraryAuthorization({ authorized in
        guard authorized else {
            print("Permission to access photo library denied.")
            completionHandler?(false, nil)
            return
        }
        guard let cvPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("sampleBuffer does not contain a CVPixelBuffer.")
            completionHandler?(false, nil)
            return
        }
        
        // Create a Core Image image from the pixel buffer and apply a filter.
        let orientationMap: [AVCaptureVideoOrientation : CGImagePropertyOrientation] = [
            .portrait           : .right,
            .portraitUpsideDown : .left,
            .landscapeLeft      : .down,
            .landscapeRight     : .up,
            ]
        let imageOrientation = Int32(orientationMap[videoOrientation]!.rawValue)
        let ciImage = CIImage(cvPixelBuffer: cvPixelBuffer).applyingOrientation(imageOrientation)
        let filteredCIImage = ciImage.applyingFilter("CIPhotoEffectNoir", withInputParameters: nil)
        
        // Get a JPEG data representation of the filter output.
        let colorSpaceMap: [AVCaptureColorSpace: CFString] = [
            .sRGB   : CGColorSpace.sRGB,
            .P3_D65 : CGColorSpace.displayP3,
            ]
        let colorSpace = CGColorSpace(name: colorSpaceMap[self.videoCaptureDevice.activeColorSpace]!)!
        guard let jpegData = CIContext().jpegRepresentation(of: filteredCIImage, colorSpace: colorSpace) else {
            print("Unable to create filtered JPEG.")
            completionHandler?(false, nil)
            return
        }
        
        // Write it to the Photos library.
        PHPhotoLibrary.shared().performChanges( {
            let creationRequest = PHAssetCreationRequest.forAsset()
            creationRequest.addResource(with: PHAssetResourceType.photo, data: jpegData, options: nil)
        }, completionHandler: { success, error in
            DispatchQueue.main.async {
                completionHandler?(success, error)
            }
        })
    })
}







*/

































/*





import UIKit
import AVFoundation
import MobileCoreServices // enables us to usekUTTypeImage


@available(iOS 10.0, *)
class AVCameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {

    var captureSession: AVCaptureSession!
    var cameraOutput: AVCapturePhotoOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    let imagePicker = UIImagePickerController()
    var justFinishedPicking: Bool = false
    var capturedImage: UIImage = #imageLiteral(resourceName: "tangerineImage2")
    var photoSampleBufferContainer: CMSampleBuffer?

    var cameraPosition: cameraPositionType = .standard // sets the default camera position to standard (vice selfie)

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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if justFinishedPicking == true { // not sure if this should go here or in reload camera
            return
        }
        
        reloadCamera()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func reloadCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto//AVCaptureSessionPresetPhoto
        cameraOutput = AVCapturePhotoOutput()
        
        // default to back camera
        var device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        print("camera loaded in standard mode (back camera")
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
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    
                    // This causes the preview layer to take up the whole screen:
                    let previewLayerBounds: CGRect = self.view.layer.bounds
                    previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                    previewLayer?.bounds = previewLayerBounds
                    previewLayer?.position = CGPoint(x: previewLayerBounds.midX, y: previewLayerBounds.midY)

                    avCameraView.layer.insertSublayer(previewLayer!, below: self.takePhotoButton.layer)
                    captureSession.startRunning()
                }
            } else {
                print("Issue encountered inside captureSession.canAddInput")
            }
            
        } else {
            print("Issue encountered when reloading camera.")
        }
        
    }
    
    
    @IBAction func takePhoto(_ sender: Any) {
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

        hideCameraIcons()

    }
    

    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }

        if let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            print("re-storing capturedImage")

            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
            
            self.capturedImage = image
            
        }
        
        avImageView.image = capturedImage
        
        previewLayer.isHidden = true // for some reason these 2 statements don't execute until the end of this method
        avImageView.isHidden = false
    }
    
    
    // gets rid of all the unnecessary buttons
    // designed to be called after a photo is picked or taken
    func hideCameraIcons() {
        //hide the camera control buttons
        photoLibraryButton.isHidden = true
        takePhotoButton.isHidden = true
        flashButton.isHidden = true
        menuButton.isHidden = true
        cameraFlipButton.isHidden = true
        
        //show the next set of processing buttons
        cancelPhotoButton.isHidden = false
    }
    
    func showCameraIcons() {
        //hide the camera control buttons
        photoLibraryButton.isHidden = false
        takePhotoButton.isHidden = false
        flashButton.isHidden = false
        menuButton.isHidden = false
        cameraFlipButton.isHidden = false
        
        //show the next set of processing buttons
        cancelPhotoButton.isHidden = true
    }
    
    
    @IBAction func selectFromPhotoLibrary(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeImage as String] //supposedly this prevents the user from taking videos
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            justFinishedPicking = true
            avImageView.contentMode = .scaleAspectFit
            self.previewLayer?.isHidden = true
            self.avImageView.isHidden = false
            self.avImageView.image = pickedImage
            hideCameraIcons()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func toggleFlash(_ sender: Any) {
        for case let (device as AVCaptureDevice) in AVCaptureDevice.devices()  {
            if device.hasFlash && device.isFlashAvailable {
                if device.isFlashModeSupported(.on) {
                    do {
                        try device.lockForConfiguration()
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
        flashButton.setImage(#imageLiteral(resourceName: "auto-flash"), for: UIControlState.normal)
        print("flash mode set to auto")
    }
    func turnFlashOn() {
        avCameraFlash = .flashOn
        flashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControlState.normal)
        print("flash mode set to on")
    }
    func turnFlashOff() {
        avCameraFlash = .flashOff
        flashButton.setImage(#imageLiteral(resourceName: "no-flash"), for: UIControlState.normal)
        print("flash mode set to off")
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        
    }
    @IBAction func cameraFlipButtonTapped(_ sender: Any) {
        switch cameraPosition {
        case .standard: // if it's standard SWITCH TO SELFIE (.front)
            cameraPosition = .selfie
            lastFlashSettingForBackCamera = avCameraFlash //stores the user's last setting for the flash
            turnFlashOff() //disables the flash since the selfie cam doesn't have one
            flashButton.isHidden = true
            //device = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
        case .selfie: // if it's selfie SWITCH TO STANDARD (.back)
            cameraPosition = .standard
            
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
        }
        
        reloadCamera()
    }
    
    @IBAction func cancelPhotoButtonTapped(_ sender: Any) {
        previewLayer.isHidden = false
        avImageView.isHidden = true
        showCameraIcons()
        reloadCamera()

    }
    
}











*/




