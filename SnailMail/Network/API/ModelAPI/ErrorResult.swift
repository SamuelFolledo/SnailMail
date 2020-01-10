//
//  ErrorResult.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/10/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

enum ErrorResult: Error { //APPError enum which shows all possible errors
    case networkError(Error)
    case dataNotFound
    case jsonParsingError(Error)
    case invalidStatusCode(Int)
}
