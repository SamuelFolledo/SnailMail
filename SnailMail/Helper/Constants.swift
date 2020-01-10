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
public let kNAME: String = "name"

//Service Constant
public let dateFormat = "yyyyMMddHHmmss"

//Image constant
let kBLANKIMAGE: UIImage = UIImage(named: "blankImage")!

//getMailName() algorithm
let streetSuffix: [String] = ["Alley", "ALY", "Annex", "ANX", "Arcade", "ARC", "Avenue", "AVE", "Bayou", "YU", "Beach", "BCH", "Bend", "BND", "Bluff", "BLF", "Bottom", "BTM", "Boulevard", "BLVD", "Branch", "BR", "Bridge", "BRG", "Brook", "BRK", "Burg", "BG", "Bypass", "BYP", "Camp", "CP", "Canyon", "CYN", "Cape", "CPE", "Causeway", "CSWY", "Center", "CTR", "Circle", "CIR", "Cliffs", "CLFS", "Club", "CLB", "Corner", "COR", "Corners", "CORS", "Course", "CRSE", "Court", "CT", "Courts", "CTS", "Cove", "CV", "Creek", "CRK", "Crescent", "CRES", "Crossing", "XING", "Dale", "DL", "Dam", "DM", "Divide", "DV", "Drive", "DR", "Estates", "EST", "Expressway", "EXPY", "Extension", "EXT", "Fall", "FALL", "Falls", "FLS", "Ferry", "FRY", "Field", "FLD", "Fields", "FLDS", "Flats", "FLT", "Ford", "FOR", "Forest", "FRST", "Forge", "FGR", "Fork", "FORK", "Forks", "FRKS", "Fort", "FT", "Freeway", "FWY", "Gardens", "GDNS", "Gateway", "GTWY", "Glen", "GLN", "Green", "GN", "Grove", "GRV", "Harbor", "HBR", "Haven", "HVN", "Heights", "HTS", "Highway", "HWY", "Hill", "HL", "Hills", "HLS", "Hollow", "HOLW", "Inlet", "INLT", "Island", "IS", "Islands", "ISS", "Isle", "ISLE", "Junction", "JCT", "Key", "CY", "Knolls", "KNLS", "Lake", "LK", "Lakes", "LKS", "Landing", "LNDG", "Lane", "LN", "Light", "LGT", "Loaf", "LF", "Locks", "LCKS", "Lodge", "LDG", "Loop", "LOOP", "Mall", "MALL", "Manor", "MNR", "Meadows", "MDWS", "Mill", "ML", "Mills", "MLS", "Mission", "MSN", "Mount", "MT", "Mountain", "MTN", "Neck", "NCK", "Orchard", "ORCH", "Oval", "OVAL", "Park", "PARK", "Parkway", "PKY", "Pass", "PASS", "Path", "PATH", "Pike", "PIKE", "Pines", "PNES", "Place", "PL", "Plain", "PLN", "Plains", "PLNS", "Plaza", "PLZ", "Point", "PT", "Port", "PRT", "Prairie", "PR", "Radial", "RADL", "Ranch", "RNCH", "Rapids", "RPDS", "Rest", "RST", "Ridge", "RDG", "River", "RIV", "Road", "RD", "Row", "ROW", "Run", "RUN", "Shoal", "SHL", "Shoals", "SHLS", "Shore", "SHR", "Shores", "SHRS", "Spring", "SPG", "Springs", "SPGS", "Spur", "SPUR", "Square", "SQ", "Station", "STA", "Stravenues", "STRA", "Stream", "STRM", "Street", "ST", "Summit", "SMT", "Terrace", "TER", "Trace", "TRCE", "Track", "TRAK", "Trail", "TRL", "Trailer", "TRLR", "Tunnel", "TUNL", "Turnpike", "TPKE", "Union", "UN", "Valley", "VLY", "Viaduct", "VIA", "View", "VW", "Village", "VLG", "Ville", "VL", "Vista", "VIS", "Walk", "WALK", "Way", "WAY", "Wells", "WLS"]
