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
    private let parseOperations: OperationQueue
    private let logOperations: OperationQueue
    var mask: String = ".*"
    
    private init() {
        parseOperations = OperationQueue()
        parseOperations.qualityOfService = QualityOfService.background
        parseOperations.maxConcurrentOperationCount = 1
        
        logOperations = OperationQueue()
        logOperations.qualityOfService = QualityOfService.background
        logOperations.maxConcurrentOperationCount = 1
    }
    
    func parseNextChunk(_ string: String, result: @escaping (([String]) -> Void)) {
        DispatchQueue.global().async { [unowned self] in
            // найдем хвост чанка, который добавим в буффер для последующи парсингов
            guard let tailStartIndex = string.lastIndex(of: "\n") else {
                return
            }
            let tail = string[string.index(after: tailStartIndex)...]
            
            let stringToParse = "\(self.buffer ?? "")\(string)"
            self.buffer = String(tail)

            let op = ParseOperation(stringToParse, mask: self.mask, closure: result)
            self.parseOperations.addOperation(op)
            op.completionBlock = {
                self.logOperations.addOperation(LogOperation(op.results))
            }
        }
    }
    
    
}

private class ParseOperation: Operation {

    private let string: String
    private let mask: String
    private let closure: (([String]) -> Void)
    
    var results: [String] = []

    init(_ string: String, mask: String, closure: @escaping (([String]) -> Void)) {
        self.string = string
        self.mask = mask
        self.closure = closure
    }

    override func main() {
        let start = CFAbsoluteTimeGetCurrent()
        let pattern = mask
        
        guard let regular = try? NSRegularExpression(pattern: pattern, options: [NSRegularExpression.Options.anchorsMatchLines]) else {
            return
        }
        
        let matches = regular.matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
        results = matches.compactMap { match -> String? in
            guard let range = Range(match.range, in: string) else {
                return nil
            }
            return String(string[range])
        }
        
        let diff = CFAbsoluteTimeGetCurrent() - start
        print("Took \(diff) seconds")
        closure(results)
    }
}

private class LogOperation: Operation {
    private let items: [String]
    
    init(_ items: [String]) {
        self.items = items
    }
    
    override func main() {
        Logger.shared.log(items)
    }
}
