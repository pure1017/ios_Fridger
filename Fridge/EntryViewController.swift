//
//  EntryViewController.swift
//  Fridge
//
//  Created by Tingyi Wang on 12/2/20.
//

import RealmSwift
import UIKit

class EntryViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var textFeild: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    private let realm = try! Realm()
    public var completionHandler: ((String, Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textFeild.becomeFirstResponder()
        textFeild.delegate = self
        datePicker.setDate(Date(), animated: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSavedButton))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFeild.resignFirstResponder()
        return true
    }
    
    @objc func didTapSavedButton() {
        if let text = textFeild.text, !text.isEmpty {
            let date = datePicker.date
            
            realm.beginWrite()
            let newItem = ToDoListItem()
            newItem.date = date
            newItem.item = text
            realm.add(newItem)
            try! realm.commitWrite()
            
            completionHandler?(text, date)
            navigationController?.popToRootViewController(animated: true)
        }
        else {
            print("Add something")
        }
    }
}

