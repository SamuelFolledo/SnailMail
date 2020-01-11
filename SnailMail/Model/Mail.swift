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
    var name: String
    let image: UIImage
    
    init(_objectId: String, _createdAt: Date, _updatedAt: Date, _scannedText: String, _name: String = "", _image: UIImage) {
        objectId = _objectId
        createdAt = _createdAt
        updatedAt = _updatedAt
        scannedText = _scannedText
        name = _name
        image = _image
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
        if let name = _dictionary[kNAME] as? String {
            self.name = name
        } else {
            self.name = ""
        }
        if let image = _dictionary[kIMAGE] as? UIImage {
            self.image = image
        } else {
            self.image = kBLANKIMAGE
        }
    }
    
    func sendAndGetData(completion: @escaping (_ data: [String: Any]?, _ error: Error?) -> Void) { //sends HttpRequest GET method to trigger SlackBot message
        let nameArr: [String] = name.byWords
        let nameQueryString: String = "\(nameArr.first ?? "")%20\(nameArr.last ?? "")"
        let url: URL = URL(string: "https://ms-snailmail.herokuapp.com/api/\(nameQueryString)")!
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, error as Error)
            }
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(json, nil)
                }
            } catch {
                completion(nil, error)
            }
//            completion((data: data, encoding: .utf8.rawValue), nil)
        }
        task.resume()
    }
} //end of class
