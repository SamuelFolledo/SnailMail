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
    
//MARK: IBOutlets
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UnderlinedTextField!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
//MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        imageView.image = mailImage
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toImageDetailVC" {
            let vc: ImageDetailVC = segue.destination as! ImageDetailVC
            vc.image = sender as? UIImage
        }
    }
    
//MARK: Private Methods
    fileprivate func setupViews() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissTap(_:)))
        self.view.addGestureRecognizer(tap)
        let popUpTap = UITapGestureRecognizer(target: self, action: #selector(handlePopupViewTap(_:)))
        self.popUpView.addGestureRecognizer(popUpTap)
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(handeImageViewTap(_:)))
        self.imageView.isUserInteractionEnabled = true
        self.imageView.addGestureRecognizer(imageTap)
        textField.textColor = .white
        textField.text = mail.scannedText
        retakeButton.isPopupButton()
        sendButton.isPopupButton()
        showAnimate()
        setupKeyboardNotifications()
    }
    
    fileprivate func setupKeyboardNotifications() { //setup notifications when keyboard shows or hide
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
        if let text = textField.text {
            if text != "" {
                if let delegate = delegate {
                    delegate.didUpdateMail(name: text)
                }
            }
            dismissPopup()
        } else { //if no text on name
            Service.presentAlert(on: self, title: "Error", message: "Receiver field cannot be empty. Please try again")
            textField.text = mail.scannedText
        }
    }
    
    @IBAction func retakeButtonTapped(_ sender: Any) {
        if let delegate = delegate {
            delegate.didRetakeMail(mail: mail!)
        }
        dismissPopup()
    }
    
//MARK: Helpers
    @objc func handeImageViewTap(_ gesture: UITapGestureRecognizer) { //go to imageDetailVC
        performSegue(withIdentifier: "toImageDetailVC", sender: mailImage)
    }
    
    @objc func handlePopupViewTap(_ gesture: UITapGestureRecognizer) { //if keyboard is up, dismiss keyboard
        if hasKeyboard {
            self.view.endEditing(false)
        }
    }
    
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
    }
    
    @objc func keyboardWillHide(notification: NSNotification) { //put the view back to 0
        hasKeyboard = false
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
}

//MARK: Extensions
