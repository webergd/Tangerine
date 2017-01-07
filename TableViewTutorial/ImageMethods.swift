//
//  ImageMethods.swift
//  TableViewTutorial
//
//  Created by Wyatt Weber on 1/6/17.
//  Copyright © 2017 Freedom Electric. All rights reserved.
//

import Foundation
import UIKit
import CoreImage


private var context = { CIContext(options: nil) }()

/*
var context: CIContext!
var currentFilter: CIFilter!



//Takes in an image and returns the same image with the faces blurred out
public func pixellate(image: UIImage) -> UIImage {
    var blurredImage: UIImage
    context = CIContext() //this step is resource intensive. If there is another place I can put this to make it run less times it'd be better
    currentFilter = CIFilter(name: "CIPixellate")
    let beginImage = CIImage(image: image)
    currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
    
    
    //currentFilter.setValue(0.5, forKey: kCIInputIntensityKey)
    
    if let cgimg = context.createCGImage(currentFilter.outputImage!, from: currentFilter.outputImage!.extent) {
        let processedImage = UIImage(cgImage: cgimg)
        blurredImage = processedImage
        print("faces blurred")
    } else {
        blurredImage = image
        print("Image Blurring Failed")
    }

    return blurredImage
}

public func buildMask(for image: CIImage){

    let detectionAccuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
    let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: detectionAccuracy)
    let foundFaces = faceDetector?.features(in: image)
    

//NSArray *faceArray = [detector featuresInImage:image options:nil];

// Create a green circle to cover the rects that are returned.
    
    
    let pixelateFilter = CIFilter(name: "CIPixellate")
    pixelateFilter?.setValue(image, forKey: kCIInputImageKey)
    pixelateFilter?.setValue(max(image.extent.width, image.extent.height) / 60.0, forKey: kCIInputScaleKey)
    

    var maskImage: CIImage? = nil

    for face in foundFaces as! [CIFaceFeature]  {
        let centerX: CGFloat = face.bounds.origin.x + face.bounds.size.width / 2.0
        let centerY: CGFloat = face.bounds.origin.y + face.bounds.size.height / 2.0
        let radius: CGFloat = min(face.bounds.size.width, face.bounds.size.height) / 1.5
        let radialGradient: CIFilter = CIFilter(name: "CIRadialGradient", withInputParameters: [

            "inputRadius0": radius,
            "inputRadius1": (radius + 1.0),
            "inputColor0": CIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),
            "inputColor1": CIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0),
            kCIInputCenterKey: CIVector(x: centerX, y: centerY),
            ])! //needs an if-let to avoid force unwrapping
    
    
        let croppedImage = radialGradient.outputImage?.cropping(to: image.extent)
    
        
        let circleImage = croppedImage
        if (maskImage == nil) {
            maskImage = circleImage
        } else {
            let filter =  CIFilter(name: "CISourceOverCompositing")
            filter?.setValue(circleImage, forKey: kCIInputImageKey)
            filter?.setValue(maskImage, forKey: kCIInputBackgroundImageKey)
        
            maskImage = filter?.outputImage
        }
    }
    let composite = CIFilter(name: "CIBlendWithMask")
    composite?.setValue(pixelateFilter?.outputImage, forKey: kCIInputImageKey) //I added the force unwrap ?'s - not really sure what they do
    composite.setValue(ciImage, forKey: kCIInputBackgroundImageKey)
    composite.setValue(maskImage, forKey: kCIInputMaskImageKey)
    
    let cgImage = context.createCGImage(composite.outputImage, fromRect: composite.outputImage.extent())
    return UIImage(CGImage: cgImage, scale: 1, orientation: orientation)!
}
*/
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////********************************************////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

public class BlurFace {
    private let ciDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil ,options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
    private var ciImage: CIImage!
    private var orientation: UIImageOrientation = .up
    private lazy var features : [AnyObject]! = { self.ciDetector!.features(in: self.ciImage) }()
    //private lazy var context = { CIContext(options: nil) }()
    
    // MARK: Initializers
    
    public init(image: UIImage!) {
        setImage(image: image)
    }
    public func setImage(image: UIImage!) {
        ciImage = CIImage(image: image)
        orientation = image.imageOrientation
        // features = nil
    }
    
    
    public func blurFaces() -> UIImage {
        let pixelateFilter = CIFilter(name: "CIPixellate")
        pixelateFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        pixelateFilter?.setValue(max(ciImage!.extent.width, ciImage.extent.height) / 60.0, forKey: kCIInputScaleKey)
        
        var maskImage: CIImage?
        for feature in featureFaces() {
            let centerX = feature.bounds.origin.x + feature.bounds.size.width / 2.0
            let centerY = feature.bounds.origin.y + feature.bounds.size.height / 2.0
            let radius = min(feature.bounds.size.width, feature.bounds.size.height) / 1.5
            
            let radialGradient = CIFilter(name: "CIRadialGradient")
            radialGradient?.setValue(radius, forKey: "inputRadius0")
            radialGradient?.setValue(radius + 1, forKey: "inputRadius1")
            radialGradient?.setValue(CIColor(red: 0, green: 1, blue: 0, alpha: 1), forKey: "inputColor0")
            radialGradient?.setValue(CIColor(red: 0, green: 0, blue: 0, alpha: 0), forKey: "inputColor1")
            radialGradient?.setValue(CIVector(x: centerX, y: centerY), forKey: kCIInputCenterKey)
            
            let croppedImage = radialGradient?.outputImage?.cropping(to: ciImage.extent)
            
            let circleImage = croppedImage
            if (maskImage == nil) {
                maskImage = circleImage
            } else {
                let filter =  CIFilter(name: "CISourceOverCompositing")
                filter?.setValue(circleImage, forKey: kCIInputImageKey)
                filter?.setValue(maskImage, forKey: kCIInputBackgroundImageKey)
                
                maskImage = filter?.outputImage
            }
        }
        
        let composite = CIFilter(name: "CIBlendWithMask")
        composite?.setValue(pixelateFilter?.outputImage, forKey: kCIInputImageKey) //I added the force unwrap ?'s
        composite?.setValue(ciImage, forKey: kCIInputBackgroundImageKey)
        composite?.setValue(maskImage, forKey: kCIInputMaskImageKey)
        
        let cgImage = context.createCGImage(composite!.outputImage!, from: composite!.outputImage!.extent)
        return UIImage(cgImage: cgImage!, scale: 1, orientation: orientation)
    }


    private func featureFaces() -> [CIFeature] {
        return features as! [CIFeature]
    }
}













