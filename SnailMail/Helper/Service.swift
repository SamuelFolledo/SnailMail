//
//  Service.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/7/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

class Service {    
//presentAlert
    static func presentAlert(on: UIViewController, title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            alertVC.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(okAction)
        on.present(alertVC, animated: true, completion: nil)
    }
    
    static func alertWithActions(on: UIViewController, actions: [UIAlertAction], title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions {
            alertVC.addAction(action)
        }
        on.present(alertVC, animated: true, completion: nil)
    }
    
    static func dateFormatter() -> DateFormatter { // DateFormatter = A formatter that converts between dates and their textual representations.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat //dateFormat = "yyyyMMddHHmmss"
        return dateFormatter
    }

    static func imageFromData(pictureData: String, withBlock: (_ image: UIImage?) -> Void ) { //string to image method for imageURL
        var image: UIImage? //container for our image
        let decodedData = NSData(base64Encoded: pictureData, options: NSData.Base64DecodingOptions(rawValue: 0)) //this will decode our string to an NSData
        image = UIImage(data: decodedData! as Data) //assign our image to our decodedData
        withBlock(image)
    }
}
