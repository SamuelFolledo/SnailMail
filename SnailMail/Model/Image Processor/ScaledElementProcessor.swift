//
//  ScaledElementProcessor.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/6/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Firebase

class ScaledElementProcessor {
    let vision = Vision.vision()
    var textRecognizer: VisionTextRecognizer!
      
    init() {
      textRecognizer = vision.onDeviceTextRecognizer() //textRecognizer is the main object you can use to detect text in images. Used to recognize the text contained in the image currently displayed by the UIImageView
    }
    
    func processImage(_ image: UIImage, callback: @escaping (_ text: String) -> Void) { //takes an image and process the texts inside the image //added also an array of shape layers
//        let newImage: UIImage = UIImage(cgImage: image.cgImage!, scale: 1, orientation: .left)
        let visionImage = VisionImage(image: image) //ML Kit uses a special VisionImage type. It’s useful because it can contain specific metadata for ML Kit to process the image, such as the image’s orientation
        textRecognizer.process(visionImage) { result, error in //The textRecognizer has a process method that takes in the VisionImage, and it returns an array of text results in the form of a parameter passed to a closure.
            guard error == nil,
                let result = result,
                !result.text.isEmpty
                else { //The result could be nil, and, in that case, you’ll want to return an empty string for the callback.
                    callback("")
                    return
            }
            callback(result.text)
        }
    }
    
//    func process(in imageView: UIImageView, callback: @escaping (_ text: String) -> Void) {
    func process(in imageView: UIImageView, callback: @escaping (_ text: String, _ scaledElements: [ScaledElement]) -> Void) { //added also an array of shape layers
        guard let image = imageView.image else { return } //check for image, else return or throw an error
        let visionImage = VisionImage(image: image) //ML Kit uses a special VisionImage type. It’s useful because it can contain specific metadata for ML Kit to process the image, such as the image’s orientation
        textRecognizer.process(visionImage) { result, error in //The textRecognizer has a process method that takes in the VisionImage, and it returns an array of text results in the form of a parameter passed to a closure.
            guard
                error == nil,
                let result = result,
                !result.text.isEmpty
            else { //The result could be nil, and, in that case, you’ll want to return an empty string for the callback.
                callback("", [])
                return
            }
            var scaledElements: [ScaledElement] = []
            // 3
            for block in result.blocks {
                for line in block.lines { //get each lines from block
                    //                    for element in line.elements { //get each element in each lines, think of it like words in each setences
                    let frame = self.createScaledFrame(featureFrame: line.frame, imageSize: image.size, viewFrame: imageView.frame) //calls our createScaledFrame method that gives us the frame we want to give a shape layer to
                    let shapeLayer = self.createShapeLayer(frame: frame) //The innermost for loop creates the shape layer from the element’s frame, which is then used to construct a new ScaledElement instance.
                    let scaledElement = ScaledElement(frame: line.frame, shapeLayer: shapeLayer)
                    scaledElements.append(scaledElement) //Add the newly created instance to scaledElements.
                }
                //                }
                print("Result from Processor's processor \(result.text)")
                callback(result.text, scaledElements) //Lastly, the callback is triggered to relay the recognized text
            }
        }
    }
    
    func createShapeLayer(frame: CGRect) -> CAShapeLayer { //method that will create a shape layer to a frame, VC will actually draw it
        let bpath = UIBezierPath(rect: frame)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = bpath.cgPath //A CAShapeLayer does not have an initializer that takes in a CGRect. So, you construct a UIBezierPath with the CGRect and set the shape layer’s path to the UIBezierPath.
        shapeLayer.strokeColor = Constants.lineColor //set the visual properties
        shapeLayer.fillColor = Constants.fillColor
        shapeLayer.lineWidth = Constants.lineWidth
        return shapeLayer
    }

    private func createScaledFrame(featureFrame: CGRect, imageSize: CGSize, viewFrame: CGRect) -> CGRect { //This method takes in CGRects for the original size of the image, the displayed image size, and the frame of the UIImageView
        let viewSize = viewFrame.size
        let resolutionView = viewSize.width / viewSize.height //resolutions of the image and view are calculated by dividing their heights and widths
        let resolutionImage = imageSize.width / imageSize.height
        var scale: CGFloat
        if resolutionView > resolutionImage { //The scale is determined by which resolution is larger. If the view is larger, you scale by the height; otherwise, you scale by the width
            scale = viewSize.height / imageSize.height
        } else {
            scale = viewSize.width / imageSize.width
        }
        let featureWidthScaled = featureFrame.size.width * scale //This method calculates width and height. The width and height of the frame are multiplied by the scale to calculate the scaled width and height.
        let featureHeightScaled = featureFrame.size.height * scale
        let imageWidthScaled = imageSize.width * scale //The origin of the frame must be scaled as well; otherwise, even if the size is correct, it would be way off center in the wrong position.
        let imageHeightScaled = imageSize.height * scale
        let imagePointXScaled = (viewSize.width - imageWidthScaled) / 2
        let imagePointYScaled = (viewSize.height - imageHeightScaled) / 2
        let featurePointXScaled = imagePointXScaled + featureFrame.origin.x * scale //The new origin is calculated by adding the x and y point scales to the unscaled origin multiplied by the scale
        let featurePointYScaled = imagePointYScaled + featureFrame.origin.y * scale
        return CGRect(x: featurePointXScaled, y: featurePointYScaled,
                      width: featureWidthScaled, height: featureHeightScaled) //A scaled CGRect is returned, configured with calculated origin and size
    }
    
//MARK: Constants
    private enum Constants { //constants
        static let lineWidth: CGFloat = 3.0
        static let lineColor = UIColor.yellow.cgColor
        static let fillColor = UIColor.clear.cgColor
    }
}
