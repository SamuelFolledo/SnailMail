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
    var cameraSession: AVCaptureSession! //to connect a video input, like a camera
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer! //preview layer
    var cameraImageOutput: AVCapturePhotoOutput!
    let scene = SCNScene() //scene for scannerView
    var mails: [String:Mail] = [:]
    var capturedImage: UIImage? = nil
    var images: [UIImage] = []
    var frameSublayer = CALayer()
    var scannedText: String = "Detected text can be edited here." {
        didSet {
            print("\(kSCANNEDTEXT) = \(scannedText)")
        }
    }
    let processor = ScaledElementProcessor()
    var deviceOrientation = UIImage.Orientation.down
    
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
        if let device = AVCaptureDevice.default(for: .video),
           let input = try? AVCaptureDeviceInput(device: device) {
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
                saveMail(text: self.scannedText) { (mail, error) in
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
            print("some error here")
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
    }
    
    func didUpdateMail(name: String) {
        print("updated mail's name = \(name)")
        cameraButton.isEnabled = true
    }
}
