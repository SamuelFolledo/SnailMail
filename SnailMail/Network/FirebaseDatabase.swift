//
//  FirebaseDatabase.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/7/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//
import Foundation

//MARK: Create Mail
func saveNameToDatabase(text: String, completion: @escaping (_ error: String?) -> Void) {
    saveDataInDatabase(data: [kSCANNEDTEXT: text]) { (error) in
        if let error = error {
            completion(error)
        }
        completion(nil) //success!
    }
}


//MARK: Save Mail Helper - Save in Database
func saveDataInDatabase(data: [String: Any], completion: @escaping (_ error: String?) -> Void) {
    let ref = firDatabase.child(kMAIL).childByAutoId()
    let id = ref.key //key is the autogenerated id
    var dataWithKey: [String: Any] = data
    dataWithKey[kOBJECTID] = id //add the key id to the data
    ref.setValue(dataWithKey) { (error, ref) in
        if let error = error {
            saveDataLocally(key: id!, data: dataWithKey)
            completion(error.localizedDescription)
        }
    }
//    print("Finished saving data \(data) in Firebase")
}

//MARK: Save Mail Helper - save locally
func saveDataLocally(key: String, data: [String: Any]) {
    UserDefaults.standard.set(data, forKey: key)
    UserDefaults.standard.synchronize()
//    print("Finished saving data \(data) locally...")
}

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

//MARK: Mail Delete
func deleteMail(objectId: String, completion: @escaping(_ error: Error?) -> Void) { //delete the current user
    let mailRef = firDatabase.child(kMAIL).queryOrdered(byChild: kOBJECTID).queryEqual(toValue: objectId).queryLimited(toFirst: 1)
    mailRef.observeSingleEvent(of: .value, with: { (snapshot) in //delete from Database
        if snapshot.exists() { //snapshot has uid and all its user's values
            firDatabase.child(kMAIL).child(objectId).removeValue { (error, ref) in
                if let error = error {
                    completion(error)
                }
                completion(nil)
            }
        }
    }, withCancel: nil)
}

//MARK: Mail Helper - take a Mail class and returns NSDictionary
func mailDictionaryFrom(mail: Mail) -> NSDictionary {
    let createdAt = Service.dateFormatter().string(from: mail.createdAt)
    let updatedAt = Service.dateFormatter().string(from: mail.updatedAt)
    return NSDictionary(
        objects: [mail.objectId, createdAt, updatedAt, mail.scannedText],
                        forKeys: [kOBJECTID as NSCopying, kCREATEDAT as NSCopying, kUPDATEDAT as NSCopying, kSCANNEDTEXT as NSCopying]) //how you create an NSDictionary
}
