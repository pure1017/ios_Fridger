//
//  ViewFrgViewController.swift
//  Fridge
//
//  Created by Tingyi Wang on 12/2/20.
//

import RealmSwift
import UIKit
import Alamofire

class ViewFrgViewController: UIViewController {
    
    public var item: InFrgListItem?
    
    public var deletionHandler: (() -> Void)?
    
    @IBOutlet var itemLabel: UITextField!
    @IBOutlet var noteText: UITextField!
    @IBOutlet var outDateLabel: UILabel!
    @IBOutlet var inDateLabel: UILabel!
    @IBOutlet var expirationLabel: UITextField!
    @IBOutlet var itemNumLabel: UITextField!
    @IBOutlet var imageView: UIImageView!
    
    
    private let realm = try! Realm()
    public var completionHandler: ((String, String, String?, String) -> Void)?
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        itemLabel.text = item?.item
        noteText.text = item?.note
        outDateLabel.text = item?.outDate
        inDateLabel.text = item?.inDate
        expirationLabel.text = item?.expiration
        itemNumLabel.text = item?.itemNum
        let imageData = try? Data(contentsOf: item!.mainUrl)
        imageView.image = UIImage(data: imageData!)
        //dateLabel.text = Self.dateFormatter.string(from: item!.inDate)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDelete))
    }
    
    @objc private func didTapDelete() {
        guard let myItem = self.item else {
            return
        }
        
        // delete request
//        AF.request("http://httpbin.org/get", method: .delete, parameters: ["foo": "bar"], encoding: JSONEncoding.default)
//                 .responseJSON { response in
//                      print(response)
//                  }
        
        realm.beginWrite()
        realm.delete(myItem)
        try! realm.commitWrite()
        
        deletionHandler?()
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func didTapSavedButton() {
        if let text = itemLabel.text, !text.isEmpty {
            guard let myItem = self.item else {
                return
            }
            
            let itemNum = itemNumLabel.text
            let note = noteText.text
            let expiration = expirationLabel.text
            
            realm.beginWrite()
//            let newItem = InFrgListItem()
            myItem.date = Date() //////////need to edit
            myItem.item = text
            myItem.itemNum = itemNum!
            myItem.note = item!.note
            myItem.outDate = item!.outDate
            myItem.inDate = item!.inDate
            myItem.expiration = expiration!
            myItem.iconUrl = item!.iconUrl
            myItem.id = item!.id
            myItem.mainUrl = item!.mainUrl
            realm.add(myItem)
            realm.refresh()
            try! realm.commitWrite()
            
            completionHandler?(text, itemNum!, note, expiration!)
            navigationController?.popToRootViewController(animated: true)
        }
        else {
            print("Add something")
        }
    }
    
}
