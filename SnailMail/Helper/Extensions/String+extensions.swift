//
//  String+extensions.swift
//  SnailMail
//
//  Created by Macbook Pro 15 on 1/9/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation

extension String {
    var isAllNumbers: Bool { //regex to see if a word/string are all numbers
        let charCount = self.count
        print("\(charCount) = \(self)")
        let integerRegEx  = "[0-9]{\(charCount),}"
        let testCase = NSPredicate(format:"SELF MATCHES %@", integerRegEx)
        let containsNumber = testCase.evaluate(with: self)
        return containsNumber
    }
    var lines: [String] { //turns a multi-line string into an array of each line https://www.hackingwithswift.com/example-code/strings/how-to-get-the-lines-in-a-string-as-an-array
        return self.components(separatedBy: "\n")
    }
    var byWords: [String] { //turns string to an array of strings https://exceptionshub.com/extract-last-word-in-string-with-swift.html
        var byWords:[String] = []
        enumerateSubstrings(in: startIndex..<endIndex, options: .byWords) { (word, range1, range2, shouldStop) in //Enumerates the substrings of the specified type in the specified range of the string.
            guard let word = word else { return }
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
    
    var asStorageUrl: String { //I realized this was not needed to delete an image from Storage
        var imageUrl: String = ""
        if let beginningRange = self.range(of: "/b/") { //characters after /b/ will have the link to the imageURL PLUS extra characters which still needs to be removed
            let imageUrlWithExtras = self[beginningRange.upperBound...]
            let imageUrlArray: [String] = imageUrlWithExtras.components(separatedBy: "?alt") //splits the string by "?alt"
            let imageURL: String = imageUrlArray[0] //string before ?alt contains the imageUrl
            imageUrl = "gs://\(imageURL)"
            imageUrl = imageUrl.replacingOccurrences(of: "/o", with: "") //"/o" in imageUrl also needs to be removed
            imageUrl = imageUrl.replacingOccurrences(of: "%2F", with: "/") //"/" gets replaced to %2F when you store them in the database, thus we need to reverse it
        }
        return imageUrl
    }
    
    func trimmedString() -> String { //method that removes string's left and right white spaces and new lines
        let newWord: String = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return newWord
    }
}
