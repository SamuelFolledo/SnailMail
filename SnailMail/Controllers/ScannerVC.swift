//
//  ScannerVC.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/8/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import SceneKit //for scannerView
import AVFoundation //for camera

class ScannerVC: UIViewController {
//MARK: Properties
    var cameraSession: AVCaptureSession! //to connect a video input, like a camera
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer! //preview layer
    var cameraImageOutput: AVCapturePhotoOutput!
    let scene = SCNScene() //scene for scannerView
//    let cameraNode = SCNNode()
//    let targetNode = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
    var mails: [String:Mail] = [:]
    var images: [UIImage] = []
    
//MARK: IBOutlets
    @IBOutlet weak var scannerView: SCNView!
    @IBOutlet weak var takePicButton: UIButton!
    
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
    @IBAction func mailsButtonTapped(_ sender: Any) {
        print("All mails coming soon")
    }
    
    @IBAction func takePicButtonTapped(_ sender: Any) {
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
            print(UIImage(data: dataImage)?.size as Any)

            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImage.Orientation.right)
            self.images.append(image)
        } else {
            print("some error here")
        }
    }
}
