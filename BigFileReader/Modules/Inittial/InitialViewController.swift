//
//  ViewController.swift
//  BigFileReader
//
//  Created by Milkhail Babushkin on 21/01/2019.
//  Copyright © 2019 Mikhail Babushkin. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet private weak var urlTextField: UITextField!
    @IBOutlet private weak var maskTextField: UITextField!
    
    private var maskParsed: String {
        guard let text = maskTextField.text else {
            return ""
        }
        return "^(\(text))$".replacingOccurrences(of: "*", with: ".*").replacingOccurrences(of: "?", with: ".?")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        maskTextField.text = "*"
        urlTextField.text = "https://joker-prognoz.ru/test2.txt"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ListTableViewController else {
            return
        }
        
        vc.mask = maskParsed
        guard let urlString = urlTextField.text,
            let url = URL(string: urlString) else {
                return
        }
        vc.url = url
    }
}

