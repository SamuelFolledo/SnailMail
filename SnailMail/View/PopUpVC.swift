//
//  PopUpVC.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/8/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

protocol ScannerMailProtocol {
    /* parameters here is what the parent class will receive */
    func didUpdateMail(name: String)
    func didRetakeMail(mail: Mail)
    func didSendMail(mail: Mail)
}

class PopUpVC: UIViewController {
//MARK: Properties
    var hasKeyboard: Bool = false
    var delegate: ScannerMailProtocol!
    var mail: Mail!
    var mailImage: UIImage = kBLANKIMAGE
    var mailName: String = ""
    let processor = ScaledElementProcessor()
    var frameSublayer = CALayer()
    
//MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UnderlinedTextField!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
//MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        imageView.image = mailImage
        displayDetectedText(in: imageView)
//        textField.text = mailName
//        processor.process(in: imageView) { text, elements in
//            elements.forEach() { element in
//                self.frameSublayer.addSublayer(element.shapeLayer) //this controller has a frameSublayer property that is attached to the imageView. Here, you add each element’s shape layer to the sublayer, so that iOS will automatically draw the shape on the image
//            }
//            print("text issss = \(text)")
//            if text != self.textField.text {
//                self.textField.text = text
//            }
//        // 3
////            completion?()
//        }
//        processor.processImage(mailImage) { text in
//            print("New text = \(text)")
//            if self.textField.text != text { //to avoid duplicates
//                self.textField.text = text
//            }
//        }
    }
    
    private func displayDetectedText(in imageView: UIImageView, completion: (() -> Void)? = nil) { //method that takes in the UIImageView and a callback so that you know when it's done
//        removeFrames() //remove the frames before processing a new image
        processor.process(in: imageView) { text, elements in
            elements.forEach() { element in
                self.frameSublayer.addSublayer(element.shapeLayer) //this controller has a frameSublayer property that is attached to the imageView. Here, you add each element’s shape layer to the sublayer, so that iOS will automatically draw the shape on the image
            }
            self.textField.text = text
        // 3
            completion?()
        }
    }
    
//MARK: Private Methods
    fileprivate func setupViews() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissTap(_:)))
        self.view.addGestureRecognizer(tap)
        showAnimate()
        setupKeyboardNotifications()
        textField.textColor = .white
        retakeButton.isPopupButton()
        sendButton.isPopupButton()
    }
    
    fileprivate func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(PopUpVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PopUpVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func showAnimate() { //show popup with animation
        view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    fileprivate func dismissPopup() { //dismiss popup with animation
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0;
        }, completion:{(finished : Bool)  in
            if (finished) {
                self.view.removeFromSuperview()
            }
        });
    }
    
//MARK: IBActions
    @IBAction func sendButtonTapped(_ sender: Any) {
        guard let text = textField.text else { return }
        print("\(text) and \(mailName)")
        if text != "" {
            if let delegate = delegate {
                delegate.didUpdateMail(name: text)
            }
        }
        dismissPopup()
    }
    
    @IBAction func retakeButtonTapped(_ sender: Any) {
        if let delegate = delegate {
            delegate.didRetakeMail(mail: mail!)
        }
        dismissPopup()
    }
    
//MARK: Helpers
    @objc func handleDismissTap(_ gesture: UITapGestureRecognizer) { //if keyboard is up, dismiss keyboard, else dismiss popup
        if hasKeyboard {
            self.view.endEditing(false)
        } else {
            if let delegate = delegate {
                delegate.didRetakeMail(mail: mail!)
            }
            dismissPopup()
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) { //makes the view go up by keyboard's height
        hasKeyboard = true
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if view.frame.origin.y == 0 {
//                view.frame.origin.y -= keyboardSize.height
//            }
//        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) { //put the view back to 0
        hasKeyboard = false
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
}

//MARK: Extensions


