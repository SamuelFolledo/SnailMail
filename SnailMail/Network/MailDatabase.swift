//
//  MailDatabase.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/7/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import FirebaseStorage

//MARK: Create Mail - Firebase
func saveMail(values: [String: Any], completion: @escaping (_ mail: Mail?, _ error: String?) -> Void) {
    saveDataInDatabase(data: values) { (mailId, error) in
        if let error = error {
            completion(nil, error)
        }
        let mailDic: NSDictionary = UserDefaults.standard.dictionary(forKey: mailId)! as NSDictionary
        let mail = Mail(_dictionary: mailDic)
        completion(mail, nil) //success!
    }
}

//MARK: Save Mail Helper - Save in Database
func saveDataInDatabase(data: [String: Any], completion: @escaping (_ mailId: String, _ error: String?) -> Void) {
    let ref = firDatabase.child(kMAIL).childByAutoId()
    let id = ref.key //key is the autogenerated id
    var dataWithKey: [String: Any] = data
    dataWithKey[kOBJECTID] = id //add the key id to the data
    ref.setValue(dataWithKey) { (error, ref) in
        if let error = error {
            completion(id!, error.localizedDescription)
        }
        saveDataLocally(key: id!, data: dataWithKey)
        completion(id!, nil)
    }
}

//MARK: Save Mail Helper - save locally
func saveDataLocally(key: String, data: [String: Any]) {
    UserDefaults.standard.set(data, forKey: key)
    UserDefaults.standard.synchronize()
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
func updateMail(mail: Mail, withBlock: @escaping(_ success: Bool) -> Void) { //will pass a dictionary with an Any value, with running a background thread escaping, pass success type boolean, so we can return if user was updated successfully, no return here so void
    if UserDefaults.standard.object(forKey: mail.objectId) != nil {
        guard let mailDictionary: [String: Any] = mailToDictionary(mail: mail) as? [String : Any] else { print("update mail could not convert to dictionary"); return }
        let ref = firDatabase.child(kMAIL).child(mail.objectId)
        ref.updateChildValues(mailDictionary) { (error, ref) in
            if error != nil {
                withBlock(false)
                return
            }
            UserDefaults.standard.set(mailDictionary, forKey: mail.objectId) //update our user in our UserDefaults because save might create a new instance of it
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
                UserDefaults.standard.removeObject(forKey: objectId) //update our user in our UserDefaults because save might create a new instance of it
                UserDefaults.standard.synchronize()
                completion(nil)
            }
        }
    }, withCancel: nil)
}

func deleteAllMails(mails: [Mail], completion: @escaping(_ error: Error?) -> Void) { //delete all mails
    let mailRef = firDatabase.child(kMAIL)
    mailRef.removeValue { (error, ref) in
        if let error = error {
            completion(error)
        }
        for mail in mails { //delete them locally as well
            UserDefaults.standard.removeObject(forKey: mail.objectId)
            UserDefaults.standard.synchronize()
        }
        completion(nil)
    }
}

//MARK: Mail Helper - take a Mail class and returns NSDictionary
func mailToDictionary(mail: Mail) -> NSDictionary {
    let createdAt = Service.dateFormatter().string(from: mail.createdAt)
    let updatedAt = Service.dateFormatter().string(from: mail.updatedAt)
    return NSDictionary(
        objects: [mail.objectId, createdAt, updatedAt, mail.scannedText, mail.name, mail.imageUrl],
                        forKeys: [kOBJECTID as NSCopying, kCREATEDAT as NSCopying, kUPDATEDAT as NSCopying, kSCANNEDTEXT as NSCopying, kNAME as NSCopying, kIMAGEURL as NSCopying]) //how you create an NSDictionary
}

//MARK: Storage for Mail Images
func getImageURL(imageView: UIImageView, compeltion: @escaping(_ imageURL: String?, _ error: String?) -> Void) { //method that grabs an image from a UIImageView, compress it as JPEG, store in Storage, and returning the URL if no error
    let imageName = NSUUID().uuidString
    let imageReference = Storage.storage().reference().child("avatar_images").child("0000\(imageName).png")
    if let avatarImage = imageView.image, let uploadData = avatarImage.jpegData(compressionQuality: 0.35) { //compress the image to be uploaded
        imageReference.putData(uploadData, metadata: nil, completion: { (metadata, error) in //putData = Asynchronously uploads data to the reference
            if let error = error {
                compeltion(nil, error.localizedDescription)
            } else { //if no error, get the url
                imageReference.downloadURL(completion: { (imageUrl, error) in
                    if let error = error {
                        compeltion(nil, error.localizedDescription)
                    } else { //no error on downloading metadata URL
                        guard let url = imageUrl?.absoluteString else { return }
                        compeltion(url, nil)
                    }
                })
            }
        })
    }
}

func getImageURL(image: UIImage, compeltion: @escaping(_ imageURL: String?, _ error: String?) -> Void) { //method that takes an image, compress it as JPEG, store in Storage, and returning the URL if no error
    let imageName = NSUUID().uuidString
    let imageReference = Storage.storage().reference().child("avatar_images").child("0000\(imageName).png")
    if let uploadData = image.jpegData(compressionQuality: 0.35) { //compress the image to be uploaded
        imageReference.putData(uploadData, metadata: nil, completion: { (metadata, error) in //putData = Asynchronously uploads data to the reference
            if let error = error {
                compeltion(nil, error.localizedDescription)
            } else { //if no error, get the url
                imageReference.downloadURL(completion: { (imageUrl, error) in
                    if let error = error {
                        compeltion(nil, error.localizedDescription)
                    } else { //no error on downloading metadata URL
                        guard let url = imageUrl?.absoluteString else { return }
                        compeltion(url, nil)
                    }
                })
            }
        })
    }
}
