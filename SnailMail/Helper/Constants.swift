//
//  Constants.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/7/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation
import FirebaseDatabase

public let firDatabase = Database.database().reference()

public let kMAIL: String = "mail"
//Mail Properties
public let kOBJECTID: String = "objectId"
public let kCREATEDAT: String = "createdAt"
public let kUPDATEDAT: String = "updatedAt"
public let kSCANNEDTEXT: String = "scannedText"

//Service Constant
public let dateFormat = "yyyyMMddHHmmss"
