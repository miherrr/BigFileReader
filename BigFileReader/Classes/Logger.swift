//
//  Logger.swift
//  BigFileReader
//
//  Created by misha on 23/01/2019.
//  Copyright © 2019 Mikhail Babushkin. All rights reserved.
//

import Foundation

class Logger {
    static var shared = Logger()
    
    private init() { }
    
    func log(_ items: [String]) {
        let result = items.joined(separator: "\n").appending("\n")
        guard let data = result.data(using: String.Encoding.ascii) else {
            return
        }
        
        let manager = FileManager.default
        do {
            let documentDirectory = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            
            let fileURL = documentDirectory.appendingPathComponent("results.log")
            
            if manager.fileExists(atPath: fileURL.path) {
                if let file = try? FileHandle(forWritingTo: fileURL) {
                    file.seekToEndOfFile()
                    
                    file.write(data)
                    file.closeFile()
                }
            } else {
                try data.write(to: fileURL)
//                try result.write(to: fileURL, atomically: false, encoding: String.Encoding.ascii)
            }
        } catch {
            print(error)
        }
    }
}
