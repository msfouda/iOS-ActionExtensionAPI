//
//  ActionViewController.swift
//  TranslationExtension
//
//  Created by Mohamed Sobhi  Fouda on 8/5/18.
//  Copyright © 2018 Mohamed Sobhi Fouda. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    var textToTranslate: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var textFound = false
        for item: Any in self.extensionContext!.inputItems {
            let inputItem = item as! NSExtensionItem
            for provider: Any in inputItem.attachments! {
                let itemProvider = provider as! NSItemProvider
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePlainText as String) {
                    
                    itemProvider.loadItem(forTypeIdentifier: kUTTypePlainText as String, options: nil, completionHandler: { (text, error) in
                        if var text = text as? String {
                            OperationQueue.main.addOperation {
                                text = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                                if let encodedString = text.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                                    self.textToTranslate = encodedString
                                }
                            }
                        }
                    })
                    
                    textFound = true
                    break
                }
            }
            
            if (textFound) {
                // We only handle one snippet of text, so stop looking for more.
                break
            }
        }
    }
    
    @IBAction func translateTapped(_ sender: Any) {
        var language: String
        
        if textField.text == "" {
            textView.text = "Please enter a language"
            return
        } else {
            language = textField.text!
            language = language.lowercased()
            getTranslation(urlString: "https://api-platform.systran.net/translation/text/translate?key=e1c5251c-4b1c-4808-846f-9fbd8e60a00e&source=auto&target=\(language)&input=\(textToTranslate!)")
        }
    }
    
    func getTranslation(urlString: String) {
        let url = URL(string: urlString)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async(execute: {
                    self.setTextView(translationData: data)
                })
            } else if let error = error {
                DispatchQueue.main.async(execute: {
                    self.textView.text = "Error getting translation"
                })
            } else {
                print("No Data or Error from Server")
            }
        }
        task.resume()
    }
    
    func setTextView(translationData: Data) {
        do {
            let json = try JSONSerialization.jsonObject(with: translationData, options: []) as! [String: Any]
            
            print(json)
            
            if let outputs = json["outputs"] as? [[String: Any]] {
                if let translation = outputs[0]["output"] as? String {
                    self.textView.text = translation
                }
            } else {
                self.textView.text = "No Translation Found"
            }
        } catch {
            print("Error fetching data")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
}
