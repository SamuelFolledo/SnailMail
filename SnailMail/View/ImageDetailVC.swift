//
//  ImageDetailVC.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/9/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

class ImageDetailVC: UIViewController {
//MARK: Properties
    var image: UIImage!
//MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
//MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
//MARK: Private Methods
    fileprivate func setupViews() {
        view.backgroundColor = .clear
        imageView.image = image
    }
    
//MARK: IBActions
    
//MARK: Helpers
    
}

//MARK: Extensions


