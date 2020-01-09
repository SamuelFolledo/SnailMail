//
//  PopUpVC.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/8/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

protocol ScannerMailProtocol {
    func editName(name: String)
    func didRetakeMail(mail: Mail)
    func didSendMail(mail: Mail)
}

class PopUpVC: UIViewController {
//MARK: Properties
    var hasKeyboard: Bool = false
    var delegate: ScannerMailProtocol!
    var mailImage: UIImage = kBLANKIMAGE {
        didSet {
            imageView.image = mailImage
        }
    }
    var mailName: String = "" {
        didSet {
            textField.text = mailName
        }
    }
    
//MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UnderlinedTextField!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
//MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
//MARK: Private Methods
    fileprivate func setupViews() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissTap(_:)))
        self.view.addGestureRecognizer(tap)
        showAnimate()
        setupKeyboardNotifications()
        retakeButton.isPopupButton()
        sendButton.isPopupButton()
    }
    
    fileprivate func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(PopUpVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PopUpVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    fileprivate func showAnimate() {
        view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        view.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    fileprivate func removeAnimate() {
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
        if text != "" {
            if let delegate = delegate {
                delegate.editName(name: text)
            }
        }
        dismissPopup()
    }
    
    @IBAction func retakeButtonTapped(_ sender: Any) {
        dismissPopup()
    }
    
//MARK: Helpers
    @objc func handleDismissTap(_ gesture: UITapGestureRecognizer) { //if keyboard is up, dismiss keyboard, else dismiss popup
        if hasKeyboard {
            self.view.endEditing(false)
        } else {
            dismissPopup()
        }
    }
    
    fileprivate func dismissPopup() {
        self.removeAnimate()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) { //makes the view go up by keyboard's height
        hasKeyboard = true
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if view.frame.origin.y == 0 {
                view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) { //put the view back to 0
        hasKeyboard = false
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
}

//MARK: Extensions


