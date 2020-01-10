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
    
//MARK: IBOutlets
    @IBOutlet weak var scannerView: SCNView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var mailCountLabel: UILabel!
    
//MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        configureVideoOrientation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCamera()
    }
    
//MARK: Private Methods
    fileprivate func setupViews() {
        view.backgroundColor = .black
        scannerView.layer.addSublayer(frameSublayer)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(viewPinched(recognizer:)))
        scannerView.addGestureRecognizer(pinch)
    }
    
    fileprivate func displayDetectedText(image: UIImage, completion: (() -> Void)? = nil) { //method that takes in the UIImageView and a callback so that you know when it's done
        processor.processImage(image) { text in
            if self.scannedText != text { //to avoid duplicates
                self.scannedText = text
            }
            completion?()
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
    
    fileprivate func getMailName(text: String) -> String { //from scannedText, get the name
        /* ALGORITHM to find a name from the scanned text
         1. put string in an array of strings
         2. loop through each string, and starting from the end of the string, loop until it reaches a whitespace, and get that word
         3. if that word is either avenue, street, lane, etc. get the index of that line
         4. index - 1 should be the index of the line that has the name
         */
        var name: String = ""
        let lines: [String] = text.lines //turns multi-line text(String) into an array of strings
        for (index, line) in lines.reversed().enumerated() where streetSuffix.contains(line.lastWord.lowercased()) { //loop through streetSuffix array in reversed() where line's lastWord is in streetSuffix array //lastWord is lowercased() to ignore cases
            var trialCount: Int = 1
            name = lines[lines.count - trialCount - index - 1] //nameLine should be the index before the line that has the last word as a street suffix. Since array is reverse(), we had to subtract - index and another - 1 to get the line on top of it
            while impossibleNames.contains(name){ //extra error checker
                if trialCount > 10 { //if too many trials then break
                    name = ""
                    break
                }
                trialCount += 1
                name = lines[lines.count - trialCount - index - 1]
            }
            break //stop the loop because we only want the first instance of street suffix
        }
        return name
    }
    
//MARK: IBActions
    @IBAction func mailButtonTapped(_ sender: Any) {
        Service.presentAlert(on: self, title: "All mails coming soon", message: "Please check back in the future")
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        Service.presentAlert(on: self, title: "Menu Coming Soon", message: "Please check back in the future")
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        cameraButton.isEnabled = false
        captureImage()
    }
    
//MARK: Helpers

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
            let rotatedImage = image.rotate(radians: 0) //turn the image into .up for Firebase to scan in properly
            displayDetectedText(image: rotatedImage!) {
                let mailText = self.getMailName(text: self.scannedText)
                saveMail(text: mailText) { (mail, error) in
                    if let error = error {
                        Service.presentAlert(on: self, title: "Error", message: error)
                        return
                    }
                    let popUpVC: PopUpVC = UIStoryboard(name: "PopUp", bundle: nil).instantiateViewController(withIdentifier: "mailPopUpView") as! PopUpVC
                    popUpVC.delegate = self
                    popUpVC.mailImage = image
                    popUpVC.mail = mail
                    self.addChild(popUpVC)
                    popUpVC.view.frame = self.view.frame
                    self.view.addSubview(popUpVC.view)
                    popUpVC.didMove(toParent: self)
                }
            }
        } else {
            print("Error: could not get imageData from photo.fileDataRepresentation()")
        }
    }
}

extension ScannerVC: ScannerMailProtocol {
    func didRetakeMail(mail: Mail) {
        deleteMail(objectId: mail.objectId) { (error) in
            if let error = error {
                Service.presentAlert(on: self, title: "Error Deleting Mail", message: error.localizedDescription)
            }
        }
        cameraButton.isEnabled = true
    }
    
    func didSendMail(mail: Mail) {
        print("send mail")
        cameraButton.isEnabled = true
        let nameArr: [String] = mail.name.byWords
        let nameQueryString: String = "\(nameArr.first ?? "")%20\(nameArr.last ?? "")"
        let urlString: String = "https://ms-snailmail.herokuapp.com/api/\(nameQueryString)"
        dataRequest(with: urlString, objectType: MailOwner.self) { (result: Result) in
            switch result {
            case .success(let object):
                print("OBJECT = \(object)")
            case .failure(let error):
                Service.presentAlert(on: self, title: "API Error", message: error.localizedDescription)
            }
        }
        
//        print("send mail")
//        cameraButton.isEnabled = true
//        let nameArr: [String] = mail.name.byWords
//        let nameQueryString: String = "\(nameArr.first ?? "")%20\(nameArr.last ?? "")"
//        let url: URL = URL(string: "https://ms-snailmail.herokuapp.com/api/\(nameQueryString)")!
//        dataRequest(with: <#T##String#>, objectType: ., completion: <#T##(Result<Decodable>) -> Void#>)
        //        mail.sendAndGetData { (data, error) in
        //            if let error = error {
        //                Service.presentAlert(on: self, title: "Error", message: error.localizedDescription)
        //                return
        //            }
        //            guard let data = data else { return }
        //            if let success = data[kSUCCESS] as? String, success == "false"  { //if not success, show error
        //                guard let dataError = data[kERROR] as? String else { return }
        //                Service.presentAlert(on: self, title: "Error", message: dataError)
        //                return
        //            }
        ////            let note = data[kNOTE] as? String //currently optional
        //            let name = data[kNAME] as? String
        //            let slackID = data[kSLACKID] as? String
        //            print("NAME = \(name), SLACKID = \(slackID)")
        //
        //        }
        
    }
    
    func didUpdateMail(name: String) {
        print("updated mail's name = \(name)")
        cameraButton.isEnabled = true
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
