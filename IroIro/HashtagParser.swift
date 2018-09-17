//
//  HashtagParser.swift
//  NoteTest
//
//  Created by Ezhik on 6/5/17.
//  Copyright © 2017 DeAnza. All rights reserved.
//

import UIKit

class HashtagParser: NSObject {

    struct doubleRange {
        var nsRange : NSRange
        var swiftRange : Range<String.Index>
        var tagRange : Range<String.Index>
    }

    static func getRanges(_ inputString: String) -> [doubleRange] {
        
        let hashtagRegex = try! NSRegularExpression(pattern: hashtagRegexSyntax, options: [.caseInsensitive])
        var ranges : [doubleRange] = []
        
        let matches = hashtagRegex.matches(in: inputString, options: [], range: NSRange(location: 0, length: inputString.characters.count))
        
        for match in matches {
            //for n in 0..<match.numberOfRanges {
            let range = match.range(at: 0)//n)
            
            let swiftRange = inputString.index(inputString.startIndex, offsetBy: range.location) ..< inputString.index(inputString.startIndex, offsetBy: range.location + range.length)
            let nsRange = NSMakeRange(range.location, range.length)
            
            let tagRange = inputString.index(inputString.startIndex, offsetBy: range.location + 1) ..< inputString.index(inputString.startIndex, offsetBy: range.location + range.length)
            
            ranges.append(doubleRange(nsRange: nsRange, swiftRange: swiftRange, tagRange: tagRange))
            
            //print(testString.substring(with: NSRange(location: range.location, length: range.length)))//r))
            //}
        }
        
        return ranges
    }
    
    
        static let hashtagRegexSyntax = "(#|＃)([a-z0-9_\u{00c0}-\u{00d6}\u{00d8}-\u{00f6}\u{00f8}-\u{00ff}\u{0100}-\u{024f}\u{0253}-\u{0254}\u{0256}-\u{0257}\u{0300}-\u{036f}\u{1e00}-\u{1eff}\u{0400}-\u{04ff}\u{0500}-\u{0527}\u{2de0}-\u{2dff}\u{a640}-\u{a69f}\u{0591}-\u{05bf}\u{05c1}-\u{05c2}\u{05c4}-\u{05c5}\u{05d0}-\u{05ea}\u{05f0}-\u{05f4}\u{fb12}-\u{fb28}\u{fb2a}-\u{fb36}\u{fb38}-\u{fb3c}\u{fb40}-\u{fb41}\u{fb43}-\u{fb44}\u{fb46}-\u{fb4f}\u{0610}-\u{061a}\u{0620}-\u{065f}\u{066e}-\u{06d3}\u{06d5}-\u{06dc}\u{06de}-\u{06e8}\u{06ea}-\u{06ef}\u{06fa}-\u{06fc}\u{0750}-\u{077f}\u{08a2}-\u{08ac}\u{08e4}-\u{08fe}\u{fb50}-\u{fbb1}\u{fbd3}-\u{fd3d}\u{fd50}-\u{fd8f}\u{fd92}-\u{fdc7}\u{fdf0}-\u{fdfb}\u{fe70}-\u{fe74}\u{fe76}-\u{fefc}\u{200c}-\u{200c}\u{0e01}-\u{0e3a}\u{0e40}-\u{0e4e}\u{1100}-\u{11ff}\u{3130}-\u{3185}\u{a960}-\u{a97f}\u{ac00}-\u{d7af}\u{d7b0}-\u{d7ff}\u{ffa1}-\u{ffdc}\u{30a1}-\u{30fa}\u{30fc}-\u{30fe}\u{ff66}-\u{ff9f}\u{ff10}-\u{ff19}\u{ff21}-\u{ff3a}\u{ff41}-\u{ff5a}\u{3041}-\u{3096}\u{3099}-\u{309e}\u{3400}-\u{4dbf}\u{4e00}-\u{9fff}\u{20000}-\u{2a6df}\u{2a700}-\u{2b73f}\u{2b740}-\u{2b81f}\u{2f800}-\u{2fa1f}]*[a-z_\u{00c0}-\u{00d6}\u{00d8}-\u{00f6}\u{00f8}-\u{00ff}\u{0100}-\u{024f}\u{0253}-\u{0254}\u{0256}-\u{0257}\u{0300}-\u{036f}\u{1e00}-\u{1eff}\u{0400}-\u{04ff}\u{0500}-\u{0527}\u{2de0}-\u{2dff}\u{a640}-\u{a69f}\u{0591}-\u{05bf}\u{05c1}-\u{05c2}\u{05c4}-\u{05c5}\u{05d0}-\u{05ea}\u{05f0}-\u{05f4}\u{fb12}-\u{fb28}\u{fb2a}-\u{fb36}\u{fb38}-\u{fb3c}\u{fb40}-\u{fb41}\u{fb43}-\u{fb44}\u{fb46}-\u{fb4f}\u{0610}-\u{061a}\u{0620}-\u{065f}\u{066e}-\u{06d3}\u{06d5}-\u{06dc}\u{06de}-\u{06e8}\u{06ea}-\u{06ef}\u{06fa}-\u{06fc}\u{0750}-\u{077f}\u{08a2}-\u{08ac}\u{08e4}-\u{08fe}\u{fb50}-\u{fbb1}\u{fbd3}-\u{fd3d}\u{fd50}-\u{fd8f}\u{fd92}-\u{fdc7}\u{fdf0}-\u{fdfb}\u{fe70}-\u{fe74}\u{fe76}-\u{fefc}\u{200c}-\u{200c}\u{0e01}-\u{0e3a}\u{0e40}-\u{0e4e}\u{1100}-\u{11ff}\u{3130}-\u{3185}\u{a960}-\u{a97f}\u{ac00}-\u{d7af}\u{d7b0}-\u{d7ff}\u{ffa1}-\u{ffdc}\u{30a1}-\u{30fa}\u{30fc}-\u{30fe}\u{ff66}-\u{ff9f}\u{ff10}-\u{ff19}\u{ff21}-\u{ff3a}\u{ff41}-\u{ff5a}\u{3041}-\u{3096}\u{3099}-\u{309e}\u{3400}-\u{4dbf}\u{4e00}-\u{9fff}\u{20000}-\u{2a6df}\u{2a700}-\u{2b73f}\u{2b740}-\u{2b81f}\u{2f800}-\u{2fa1f}][a-z0-9_\u{00c0}-\u{00d6}\u{00d8}-\u{00f6}\u{00f8}-\u{00ff}\u{0100}-\u{024f}\u{0253}-\u{0254}\u{0256}-\u{0257}\u{0300}-\u{036f}\u{1e00}-\u{1eff}\u{0400}-\u{04ff}\u{0500}-\u{0527}\u{2de0}-\u{2dff}\u{a640}-\u{a69f}\u{0591}-\u{05bf}\u{05c1}-\u{05c2}\u{05c4}-\u{05c5}\u{05d0}-\u{05ea}\u{05f0}-\u{05f4}\u{fb12}-\u{fb28}\u{fb2a}-\u{fb36}\u{fb38}-\u{fb3c}\u{fb40}-\u{fb41}\u{fb43}-\u{fb44}\u{fb46}-\u{fb4f}\u{0610}-\u{061a}\u{0620}-\u{065f}\u{066e}-\u{06d3}\u{06d5}-\u{06dc}\u{06de}-\u{06e8}\u{06ea}-\u{06ef}\u{06fa}-\u{06fc}\u{0750}-\u{077f}\u{08a2}-\u{08ac}\u{08e4}-\u{08fe}\u{fb50}-\u{fbb1}\u{fbd3}-\u{fd3d}\u{fd50}-\u{fd8f}\u{fd92}-\u{fdc7}\u{fdf0}-\u{fdfb}\u{fe70}-\u{fe74}\u{fe76}-\u{fefc}\u{200c}-\u{200c}\u{0e01}-\u{0e3a}\u{0e40}-\u{0e4e}\u{1100}-\u{11ff}\u{3130}-\u{3185}\u{a960}-\u{a97f}\u{ac00}-\u{d7af}\u{d7b0}-\u{d7ff}\u{ffa1}-\u{ffdc}\u{30a1}-\u{30fa}\u{30fc}-\u{30fe}\u{ff66}-\u{ff9f}\u{ff10}-\u{ff19}\u{ff21}-\u{ff3a}\u{ff41}-\u{ff5a}\u{3041}-\u{3096}\u{3099}-\u{309e}\u{3400}-\u{4dbf}\u{4e00}-\u{9fff}\u{20000}-\u{2a6df}\u{2a700}-\u{2b73f}\u{2b740}-\u{2b81f}\u{2f800}-\u{2fa1f}]*)"
    

}
