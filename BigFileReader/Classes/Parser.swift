//
//  Parse.swift
//  BigFileReader
//
//  Created by misha on 22/01/2019.
//  Copyright © 2019 Mikhail Babushkin. All rights reserved.
//

import Foundation

class Parser {
    static var shared = Parser()
    
    
    private var buffer: String?
    var mask: String = ".*"
    
    private init() { }
    
    func parseNextChunk(_ string: String, result: @escaping (([String]) -> Void)) {
        DispatchQueue.global().async { [unowned self] in
            var stringToParse = string
            if let localBuffer = self.buffer {
                self.buffer = nil
                stringToParse = localBuffer + stringToParse
            }
            
            let lines = stringToParse.split(separator: "\n").map { String($0) }
            if !string.hasSuffix("\n"),
                let lastString = lines.last {
                self.buffer = lastString
            }
            
            guard let regular = try? NSRegularExpression(pattern: self.mask, options: []) else {
                result([])
                return
            }
            
            var results: [String] = []
            for line in lines {
                let range = NSRange(location: 0, length: line.count)
                    guard regular.firstMatch(in: line, options: [], range: range) != nil
                    else { continue }
                
                results.append(line)
            }
            
            result(results)
            print("calculated")
        }
    }
    
    
}

//class ParseOperation: Operation {
//
//    private let string: String
//
//    init(_ string: String) {
//        self.string = string
//    }
//
//    override func main() {
//        <#code#>
//    }
//}
