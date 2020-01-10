//
//  String+extensions.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/9/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation

extension String {
    var lines: [String] { //turns a multi-line string into an array of each line https://www.hackingwithswift.com/example-code/strings/how-to-get-the-lines-in-a-string-as-an-array
        return self.components(separatedBy: "\n")
    }
    
    var byWords: [String] { //turns string to an array of strings
        var byWords:[String] = []
        enumerateSubstrings(in: startIndex..<endIndex, options: .byWords) {
            guard let word = $0 else { return }
            print($1,$2,$3)
            byWords.append(word)
        }
        return byWords
    }
    func firstWords(_ max: Int) -> [String] {
        return Array(byWords.prefix(max))
    }
    var firstWord: String {
        return byWords.first ?? ""
    }
    func lastWords(_ max: Int) -> [String] {
        return Array(byWords.suffix(max))
    }
    var lastWord: String {
        return byWords.last ?? ""
    }
    
    func trimmedString() -> String { //method that removes string's left and right white spaces and new lines
        let newWord: String = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return newWord
    }
}
