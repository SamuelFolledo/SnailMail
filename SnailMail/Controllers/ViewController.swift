//
//  ViewController.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/6/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var camButton: UIButton!
    @IBOutlet weak var albumButton: UIButton!
    
    var frameSublayer = CALayer()
    var scannedText: String = "Detected text can be edited here." {
        didSet {
            textView.text = scannedText
            saveNameToDatabase(name: scannedText) { (error) in
                if let error = error {
                    Service.presentAlert(on: self, title: "Error", message: error)
                    return
                }
            }
        }
    }
    let processor = ScaledElementProcessor()
  
//MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Notifications to slide the keyboard up
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        imageView.layer.addSublayer(frameSublayer)
        
        displayDetectedText(in: imageView)
    }
    
//MARK: Private methods
    private func displayDetectedText(in imageView: UIImageView, completion: (() -> Void)? = nil) { //method that takes in the UIImageView and a callback so that you know when it's done
        removeFrames() //remove the frames before processing a new image
        processor.process(in: imageView) { text, elements in
            elements.forEach() { element in
                self.frameSublayer.addSublayer(element.shapeLayer) //this controller has a frameSublayer property that is attached to the imageView. Here, you add each element’s shape layer to the sublayer, so that iOS will automatically draw the shape on the image
            }
            if self.scannedText != text { //to avoid duplicates
                self.scannedText = text
            }
            completion?()
        }
    }
    
    private func removeFrames() { //method that will remove sublayers, the boxes on each words
        guard let sublayers = frameSublayer.sublayers else { return }
        for sublayer in sublayers {
            sublayer.removeFromSuperlayer()
        }
    }
    
// MARK: Touch handling to dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let evt = event, let tchs = evt.touches(for: view), tchs.count > 0 {
            textView.resignFirstResponder()
        }
    }
  
// MARK: Actions
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            presentImagePickerController(withSourceType: .camera)
        } else {
            let alert = UIAlertController(title: "Camera Not Available", message: "A camera is not available. Please try picking an image from the image library instead.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func albumButtonTapped(_ sender: UIButton) {
        presentImagePickerController(withSourceType: .photoLibrary)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) { //creates a UIActivityVC that contains the scanned text and image then present it and let the user do the rest
        let vc = UIActivityViewController(activityItems: [scannedText, imageView.image!], applicationActivities: [])
        present(vc, animated: true, completion: nil)
    }

// MARK: Keyboard slide up
    @objc func keyboardWillShow(notification: NSNotification) { //makes the view go up by keyboard's height
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                view.frame.origin.y -= keyboardSize.height
            }
        }
    }
  
    @objc func keyboardWillHide(notification: NSNotification) { //put the view back to 0
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
// MARK: UIImagePickerController
    private func presentImagePickerController(withSourceType sourceType: UIImagePickerController.SourceType) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = sourceType
        controller.mediaTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
        present(controller, animated: true, completion: nil)
    }
  
// MARK: UIImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let fixedImage = pickedImage.fixOrientation() //newly selected image is rotated back to the up position
            imageView.image = fixedImage
            displayDetectedText(in: imageView) //run our converter after getting an image
        }
        dismiss(animated: true, completion: nil)
    }
}
