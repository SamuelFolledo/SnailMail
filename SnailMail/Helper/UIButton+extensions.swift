//
//  UIButton+extensions.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/8/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

extension UIButton {
    func isPopupButton() {
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.cornerRadius = self.frame.height / 5
        self.clipsToBounds = true
    }
}
