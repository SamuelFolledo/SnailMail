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
    var images: [UIImage] = []
    var frameSublayer = CALayer()
    var scannedText: String = "Detected text can be edited here." {
        didSet {
            print("\(kSCANNEDTEXT) = \(scannedText)")
            saveMail(text: scannedText) { (error) in
                if let error = error {
                    Service.presentAlert(on: self, title: "Error", message: error)
                    return
                }
            }
        }
    }
    let processor = ScaledElementProcessor()
    
//MARK: IBOutlets
    @IBOutlet weak var scannerView: SCNView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var mailCountLabel: UILabel!
    
//MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
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
    
    fileprivate func captureImage() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        cameraImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
//MARK: IBActions
    @IBAction func mailButtonTapped(_ sender: Any) {
        print("All mails coming soon")
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        print("Menu coming soon")
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        captureImage()
    }
    
//MARK: Helpers

}

//MARK: Extensions
extension ScannerVC: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("error occured : \(error.localizedDescription)")
        }
        if let dataImage = photo.fileDataRepresentation() {
//            print(UIImage(data: dataImage)?.size as Any)
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
            displayDetectedText(image: image) {
                let popUpVC: PopUpVC = UIStoryboard(name: "PopUp", bundle: nil).instantiateViewController(withIdentifier: "mailPopUpView") as! PopUpVC
                popUpVC.delegate = self
                self.addChild(popUpVC)
                popUpVC.view.frame = self.view.frame
                self.view.addSubview(popUpVC.view)
                popUpVC.didMove(toParent: self)
            }
//            self.images.append(image)
        } else {
            print("some error here")
        }
    }
}

extension ScannerVC: ScannerMailProtocol {
    func didRetakeMail(mail: Mail) {
        print("deleting mail = \(mail)")
    }
    
    func didSendMail(mail: Mail) {
        print("sent mail = \(mail)")
    }
    
    func editName(name: String) {
        print("mail sent is = \(name)")
    }
}
