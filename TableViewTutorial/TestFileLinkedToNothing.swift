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
