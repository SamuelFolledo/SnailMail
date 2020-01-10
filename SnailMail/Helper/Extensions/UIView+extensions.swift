//
//  UIView+extensions.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/10/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

extension UIView {
    func enlargeThenShrinkAnimation() {
        self.isHidden = false
        UIView.animate(withDuration: 3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (finished) in
            UIView.animate(withDuration: 1, delay: 3, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
//                self.transform = CGAffineTransform.identity
                self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            }) { (finished) in
                self.isHidden = true
            }
        }
    }
}
