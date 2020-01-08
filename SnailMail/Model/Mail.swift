//
//  Mail.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/7/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation
import Firebase

class Mail {
    let objectId: String
    let createdAt: Date
    let updatedAt: Date
    let scannedText: String
    
    init(_objectId: String, _createdAt: Date, _updatedAt: Date, _scannedText: String) {
        objectId = _objectId
        createdAt = _createdAt
        updatedAt = _updatedAt
        scannedText = _scannedText
    }
    
    init(_dictionary: NSDictionary) { //in order to save something to our Firebase, we need to convert it to an NSDictionary which is a type JSON
        objectId = _dictionary[kOBJECTID] as! String //crash if mail has no objectId
        if let updated = _dictionary[kUPDATEDAT] {
            updatedAt = Service.dateFormatter().date(from: updated as! String)!
        } else { updatedAt = Date() }
        if let created = _dictionary[kCREATEDAT] {
            createdAt = Service.dateFormatter().date(from: created as! String)! //takes a string and returns a date
        } else { //if there is no value, dont crash our app
            createdAt = Date() //just create from current date
        }
        if let scannedText = _dictionary[kSCANNEDTEXT] as? String {
            self.scannedText = scannedText
        } else {
            scannedText = ""
        }
    }
} //end of class
