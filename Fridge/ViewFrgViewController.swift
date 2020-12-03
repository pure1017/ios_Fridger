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
    @IBOutlet var dateLabel: UILabel!
    
    private let realm = try! Realm()
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        itemLabel.text = item?.item
        //dateLabel.text = Self.dateFormatter.string(from: item!.inDate)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDelete))
    }
    
    @objc private func didTapDelete() {
        guard let myItem = self.item else {
            return
        }
        
        // post request
//        AF.request("http://httpbin.org/get", method: .post, parameters: ["foo": "bar"], encoding: JSONEncoding.default)
//                 .responseJSON { response in
//                      print(response)
//                  }
        
        realm.beginWrite()
        realm.delete(myItem)
        try! realm.commitWrite()
        
        deletionHandler?()
        navigationController?.popToRootViewController(animated: true)
    }
    
}
