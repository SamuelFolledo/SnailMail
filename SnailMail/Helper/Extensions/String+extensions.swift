//
//  String+extensions.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/9/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation

extension String {
    func trimmedString() -> String { //method that removes string's left and right white spaces and new lines
        let newWord: String = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return newWord
    }
}
