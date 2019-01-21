//
//  ListTableViewController.swift
//  BigFileReader
//
//  Created by Milkhail Babushkin on 21/01/2019.
//  Copyright © 2019 Mikhail Babushkin. All rights reserved.
//

import UIKit

class ListTableViewController: UITableViewController {
    
    var url: URL!
    var mask: String?
    private var chunkCounter: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let connection = NSURLConnection(request: URLRequest(url: url), delegate: self, startImmediately: false)
        connection?.start()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
}

extension ListTableViewController: URLSessionDelegate {
    
}

extension ListTableViewController: NSURLConnectionDataDelegate {
    func connection(_ connection: NSURLConnection, didReceive data: Data) {
        guard let chunk = String(data: data, encoding: String.Encoding.ascii) else {
            print("failed")
            return
        }
        chunkCounter += 1
        print("==== Chunk #\(chunkCounter) ====\n")
        print(chunk)
    }
}
