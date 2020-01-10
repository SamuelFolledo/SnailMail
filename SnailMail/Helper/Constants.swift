//
//  Constants.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/7/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

public let firDatabase = Database.database().reference()

public let kMAIL: String = "mail"
//Mail Properties
public let kOBJECTID: String = "objectId"
public let kCREATEDAT: String = "createdAt"
public let kUPDATEDAT: String = "updatedAt"
public let kSCANNEDTEXT: String = "scannedText"
public let kNAME: String = "name"

//Service Constant
public let dateFormat = "yyyyMMddHHmmss"

//Image constant
let kBLANKIMAGE: UIImage = UIImage(named: "blankImage")!
let kCORRECTIMAGE: UIImage = UIImage(named: "correct")!
let kWRONGIMAGE: UIImage = UIImage(named: "wrong")!

//getMailName() algorithm
//streetSuffix.count = 286
let streetSuffix: [String] = ["alley", "aly", "annex", "anx", "arcade", "arc", "avenue", "ave", "bayou", "yu", "beach", "bch", "bend", "bnd", "bluff", "blf", "bottom", "btm", "boulevard", "blvd", "branch", "br", "bridge", "brg", "brook", "brk", "burg", "bg", "bypass", "byp", "camp", "cp", "canyon", "cyn", "cape", "cpe", "causeway", "cswy", "center", "ctr", "circle", "cir", "cliffs", "clfs", "club", "clb", "corner", "cor", "corners", "cors", "course", "crse", "court", "ct", "courts", "cts", "cove", "cv", "creek", "crk", "crescent", "cres", "crossing", "xing", "dale", "dl", "dam", "dm", "divide", "dv", "drive", "dr", "estates", "est", "expressway", "expy", "extension", "ext", "fall", "fall", "falls", "fls", "ferry", "fry", "field", "fld", "fields", "flds", "flats", "flt", "ford", "for", "forest", "frst", "forge", "fgr", "fork", "fork", "forks", "frks", "fort", "ft", "freeway", "fwy", "gardens", "gdns", "gateway", "gtwy", "glen", "gln", "green", "gn", "grove", "grv", "harbor", "hbr", "haven", "hvn", "heights", "hts", "highway", "hwy", "hill", "hl", "hills", "hls", "hollow", "holw", "inlet", "inlt", "island", "is", "islands", "iss", "isle", "isle", "junction", "jct", "key", "cy", "knolls", "knls", "lake", "lk", "lakes", "lks", "landing", "lndg", "lane", "ln", "light", "lgt", "loaf", "lf", "locks", "lcks", "lodge", "ldg", "loop", "loop", "mall", "mall", "manor", "mnr", "meadows", "mdws", "mill", "ml", "mills", "mls", "mission", "msn", "mount", "mt", "mountain", "mtn", "neck", "nck", "orchard", "orch", "oval", "oval", "park", "park", "parkway", "pky", "pass", "pass", "path", "path", "pike", "pike", "pines", "pnes", "place", "pl", "plain", "pln", "plains", "plns", "plaza", "plz", "point", "pt", "port", "prt", "prairie", "pr", "radial", "radl", "ranch", "rnch", "rapids", "rpds", "rest", "rst", "ridge", "rdg", "river", "riv", "road", "rd", "row", "row", "run", "run", "shoal", "shl", "shoals", "shls", "shore", "shr", "shores", "shrs", "spring", "spg", "springs", "spgs", "spur", "spur", "square", "sq", "station", "sta", "stravenues", "stra", "stream", "strm", "street", "st", "summit", "smt", "terrace", "ter", "trace", "trce", "track", "trak", "trail", "trl", "trailer", "trlr", "tunnel", "tunl", "turnpike", "tpke", "union", "un", "valley", "vly", "viaduct", "via", "view", "vw", "village", "vlg", "ville", "vl", "vista", "vis", "walk", "walk", "way", "way", "wells", "wls"]
let illegalNames: [String] = ["", "deliver", "delivery", "fedex", "for", "address", "ship", "ship to", "to", "ups", "usps"]

//Heroku API Data Keys
let kERROR: String = "error"
let kNOTE: String = "note"
let kSLACKID: String = "slackID"
let kSUCCESS: String = "success"

//for filtering
let allAlphaNum: String = "qwertyuiopasdfghjklzxcvbnm1234567890"
