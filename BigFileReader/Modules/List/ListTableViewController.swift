//
//  ListTableViewController.swift
//  BigFileReader
//
//  Created by Milkhail Babushkin on 21/01/2019.
//  Copyright © 2019 Mikhail Babushkin. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    // MARK: - Public props
    var url: URL!
    var mask: String!
    
    // MARK: - Private props
    private var chunkCounter: Int = 0
    private var dataSource = WriteLockableSynchronizedArray<String>(with: [])

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Parser.shared.mask = mask
        let connection = NSURLConnection(request: URLRequest(url: url), delegate: self, startImmediately: false)
        connection?.start()
    }

    // TableView

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        
        return cell
    }
}

// MARK: - NSURLConnectionDataDelegate
extension ListTableViewController: NSURLConnectionDataDelegate {
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        guard let chunk = String(data: data, encoding: String.Encoding.ascii) else {
            print("failed")
            return
        }
        print("chunk \(chunk.count)")
        
        Parser.shared.parseNextChunk(chunk) { [weak self] results in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }

                let lastIndex = self.dataSource.count
                
                let indexPaths = (0..<results.count).map { IndexPath(row: lastIndex + $0, section: 0) }
                
                self.dataSource.append(results)
//                guard let `self` = self else { return }
                if #available(iOS 11.0, *) {
                    self.tableView.performBatchUpdates({
                        self.tableView.insertRows(at: indexPaths, with: .automatic)
                    }, completion: nil)
                } else {
                    // Fallback on earlier versions
                }
//                self.tableView.beginUpdates()
//
//
//                self.tableView.endUpdates()
            }
        }
//        chunkCounter += 1
//        print("==== Chunk #\(chunkCounter) ====\n")
//        print(chunk)
    }
}
