//
//  FirebaseDatabase.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/7/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import FirebaseDatabase

public let firDatabase = Database.database().reference()
public let kSTUDENT: String = "student"
public let kNAME: String = "name"
public let kKEY: String = "key"

func saveNameToDatabase(name: String, completion: @escaping (_ error: String?) -> Void) {
    saveDataInDatabase(data: [kNAME: name]) { (error) in
        if let error = error {
            completion(error)
        }
        completion(nil) //success!
    }
}

func saveDataInDatabase(data: [String: Any], completion: @escaping (_ error: String?) -> Void) {
    let ref = firDatabase.child(kSTUDENT).childByAutoId()
    let id = ref.key //key is the autogenerated id
    var dataWithKey: [String: Any] = data
    dataWithKey[kKEY] = id //add the key id to the data
    ref.setValue(dataWithKey) { (error, ref) in
        if let error = error {
            saveDataLocally(key: id!, data: dataWithKey)
            completion(error.localizedDescription)
        }
    }
    print("Finished saving data \(data) in Firebase")
}

//save locally
func saveDataLocally(key: String, data: [String: Any]) {
    UserDefaults.standard.set(data, forKey: key)
    UserDefaults.standard.synchronize()
    print("Finished saving data \(data) locally...")
}
