//
//  PopUpVC.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/8/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

class PopUpVC: UIViewController {
//MARK: Properties
    
//MARK: IBOutlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var retakeButton: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
    
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
    @IBAction func sendButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func retakeButtonTapped(_ sender: Any) {
        
    }
    
//MARK: Helpers
    
}

//MARK: Extensions


