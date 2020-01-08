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

//------------------------------------------------------------------

//MARK: Read Mail - take a Mail objectId and returns Mail
func fetchMailWith(mailId: String, completion: @escaping (_ mail: Mail?) -> Void) { //fetch with objectId!
    let ref = firDatabase.child(kMAIL).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: mailId)
    ref.observeSingleEvent(of: .value, with: { (snapshot) in // observe one value only. //.value = Any data changes at a location or, recursively, at any child node.
        if snapshot.exists() {
            let mailDictionary = ((snapshot.value as! NSDictionary).allValues as NSArray).firstObject! as! NSDictionary //convert snapshot to NSDictionary
            let mail: Mail = Mail(_dictionary: mailDictionary) //create our mail
            completion(mail) //pass our mail
        } else { //snapshot dont exist
            completion(nil) //we dont have a mail
        }
    }, withCancel: nil)
}

//MARK: Update Mail
func updateCurrentMail(mail: Mail, withValues values: [String : Any], withBlock: @escaping(_ success: Bool) -> Void) { //will pass a dictionary with an Any value, with running a background thread escaping, pass success type boolean, so we can return if user was updated successfully, no return here so void
    if UserDefaults.standard.object(forKey: mail.objectId) != nil {
        let mailObject = mailDictionaryFrom(mail: mail).mutableCopy() as! NSMutableDictionary //this makes the normal dictionary a mutable dictionary and specify it as NSMutableDictionary
        mailObject.setValuesForKeys(values) //pass our values parameter and to pass it to mailObject, now we can save our user to Firebase
        let ref = firDatabase.child(kMAIL).child(mail.objectId)
        ref.updateChildValues(values) { (error, ref) in
            if error != nil {
                withBlock(false)
                return
            }
            UserDefaults.standard.set(mailObject, forKey: mail.objectId) //update our user in our UserDefaults because save might create a new instance of it
            UserDefaults.standard.synchronize()
            withBlock(true)
            
        }
    }
}

//MARK: Mail Helper - take a Mail class and returns NSDictionary
func mailDictionaryFrom(mail: Mail) -> NSDictionary {
    let createdAt = Service.dateFormatter().string(from: mail.createdAt)
    let updatedAt = Service.dateFormatter().string(from: mail.updatedAt)
    return NSDictionary(
        objects: [mail.objectId, createdAt, updatedAt, mail.scannedText],
                        forKeys: [kOBJECTID as NSCopying, kCREATEDAT as NSCopying, kUPDATEDAT as NSCopying, kSCANNEDTEXT as NSCopying]) //how you create an NSDictionary
}
