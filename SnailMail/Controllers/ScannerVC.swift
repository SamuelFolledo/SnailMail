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
    var cameraSession: AVCaptureSession? //to connect a video input, like a camera
    var cameraLayer: AVCaptureVideoPreviewLayer? //preview layer
    let scene = SCNScene() //scene for scannerView
//    let cameraNode = SCNNode()
//    let targetNode = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
    let stillImageOutput = AVCaptureStillImageOutput()
    
//MARK: IBOutlets
    @IBOutlet weak var scannerView: SCNView!
    @IBOutlet weak var takePicButton: UIButton!
    
//MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
//MARK: Private Methods
    fileprivate func setupViews() {
        view.backgroundColor = .black
        loadCamera()
        self.cameraSession?.startRunning() //start grabbing frames from the camera, which are displayed automatically on the preview layer
        scannerView.scene = scene //creates an empty scene and adds a camera
        //cameraNode.camera = SCNCamera()
        //cameraNode.position = SCNVector3(x:0, y:0, z:10)
        //scene.rootNode.addChildNode(cameraNode)
    }
    
    fileprivate func createCaptureSession() -> (session: AVCaptureSession?, error: NSError?) { //to have the input in the camera
        var error: NSError?
        var captureSession: AVCaptureSession?
        let backVideoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) //get the rear camera of the device
        if backVideoDevice != nil { //if camera exists, get its input
            var videoInput: AVCaptureDeviceInput! //A capture input that provides media from a capture device to a capture session.
            do {
                videoInput = try AVCaptureDeviceInput(device: backVideoDevice!)
            } catch let error1 as NSError {
                error = error1
                videoInput = nil
                print("No rear camera found")
            }
            if error == nil { //if no error, create an instance of AVCaptureSession
                captureSession = AVCaptureSession()
                //add the video device as an input
                if captureSession!.canAddInput(videoInput) {
                    captureSession!.addInput(videoInput)
                } else {
                    error = NSError(domain: "", code: 1, userInfo: ["description":"Error adding video input."])
                }
            } else {
                error = NSError(domain: "", code: 1, userInfo: ["description": "Error creating capture device input."])
            }
        } else { //if backVideo is nil
            error = NSError(domain: "", code: 2, userInfo: ["description": "Back video device not found."])
        }
        return (session: captureSession, error: error) //return a tuple that contains either the captureSession or an error
    } //end of createCaptureSession
    
    fileprivate func loadCamera() {
        let captureSessionResult = createCaptureSession() //init captureSession
        guard captureSessionResult.error == nil, let session = captureSessionResult.session else { //if error or captureSession is nil, return
            print("Error creating capture session")
            return
        }
        self.cameraSession = session //if everything is fine, store capture session in cameraSession
        let cameraLayer = AVCaptureVideoPreviewLayer(session: self.cameraSession!) //creates a video preview layer; if successful, it sets videoGravity and sets the frame of the layer to the views bounds (fullscreen view)..... AVCaptureVideoPreviewLayer is a core animation layer that can display a video as it is being captured
        cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(cameraLayer, at: 0) //p.7 #5 add the layer as a sublayer and store it in cameraLayer
        self.cameraLayer = cameraLayer
    }
    
//MARK: IBActions
    @IBAction func mailsButtonTapped(_ sender: Any) {
        print("All mails coming soon")
    }
    
    @IBAction func takePicButtonTapped(_ sender: Any) {
        if let videoConnection = stillImageOutput.connection(with: .video) {
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection) { (imageDataSampleBuffer, error) in
                if let error = error {
                    Service.presentAlert(on: self, title: "Error Taking Picture", message: error.localizedDescription)
                    return
                }
                if imageDataSampleBuffer != nil {
                    let ciImage: CIImage = CIImage(cvPixelBuffer: imageDataSampleBuffer as! CVPixelBuffer)
                    let image: UIImage = self.convert(cmage: ciImage) //convert ciImage to a UIImage
//                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil) //to save to photosAlbum
                }
            }
        }
    }
    
//MARK: Helpers
    fileprivate func convert(cmage:CIImage) -> UIImage { // Convert CIImage to CGImage
         let context:CIContext = CIContext.init(options: nil)
         let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
         let image:UIImage = UIImage.init(cgImage: cgImage)
         return image
    }
}

//MARK: Extensions


