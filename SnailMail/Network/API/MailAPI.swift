//
//  MailAPI.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/10/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation

func dataRequest<T: Codable>(with url: String, objectType: T.Type, completion: @escaping (Result<T>) -> Void) { //dataRequest which sends request to given URL and convert to Decodable Object https://stackoverflow.com/questions/24016142/how-to-make-an-http-request-in-swift
    let dataURL = URL(string: url)! //create the url with NSURL
    let session = URLSession.shared //create the session object
    let request = URLRequest(url: dataURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60) //now create the URLRequest object using the url object
    let task = session.dataTask(with: request, completionHandler: { data, response, error in //create dataTask using the session object to send data to the server
        if let error = error {
            completion(Result.failure(APIError.networkError(error)))
            return
        }
        guard let data = data else {
            completion(Result.failure(APIError.dataNotFound))
            return
        }
        do {
            //create decodable object from data
            let decodedObject = try JSONDecoder().decode(objectType.self, from: data)
            completion(Result.success(decodedObject))
        } catch let error {
            completion(Result.failure(APIError.jsonParsingError(error as! DecodingError)))
        }
    })
    task.resume()
}
