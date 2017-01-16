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


public var numFaces: Int = 0


private var context = { CIContext(options: nil) }()


public class BlurFace {
    private let ciDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil ,options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
    private var ciImage: CIImage!
    private var orientation: UIImageOrientation = .up
    private lazy var features : [AnyObject]! = { self.ciDetector!.features(in: self.ciImage) }()

    
    var maskImage: CIImage?
    let pixelateFilter = CIFilter(name: "CIPixellate")
    //private lazy var context = { CIContext(options: nil) }()
    
    // MARK: Initializers
    
    public init(image: UIImage!) {
        setImage(image: image)
    }
    public func setImage(image: UIImage!) {
        ciImage = CIImage(image: image)
        orientation = image.imageOrientation
        pixelateFilter?.setValue(ciImage, forKey: kCIInputImageKey)

        // Started out as 60

        
        pixelateFilter?.setValue(max(ciImage!.extent.width, ciImage.extent.height) / 30.0, forKey: kCIInputScaleKey)
        // features = nil
    }
    
    public func setupBlurMask(centerX: CGFloat, centerY: CGFloat, radius: CGFloat) {
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
    public func addBlurMaskToImage() -> UIImage {
        let composite = CIFilter(name: "CIBlendWithMask")
        composite?.setValue(pixelateFilter?.outputImage, forKey: kCIInputImageKey) //I added the force unwrap ?'s
        composite?.setValue(ciImage, forKey: kCIInputBackgroundImageKey)
        composite?.setValue(maskImage, forKey: kCIInputMaskImageKey)
        
        let cgImage = context.createCGImage(composite!.outputImage!, from: composite!.outputImage!.extent)
        return UIImage(cgImage: cgImage!, scale: 1, orientation: orientation)
    }
    
    
    // This may need to be renamed to autoBlurFaces
    public func blurFaces() -> UIImage {
        
        
        // testing this here to see if refreshing the context every time removes the blurring issues
        context = { CIContext(options: nil) }()
        print("context refreshed")
        
        
        
        //let pixelateFilter = CIFilter(name: "CIPixellate")
        //pixelateFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        //pixelateFilter?.setValue(max(ciImage!.extent.width, ciImage.extent.height) / 60.0, forKey: kCIInputScaleKey)
        
        numFaces = 0
        // This runs a loop to blur each individual face that the system has detected, one at a time
        for feature in featureFaces() {
            numFaces += 1
            print("\(numFaces) faces detected")
            
            let centerX = feature.bounds.origin.x + feature.bounds.size.width / 2.0
            let centerY = feature.bounds.origin.y + feature.bounds.size.height / 2.0
            let radius = min(feature.bounds.size.width, feature.bounds.size.height) / 1.5
            
            print("auto blurring face at x: \(centerX) y: \(centerY)")
            
            setupBlurMask(centerX: centerX, centerY: centerY, radius: radius)
            
            /*
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
            */
        }
        if numFaces < 1 {
            print("numFaces = \(numFaces)")
        }
        
        /*
        let composite = CIFilter(name: "CIBlendWithMask")
        composite?.setValue(pixelateFilter?.outputImage, forKey: kCIInputImageKey) //I added the force unwrap ?'s
        composite?.setValue(ciImage, forKey: kCIInputBackgroundImageKey)
        composite?.setValue(maskImage, forKey: kCIInputMaskImageKey)
        
        let cgImage = context.createCGImage(composite!.outputImage!, from: composite!.outputImage!.extent)
        return UIImage(cgImage: cgImage!, scale: 1, orientation: orientation)
         */
        
        return addBlurMaskToImage()
    }
    
    public func manualBlurFace(at location: CGPoint, with radius: CGFloat) -> UIImage {
        
        // beacuse I don't have an autodetected face, I need to manually determine the size and location of the face box
        let centerX: CGFloat = location.x
        let centerY: CGFloat = location.y
        print("manualBlurFace called. Location passed to it is x: \(location.x) y: \(location.y)")
        // I still need a way for the user to set the radius
        //let radius: CGFloat = 100.0
        
        print("manual face blurring with radius of: \(radius)")
        setupBlurMask(centerX: centerX, centerY: centerY, radius: radius)
        
        return addBlurMaskToImage()
    }


    private func featureFaces() -> [CIFeature] {
        return features as! [CIFeature]
    }
}
/////////////////////////////////////////////////////////////
// The next set of public methods don't belong to a class  //
//                                                         //
// They are used to compute various properties relating    //
// the image as seen in the scrollView and the underlying  //
// image that is stored in the UIImageView.                //
/////////////////////////////////////////////////////////////



// determines whether the image is portrait, landscape, or square. Portraits with different h to w ratios
// would still be considered portraits. We use this value later to avoid redundant logic statements.

public func computeImageAspectType(passedImage: UIImage) -> ImageAspectType {
    if passedImage.size.width < passedImage.size.height { //portrait
        return .isPortrait
    } else if passedImage.size.width > passedImage.size.height { //landscape
        return .isLandscape
    } else { //square image already
        return .isSquare
    }
}

//this determines the "scale" as far as how many times bigger or smaller the longest side of the displayed image is to the actual size of the longest side of the stored image in memory:
public func computeUnderlyingToDisplayedRatio(passedImage: UIImage, screenWidth: CGFloat) -> CGFloat {
    
    let underlyingImageWidth = passedImage.size.width
    let underlyingImageHeight = passedImage.size.height
    
    if computeImageAspectType(passedImage: passedImage) == ImageAspectType.isPortrait {
        print("Portrait detected. UnderlyingImageToDisplayedRatio is: \(underlyingImageHeight / screenWidth)")
        return underlyingImageHeight / screenWidth
    } else { //encompasses landscape and square images
        print("Landscape or square detected. UnderlyingImageToDisplayedRatio is: \(underlyingImageHeight / screenWidth)")
        return underlyingImageWidth / screenWidth
    }
}




// This computes the linear value of the white space either to the sides or above and below the non-square image.
// The actual value returned is only one of the two rectangles, not the total added up space. Hence the "/ 2."
public func computeWhiteSpace(passedImage: UIImage) -> CGFloat {
    let imageAspectType = computeImageAspectType(passedImage: passedImage)
    
    let underlyingImageWidth = passedImage.size.width
    let underlyingImageHeight = passedImage.size.height
    
    if imageAspectType == ImageAspectType.isPortrait {
        print("Portrait, computed white space is: \((underlyingImageHeight - underlyingImageWidth) / 2)")
        return (underlyingImageHeight - underlyingImageWidth) / 2
    } else if imageAspectType == ImageAspectType.isLandscape {
        return (underlyingImageWidth - underlyingImageHeight) / 2
    } else { //it's a square, there is no white space
        return 0.0
    }
}

public func computeOrig(passedImage: UIImage, pointToConvert: CGPoint, screenWidth: CGFloat, contentOffset: CGPoint, zoomScale: CGFloat) -> CGPoint {
    let unzoomedOffsetX = contentOffset.x / zoomScale
    let unzoomedOffsetY = contentOffset.y / zoomScale
    let unzoomedPointToConvertX = pointToConvert.x / zoomScale
    let unzoomedPointToConvertY = pointToConvert.y / zoomScale
    var returnedX: CGFloat
    var returnedY: CGFloat
    
    //We need to do something with the point to convert
    
    
    
    
    
    let underlyingToDisplayedRatio = computeUnderlyingToDisplayedRatio(passedImage: passedImage, screenWidth: screenWidth)
    let whiteSpace = computeWhiteSpace(passedImage: passedImage)
    //if it's not a square, we need to account for the white space.
    //Since we know the photo is centered between the white space, we know that half of the white space
    // is on either side of it. (already factored into the white space value)
    if computeImageAspectType(passedImage: passedImage) == ImageAspectType.isPortrait {
        //print("returning \((unzoomedOffsetX * underlyingToDisplayedRatio) - whiteSpace) for origX")
        print("underlying image width is \(passedImage.size.width) and height is \(passedImage.size.height)")
        returnedX = (unzoomedPointToConvertX * underlyingToDisplayedRatio) + (unzoomedOffsetX * underlyingToDisplayedRatio) - whiteSpace
        returnedY = (unzoomedPointToConvertY * underlyingToDisplayedRatio) + (unzoomedOffsetY * underlyingToDisplayedRatio)
    } else {
        returnedX = (unzoomedPointToConvertX * underlyingToDisplayedRatio) + (unzoomedOffsetX * underlyingToDisplayedRatio)
        returnedY = (unzoomedPointToConvertY * underlyingToDisplayedRatio) + (unzoomedOffsetY * underlyingToDisplayedRatio) - whiteSpace
    }

    return CGPoint(x: returnedX, y: returnedY)
}








