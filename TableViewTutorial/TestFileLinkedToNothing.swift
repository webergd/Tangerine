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
