//
//  MailOwner.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/10/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

enum Result<T> { //Result enum to show success or failure
    case success(T)
    case failure(APIError)
}

struct MailOwner: Codable {
    let error: String?
    let name: String?
    let note: String?
    let slackID: String?
    let success: String
}
