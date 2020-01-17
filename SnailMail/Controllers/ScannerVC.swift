//
//  ScannerVC.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/8/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import SceneKit //for scannerView
import AVFoundation //for scannerView

class ScannerVC: UIViewController {
//MARK: Properties
    var device: AVCaptureDevice!
    var cameraSession: AVCaptureSession! //to connect a video input, like a camera
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer! //preview layer
    var cameraImageOutput: AVCapturePhotoOutput!
    var mails: [String:Mail] = [:] //???????
    var frameSublayer = CALayer() //???????
    var scannedText: String = "Detected text will be here."
    let processor = ScaledElementProcessor()
    let mailRef = firDatabase.child(kMAIL)
    
//MARK: IBOutlets
    @IBOutlet weak var scannerView: SCNView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var mailCountLabel: UILabel!
    @IBOutlet weak var successImageView: UIImageView!
    @IBOutlet weak var successLabel: UILabel!
    @IBOutlet weak var successView: UIView!
    
//MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateFirebaseObservers(shouldStart: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        updateFirebaseObservers(shouldStart: false)
    }
    
//MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMailsTableVC" {
            let vc: MailsTableVC = segue.destination as! MailsTableVC
            let mailsArr: [Mail] = Array(mails.values).reversed() //reversed to put newest at the top
            vc.mails = mailsArr
        }
    }
    
//MARK: Private Methods
    fileprivate func setupViews() {
        view.backgroundColor = .black
        scannerView.layer.addSublayer(frameSublayer)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(viewPinched(recognizer:)))
        scannerView.addGestureRecognizer(pinch)
        successView.isHidden = true
        configureVideoOrientation()
        startCamera()
    }
    
    fileprivate func getDetectedText(image: UIImage, completion: @escaping (_ text: String) -> Void) {//method that takes in the UIImageView and a callback so that you know when it's done
        processor.processImage(image) { text in
            if self.scannedText != text { //to avoid duplicates
                self.scannedText = text
            }
            completion(text)
        }
    }
    
    fileprivate func startCamera() { //start running the rear camera full screen
        cameraSession = AVCaptureSession()
        cameraSession.sessionPreset = AVCaptureSession.Preset.photo
        cameraImageOutput = AVCapturePhotoOutput()
        device = AVCaptureDevice.default(for: .video)
        if let input = try? AVCaptureDeviceInput(device: device) {
            if (cameraSession.canAddInput(input)) {
                cameraSession.addInput(input)
                if (cameraSession.canAddOutput(cameraImageOutput)) {
                    cameraSession.addOutput(cameraImageOutput)
                    cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: cameraSession)
                    cameraPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    cameraPreviewLayer.frame = self.view.bounds //make the preview full screen
                    self.view.layer.insertSublayer(cameraPreviewLayer, at: 0)
                    cameraSession.startRunning()
                }
            } else {
                print("issue here : captureSesssion.canAddInput")
            }
        } else {
            print("some problem here")
        }
    }
    
    fileprivate func configureVideoOrientation() { //sets the previewLayer's orientation correctly
        /* https://stackoverflow.com/questions/15075300/avcapturevideopreviewlayer-orientation-need-landscape
         */
        if let previewLayer = self.cameraPreviewLayer,
            let connection = previewLayer.connection {
            let orientation = UIDevice.current.orientation
            if connection.isVideoOrientationSupported,
                let videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) {
                previewLayer.frame = self.view.bounds
                connection.videoOrientation = videoOrientation
            }
        }
    }
    
    fileprivate func captureImage() { //captures a still image from imageOutput
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 1600,
            kCVPixelBufferHeightKey as String: 1600
        ]
        settings.previewPhotoFormat = previewFormat
        cameraImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    fileprivate func updateFirebaseObservers(shouldStart: Bool) { //childAdded, childRemoved, and remove observers for mails
        if shouldStart {
            self.mails.removeAll()
            mailRef.observe(.childAdded, with: { (snapshot) in
                if snapshot.exists() {
                    guard let mailDic = snapshot.value as? [String: Any] else { return }
                    let mail: Mail = Mail(_dictionary: mailDic as NSDictionary)
                    self.mails[mail.objectId] = mail
                }
                self.mailCountLabel.text = "\(self.mails.count)"
            }, withCancel: nil)
            mailRef.observe(.childRemoved) { (snapshot) in //delete from mails
                if snapshot.exists() {
                    guard let mailDic = snapshot.value as? [String: Any] else { return }
                    let mail: Mail = Mail(_dictionary: mailDic as NSDictionary)
                    self.mails.removeValue(forKey: mail.objectId)
                }
                self.mailCountLabel.text = "\(self.mails.count)"
            }
        } else {
            mailRef.removeAllObservers()
        }
    }
    
    fileprivate func getMailName(text: String) -> (name:String, address: String) { //from scannedText, get the name
        /* ALGORITHM to find a name from the scanned text
         1. put string in an array of strings
         2. loop through each string, and starting from the end of the string, loop until it reaches a whitespace, and get that word
         3. if that word is either avenue, street, lane, etc. get the index of that line
         4. index - 1 should be the index of the line that has the name
         */
        var nameAndAddress: (name: String, address: String) = (name: "", address: "")
        let lines: [String] = text.lines //turns multi-line text(String) into an array of strings
//        for (index, line) in lines.reversed().enumerated() where streetSuffix.contains(line.lastWord.lowercased().filter(allAlphaNum.contains)) { //loop through streetSuffix array in reversed() where line's lastWord is in streetSuffix array //lastWord is lowercased() to ignore cases
        for (index, line) in lines.reversed().enumerated() where line.firstWord.isAllNumbers { //loop through lines in reversed() where line's firstWord is made up of all integers only
            for word in line.byWords where streetSuffix.contains(word.lowercased().filter(allAlphaNum.contains)) { //for each word in line where it contains one of streetSuffix...
                print("1)\(line) in index \(index)::: \(word)")
                nameAndAddress.address = line //line that has a street suffix will be the address line
                print("1) ADDRESS = \(nameAndAddress.address)")
                var lineNameIndex: Int = lines.count - 1 - index - 1 //lineName will be the line on top of address line's index
                nameAndAddress.name = lines[lineNameIndex]
                while illegalNames.contains(nameAndAddress.name.lowercased().filter(allAlphaNum.contains)) && lineNameIndex >= 0 { //while name grabbed is one of the illegal names keep going up one line, or until it reaches the first/highest line
                    print("1) \(nameAndAddress.name) name is ILLEGAL ❌")
                    lineNameIndex -= 1
                    nameAndAddress.name = lines[lineNameIndex]
                }
                print("1) \(nameAndAddress.name) name is ALLOWED ✅")
                return nameAndAddress
            }
        }
        return nameAndAddress
    }
    
    fileprivate func sendSlackMessage(mail: Mail) {
        dataRequest(with: getURLFromMail(mail: mail), objectType: MailOwner.self) { (result: Result) in //GET from API
            DispatchQueue.main.async {
                switch result {
                case .success(let object):
                    print("didSend OBJECT = \(object)")
//                    guard let name = object[kNAME] as? String else { return }
                    //                guard let note = object[kNOTE] as? String else { return }
                    guard let success = object[kSUCCESS] as? Int else { return }
                    //                guard let error = object[kERROR] as? String else { return }
                    //                guard let slackID = object[kSLACKID] as? String else { return }
                    //                print(name, note, success, error, slackID)
                    DispatchQueue.main.async {
                        if success == 0 {
                            self.showSuccessAlertView(success: false, message: "No User Found")
                        } else {
                            self.showSuccessAlertView(success: true, message: "Mail Sent!")
                        }
                    }
                case .failure(let error):
                    Service.presentAlert(on: self, title: "API Error", message: error.localizedDescription)
                }
            }
        }
    }
    
//MARK: IBActions
    @IBAction func mailButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toMailsTableVC", sender: nil)
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        Service.presentAlert(on: self, title: "Menu Coming Soon", message: "Please check back in the future")
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        cameraButton.isEnabled = false
        captureImage()
    }
    
//MARK: Helpers
    fileprivate func getURLFromMail(mail: Mail) -> String {
        let nameArr: [String] = mail.name.byWords
        print("Mail name \(mail.name)")
        let streetAddressArray: [String] = mail.scannedText.byWords
        var addressURL: String = ""
        if streetAddressArray[0] != "" && streetAddressArray[1] != "" && streetAddressArray[2] != "" {
            addressURL = "&addy=\(streetAddressArray[0])%20\(streetAddressArray[1])%20\(streetAddressArray[2])"
        }
        print("STREET ADDRESS for URL = \(mail.scannedText)")
        let nameQueryString: String = "name=\(nameArr.first ?? "")%20\(nameArr.last ?? "")"
        
        return "https://ms-snailmail.herokuapp.com/api/?\(nameQueryString)\(addressURL)"
    }
    
    fileprivate func showSuccessAlertView(success: Bool, message: String) {
        successImageView.image = success ? kCORRECTIMAGE : kWRONGIMAGE
        successLabel.text = message
        successView.enlargeThenShrinkAnimation()
    }
    
    fileprivate func handleMailError(mail: Mail?, errorMessage: String) {
        cameraButton.isEnabled = true
        if let mail = mail { //remove mail from mails
            mails.removeValue(forKey: mail.objectId)
            deleteMail(mail: mail) { (error) in
                if let error = error {
                    Service.presentAlert(on: self, title: "Error Deleting Mail", message: error.localizedDescription)
                    return
                }
            }
        }
        Service.presentAlert(on: self, title: "Error", message: errorMessage)
    }
}

//MARK: Extensions
extension ScannerVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            Service.presentAlert(on: self, title: "Error", message: error.localizedDescription)
        }
        if let dataImage = photo.fileDataRepresentation() {
            //            print(UIImage(data: dataImage)?.size as Any)
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
            let rotatedImage = image.rotate(radians: 0) //turn the image into .up for Firebase to scan it properly
            getDetectedText(image: rotatedImage!) { scannedText in //scan the image's text
                let mailNameAndAddress: (name:String, address: String) = self.getMailName(text: scannedText) //get the name from scannedText from image
                self.scannedText = mailNameAndAddress.address //TEMPORARY ADDRESS Placeholder
                let values: [String: Any] = [kNAME: mailNameAndAddress.name, kSCANNEDTEXT: mailNameAndAddress.address, kIMAGEURL: ""]
                saveMail(values: values) { (mail, error) in //with mail's name, save mail
                    if let error = error {
                        self.handleMailError(mail: mail, errorMessage: error)
                        return
                    }
                    guard let mail: Mail = mail else { return } //with mail, show popUp
                    getImageURL(mail: mail, image: image) { (imageUrl, error) in //store the image scanned and get image url
                        if let error = error {
                            self.handleMailError(mail: mail, errorMessage: error.localizedDescription)
                            return
                        }
                        mail.imageUrl = imageUrl! //update
                        self.mails[mail.objectId] = mail //add mail to mails
                        updateMail(mail: mail) { (error) in
                            if let error = error {
                                self.handleMailError(mail: mail, errorMessage: error.localizedDescription)
                                return
                            }
                            let popUpVC: PopUpVC = UIStoryboard(name: "PopUp", bundle: nil).instantiateViewController(withIdentifier: "mailPopUpView") as! PopUpVC
                            popUpVC.delegate = self
                            popUpVC.mail = mail
                            popUpVC.mailImage = image
                            print("MAIL NAME = \(mail.name)")
                            self.addChild(popUpVC)
                            popUpVC.view.frame = self.view.frame
                            self.view.addSubview(popUpVC.view)
                            popUpVC.didMove(toParent: self)
                        }
                    }
                }
            }
        } else {
            print("Error: could not get imageData from photo.fileDataRepresentation()")
        }
    }
}

extension ScannerVC: ScannerMailProtocol {
    func didRetakeMail(mail: Mail) {
        cameraButton.isEnabled = true
        deleteMail(mail: mail) { (error) in
            if let error = error {
                self.handleMailError(mail: mail, errorMessage: error.localizedDescription)
                return
            }
        }
    }
    
    func didSendMail(mail: Mail) {
        cameraButton.isEnabled = true
        sendSlackMessage(mail: mail)
    }
    
    func didUpdateMail(mail: Mail) {
        cameraButton.isEnabled = true
        print("updated mail's name to \(mail.name)")
        updateMail(mail: mail) { (error) in
            if let error = error {
                self.handleMailError(mail: mail, errorMessage: error.localizedDescription)
                return
            }
            self.mails[mail.objectId] = mail
            self.sendSlackMessage(mail: mail)
        }
    }
}

extension ScannerVC: UIGestureRecognizerDelegate {
    @objc func viewPinched(recognizer: UIPinchGestureRecognizer) { //pinch gesture for zooming camera in and out
        switch recognizer.state {
            case .began:
                recognizer.scale = device.videoZoomFactor
            case .changed:
                let scale = recognizer.scale
                do {
                     try device.lockForConfiguration()
                     device.videoZoomFactor = max(device.minAvailableVideoZoomFactor, min(scale, device.maxAvailableVideoZoomFactor))
                     device.unlockForConfiguration()
                }
                catch {
                    Service.presentAlert(on: self, title: "Pinch Error", message: error.localizedDescription)
                }
            default:
                break
        }
    }
}
