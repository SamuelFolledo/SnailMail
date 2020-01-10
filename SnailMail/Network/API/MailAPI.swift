//
//  MailAPI.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/10/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation

func send(completion: @escaping (_ result: String?, _ error: String?) -> Void) { //sends HttpRequest GET method to trigger SlackBot message
    let nameArr: [String] = name.byWords
    let nameQueryString: String = "\(nameArr.first ?? "")%20\(nameArr.last ?? "")"
    let url: URL = URL(string: "https://ms-snailmail.herokuapp.com/api/\(nameQueryString)")!
    let task: URLSessionDataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            completion(nil, error.localizedDescription)
        }
        guard let data = data else { return }
        print(String(data: data, encoding: .utf8)!) //data is just bytes, but with encoding is the JSON
        completion((String(data: data, encoding: .utf8)!), nil)
    }
    task.resume()
}

func dataRequest<T: Decodable>(objectType: T.Type, completion: @escaping (Result<T>) -> Void) { //dataRequest which sends request to given URL and convert to Decodable Object

    //create the url with NSURL
    let dataURL = URL(string: url)! //change the url

    //create the session object
    let session = URLSession.shared

    //now create the URLRequest object using the url object
    let request = URLRequest(url: dataURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)

    //create dataTask using the session object to send data to the server
    let task = session.dataTask(with: request, completionHandler: { data, response, error in

        guard error == nil else {
            completion(Result.failure(AppError.networkError(error!)))
            return
        }

        guard let data = data else {
            completion(Result.failure(APPError.dataNotFound))
            return
        }

        do {
            //create decodable object from data
            let decodedObject = try JSONDecoder().decode(objectType.self, from: data)
            completion(Result.success(decodedObject))
        } catch let error {
            completion(Result.failure(APPError.jsonParsingError(error as! DecodingError)))
        }
    })

    task.resume()
}
