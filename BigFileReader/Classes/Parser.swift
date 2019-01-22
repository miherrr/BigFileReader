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
    private let operations: OperationQueue
    var mask: String = ".*"
    
    private init() {
        operations = OperationQueue()
        operations.qualityOfService = QualityOfService.background
        operations.maxConcurrentOperationCount = 2
    }
    
    func parseNextChunk(_ string: String, result: @escaping (([String]) -> Void)) {
        DispatchQueue.global().async { [unowned self] in
            let op = ParseOperation(string, mask: self.mask, closure: result)
            self.operations.addOperation(op)
        }
    }
    
    
}

class ParseOperation: Operation {

    private let string: String
    private let mask: String
    private let closure: (([String]) -> Void)
    
    var result: [String] = []

    init(_ string: String, mask: String, closure: @escaping (([String]) -> Void)) {
        self.string = string
        self.mask = mask
        self.closure = closure
    }

    override func main() {
        print("start parsing")
        let lines = string.split(separator: "\n").map { String($0) }
        
        guard let regular = try? NSRegularExpression(pattern: mask, options: []) else {
            return
        }
        
        var results: [String] = []
        for line in lines {
            let range = NSRange(location: 0, length: line.count)
            guard regular.firstMatch(in: line, options: [], range: range) != nil
                else { continue }
            
            results.append(line)
        }
        
        closure(results)
        print("calculated")
    }
}
