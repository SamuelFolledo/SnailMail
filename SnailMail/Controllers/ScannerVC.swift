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
    let scene = SCNScene()
    let cameraNode = SCNNode()
    let targetNode = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0))
    
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
        
        loadCamera() //p.7
        self.cameraSession?.startRunning() //p.7 start grabbing frames from the camera, which are displayed automatically on the preview layer
        
//        self.locationManager.delegate = self //p.9 #1 sets ViewController a the delegate for the CLLocationManager
//        self.locationManager.startUpdatingHeading() //p.9 #2 after this call, you will have the heading information. By default, the delegate is informed when the heading changes more than 1 degree
        
        scannerView.scene = scene //p.9 #3 creates an empty scene and adds a camera
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x:0, y:0, z:10)
        scene.rootNode.addChildNode(cameraNode)
        
    }
    
    fileprivate func createCaptureSession() -> (session: AVCaptureSession?, error: NSError?) { //p.5 to have the input in the camera
        //#1 vars for return value
        var error: NSError?
        var captureSession: AVCaptureSession?
        let backVideoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) //#2 p.6 get the rear camera of the device
        
        if backVideoDevice != nil { //#3 if camera exists, get its input
            var videoInput: AVCaptureDeviceInput!
            do {
                videoInput = try AVCaptureDeviceInput(device: backVideoDevice!)
            } catch let error1 as NSError {
                error = error1
                videoInput = nil
                print("No rear camera found")
            }
            
            //#4 p.6 create an instance of AVCaptureSession
            if error == nil {
                captureSession = AVCaptureSession()
                
                //#5 p.6 add the video device as an input
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
        
        return (session: captureSession, error: error) //#6 p.6 return a tuple that contains either the captureSession or an error
    } //end of createCaptureSession
    
    fileprivate func loadCamera() {
        let captureSessionResult = createCaptureSession() //p.7 #1 call captureSession
        guard captureSessionResult.error == nil, let session = captureSessionResult.session else { //p.7 #2 if error or captureSession is nil, return
            print("Error creating capture session")
            return
        }
        
        self.cameraSession = session //p.7 #3 if everything is fine, store capture session in cameraSession
        
        //if let cameraLayer = AVCaptureVideoPreviewLayer(session: self.cameraSession!) {
        let cameraLayer = AVCaptureVideoPreviewLayer(session: self.cameraSession!) //p.7 #4 creates a video preview layer; if successful, it sets videoGravity and sets the frame of the layer to the views bounds (fullscreen view)..... AVCaptureVideoPreviewLayer is a core animation layer that can display a video as it is being captured
        cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(cameraLayer, at: 0) //p.7 #5 add the layer as a sublayer and store it in cameraLayer
        self.cameraLayer = cameraLayer
        
    }
    
//MARK: IBActions
    
//MARK: Helpers
    
}

//MARK: Extensions


