//
//  ImageView+extensions.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/10/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

extension UIImageView {
//MARK: Storage - ImageView's extension
    func downloaded(fromURL url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) { //method that will download its own image from a url
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
                DispatchQueue.main.async() {
                    self.image = image
                }
            }.resume()
    }
    func downloaded(fromLink link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) { //method that will download its own image from a url
        guard let url = URL(string: link) else { return }
        downloaded(fromURL: url, contentMode: mode)
    }
}
