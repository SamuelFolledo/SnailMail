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
    }
    
//MARK: IBActions
    
//MARK: Helpers
    
}

//MARK: Extensions


