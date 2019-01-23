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
        guard let text = maskTextField.text,
            !text.isEmpty else {
            return ""
        }
        return "^(\(text))$".replacingOccurrences(of: "*", with: ".*").replacingOccurrences(of: "?", with: ".?")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        maskTextField.text = "*"
        urlTextField.text = "https://joker-prognoz.ru/test2.txt"
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard  identifier == "table" else { return false }
        
        guard verifyUrl(urlString: urlTextField.text),
            let urlString = urlTextField.text,
            URL(string: urlString) != nil else {
        
                alert(message: "url невалидный")
                return false
        }
        
        guard !maskParsed.isEmpty else {
            alert(message: "введите маску")
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ListTableViewController else {
            return
        }
        
        guard let urlString = urlTextField.text,
            let url = URL(string: urlString) else {
                alert(message: "url невалидный")
                return
        }
        vc.setInitialParams(mask: maskParsed, url: url)
    }
    
    private func alert(message: String) {
        let alertVC = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alertVC, animated: true, completion: nil)
    }
    
    private func verifyUrl (urlString: String?) -> Bool {
        let patternString = "^(http:\\/\\/www\\.|https:\\/\\/www\\.|http:\\/\\/|https:\\/\\/)?[a-z0-9]+([\\-\\.]{1}[a-z0-9]+)*\\.[a-z]{2,5}(:[0-9]{1,5})?(\\/.*)?$"
        guard let regex = try? NSRegularExpression(pattern: patternString, options: [NSRegularExpression.Options.anchorsMatchLines]),
            let string = urlString else { return false }
        
        
        return regex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count)) != nil
    }
}

