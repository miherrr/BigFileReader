//
//  ListTableViewController.swift
//  BigFileReader
//
//  Created by Milkhail Babushkin on 21/01/2019.
//  Copyright © 2019 Mikhail Babushkin. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    // MARK: - Constants
    private let pageSize = 100
    private let pagePreloadOffset = 20
    
    // MARK: - Private props

    private var chunkCounter: Int = 0
    private var updateQueue: OperationQueue!
    private var pageNumber = 1
    private var url: URL!
    private var mask: String!
    private var data = WriteLockableSynchronizedArray<String>(with: [])
    private var dataSource: [String] {
        let maxIndex = min(pageSize * pageNumber, data.count) - 1
        if !data.isEmpty {
            return Array(data[0...maxIndex])
        } else {
            return []
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateQueue = OperationQueue.main
        updateQueue.maxConcurrentOperationCount = 1
        
        Parser.shared.mask = mask
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: 5000)
        let connection = NSURLConnection(request: request, delegate: self, startImmediately: false)
        connection?.start()
    }
    
    // MARK: - Public interface
    
    func setInitialParams(mask: String, url: URL) {
        self.mask = mask
        self.url = url
    }

    // MARK: - TableView

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if rowsLeftToEnd(for: indexPath) <= pagePreloadOffset {
            pageNumber += 1
            DispatchQueue.main.async { [weak self] in
                self?.insertNewRows()
            }
        }
    }
    
    // MARK: - Private interface

    private func rowsLeftToEnd(for indexPath: IndexPath) -> Int {
        var rowsCount = 0
        for section in indexPath.section..<tableView.numberOfSections {
            if section == indexPath.section {
                rowsCount += tableView.numberOfRows(inSection: section) - (indexPath.row + 1)
            } else {
                rowsCount += tableView.numberOfRows(inSection: section)
            }
        }
        
        return rowsCount
    }
    
    private func insertNewRows() {
        let currentRowsCount = tableView.numberOfRows(inSection: 0)
        let newRowsCount = dataSource.count
        
        let newIndexPaths = (currentRowsCount..<newRowsCount).map { IndexPath(row: $0, section: 0) }
        
        self.tableView.insertRows(at: newIndexPaths)
    }
}

// MARK: - NSURLConnectionDataDelegate
extension ListTableViewController: NSURLConnectionDataDelegate {
    func connectionDidFinishLoading(_ connection: NSURLConnection) {
        print("finished")
    }
    
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        guard let chunk = String(data: data, encoding: String.Encoding.ascii) else {
            return
        }
        print("chunk \(chunk.count)")
        
        Parser.shared.parseNextChunk(chunk) { results in

            self.data.append(results)

            DispatchQueue.main.async {
                self.insertNewRows()
            }
        }
    }
}

extension UITableView {
    func insertRows(at indexPaths: [IndexPath]) {
        if #available(iOS 11.0, *) {
            self.performBatchUpdates({
                self.insertRows(at: indexPaths, with: .automatic)
            }, completion: nil)
        } else {
            self.beginUpdates()
            
            self.insertRows(at: indexPaths, with: .automatic)
            
            self.endUpdates()
        }
    }
}
