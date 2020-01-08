//
//  UIImage+extensions.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/6/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

extension UIImage {
    
    var isPortrait: Bool { return size.height > size.width } //RE ep.106 5mins check if portrait or landscape, and returning the height and width differences
    var isLandscape: Bool { return size.width > size.height } //RE ep.106 5mins
    var breadth: CGFloat { return min(size.width, size.height) } //RE ep.106 5mins returns the screen's minimum width or height
    var breadthSize: CGSize { return CGSize(width: breadth, height: breadth) } //RE ep.106 5mins set our minimum width or height
    var breadthRect: CGRect { return CGRect(origin: .zero, size: breadthSize) } //RE ep.106 5mins sete the rect here
    
    var circleMasked: UIImage? { //RE ep.106 5mins now that we have a square image, we checked if the view is portrait or landscape. Now we make the image round
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale) //RE ep.106 5mins
        defer { UIGraphicsEndImageContext() } //RE ep.106 5mins if we dont have any image, dont start it
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: CGPoint(x: isLandscape ? floor( (size.width - size.height) / 2 ) : 0,
                                                                         y: isPortrait ? floor( (size.height - size.width) / 2 ) : 0),
                                                                        size: breadthSize)) else { return nil } //RE ep.106 5mins convert our UIImage and crop it
        UIBezierPath(ovalIn: breadthRect).addClip() //RE ep.106 5mins create a bezier path
        UIImage(cgImage: cgImage).draw(in: breadthRect) //RE ep.106 5mins create a UIImage from a CgImage
        return UIGraphicsGetImageFromCurrentImageContext() //RE ep.106 5mins returns our circle image
    }
    
    func scaleImageToSize(newSize: CGSize) -> UIImage { //RE ep.106 5mins
        var scaledImageRect = CGRect.zero //RE ep.106 5mins create a
        
        let aspectWidth = newSize.width / size.width //RE ep.106 5mins
        let aspectHeight = newSize.height / size.height //RE ep.106 5mins
        
        let aspectRatio = max(aspectWidth, aspectHeight) //RE ep.106 5mins
        
        scaledImageRect.size.width = size.width * aspectRatio //RE ep.106 5mins
        scaledImageRect.size.height = size.height * aspectRatio //RE ep.106 5mins
        scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0; //RE ep.106 5mins
        scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0; //RE ep.106 5mins
        
        UIGraphicsBeginImageContext(newSize) //RE ep.106 5mins
        draw(in: scaledImageRect) //RE ep.106 5mins
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext() //RE ep.106 5mins
        UIGraphicsEndImageContext() //RE ep.106 5mins
        
        return scaledImage! //RE ep.106 5mins return our scaled image back
    }
    
  // Thx to: https://stackoverflow.com/questions/8915630/ios-uiimageview-how-to-handle-uiimage-image-orientation
  func fixOrientation() -> UIImage? {
    guard let cgImage = self.cgImage else {
      return nil
    }
    if imageOrientation == .up {
      return self
    }
    
    let width  = self.size.width
    let height = self.size.height
    var transform = CGAffineTransform.identity
    
    switch imageOrientation {
    case .down, .downMirrored:
      transform = transform.translatedBy(x: width, y: height)
      transform = transform.rotated(by: CGFloat.pi)
    case .left, .leftMirrored:
      transform = transform.translatedBy(x: width, y: 0)
      transform = transform.rotated(by: 0.5*CGFloat.pi)
    case .right, .rightMirrored:
      transform = transform.translatedBy(x: 0, y: height)
      transform = transform.rotated(by: -0.5*CGFloat.pi)
    case .up, .upMirrored:
      break
    @unknown default:
        break
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    guard let colorSpace = cgImage.colorSpace else {
      return nil
    }
    
    guard let context = CGContext(
      data: nil,
      width: Int(width),
      height: Int(height),
      bitsPerComponent: cgImage.bitsPerComponent,
      bytesPerRow: 0,
      space: colorSpace,
      bitmapInfo: UInt32(cgImage.bitmapInfo.rawValue)
      ) else {
        return nil
    }
    context.concatenate(transform);
    
    switch imageOrientation {
    case .left, .leftMirrored, .right, .rightMirrored:
      // Grr...
      context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
    default:
      context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    }
    
    // And now we just create a new UIImage from the drawing context
    guard let newCGImg = context.makeImage() else {
      return nil
    }
    
    let img = UIImage(cgImage: newCGImg)
    return img;
  }
}
