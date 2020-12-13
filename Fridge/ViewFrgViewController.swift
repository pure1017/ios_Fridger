//
//  ViewFrgViewController.swift
//  Fridge
//
//  Created by Tingyi Wang on 12/2/20.
//

import RealmSwift
import UIKit

class ViewFrgViewController: UIViewController {
    
    public var item: InFrgListItem?
    
    public var deletionHandler: (() -> Void)?
    
    @IBOutlet var itemLabel: UITextField!
    @IBOutlet var noteText: UITextView!
    @IBOutlet var outDateLabel: UILabel!
    @IBOutlet var inDateLabel: UIDatePicker!
    @IBOutlet var expirationLabel: UITextField!
    @IBOutlet var itemNumLabel: UITextField!
    @IBOutlet var imageView: UIImageView!
    
    // Create a URLRequest for an API endpoint
    private let url = URL(string: "https://wdrd6suw5h.execute-api.us-east-1.amazonaws.com/test/item")!
    
    private let realm = try! Realm()
    public var completionHandler: ((String, String, String?, String) -> Void)?
    
    static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    // to store the current active textfield
    var activeTextField : UITextField? = nil
    var activeTextView : UITextView? = nil
    
    public var height = CGFloat(0)
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        self.itemLabel.resignFirstResponder()
        self.expirationLabel.resignFirstResponder()
        self.itemNumLabel.resignFirstResponder()
        self.noteText.resignFirstResponder()
        self.view.frame.origin.y = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        expirationLabel.delegate = self
        noteText.delegate = self
        
        // call the 'keyboardWillShow' function when the view controller receive notification that keyboard is going to be shown
        NotificationCenter.default.addObserver(self, selector: #selector(EntryFriViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let inDate = formatter.date(from: item!.inDate)!
        
        itemLabel.text = item?.item
        noteText.text = item?.note
        outDateLabel.text = item?.outDate
//        inDateLabel.text = item?.inDate
        inDateLabel.setDate(inDate, animated: true)
        expirationLabel.text = item?.expiration
        itemNumLabel.text = item?.itemNum
        print(item!.mainUrl)
        let imageData = try? Data(contentsOf: URL(string: item!.mainUrl)!)
        imageView.image = UIImage(data: imageData!)
        //dateLabel.text = Self.dateFormatter.string(from: item!.inDate)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didTapDelete))
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {

        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {

            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        height = keyboardSize.height
    }

    
    @objc private func didTapDelete() {
        guard let myItem = self.item else {
            return
        }
        
        // delete request
        var request = URLRequest(url: url)
        let body = ["id": myItem.id]
        let bodyData = try? JSONSerialization.data(
            withJSONObject: body,
            options: []
        )
        request.httpMethod = "DELETE"
        request.httpBody = bodyData
        // Create the HTTP request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in

            if error != nil {
                // Handle HTTP request error
                print("error occurs")
                print(response as Any)
            } else if data != nil {
                print("data back")
                print(response as Any)
                // Handle HTTP request response
            } else {
                print("response here")
                print(response as Any)
                // Handle unexpected error
            }
        }
        task.resume()
        
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
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let inDate = formatter.string(from: inDateLabel.date)
            let cal_outDate = Calendar.current.date(byAdding: .day, value: Int(expiration!) ?? 0, to: inDateLabel.date)!
            let outDate = formatter.string(from: cal_outDate)
            
            //notification
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { success, error in
                if success {
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Expire Warning"
                    content.sound = .default
                    content.body = "Please have a look at your " + text
                    
                    let targetDate = cal_outDate
                    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second],from: targetDate),repeats: false)

                    let request = UNNotificationRequest(identifier: "some_long_id", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                        if error != nil {
                            print("something went wrong")
                        }
                    })
                }
                else if error != nil {
                    print("error occered")
                }
            })
            
            realm.beginWrite()
//            let newItem = InFrgListItem()
            myItem.date = Date() //////////need to edit
            myItem.item = text
            myItem.itemNum = itemNum!
            myItem.note = item!.note
            myItem.outDate = outDate
            myItem.inDate = inDate
            myItem.expiration = expiration!
            myItem.iconUrl = item!.iconUrl
            myItem.id = item!.id
            myItem.mainUrl = item!.mainUrl
            realm.add(myItem)
            realm.refresh()
            try! realm.commitWrite()
            
            // post request
            var request = URLRequest(url: url)
            let body = ["itemNum": myItem.itemNum,
                        "note": myItem.note,
                        "outDate": myItem.outDate,
                        "inDate": myItem.inDate,
                        "expiration": myItem.expiration,
                        "iconUrl": myItem.iconUrl,
                        "id": myItem.id,
                        "mainURL": myItem.mainUrl,
                        "itemName": myItem.item] as [String : Any]
            let bodyData = try? JSONSerialization.data(
                withJSONObject: body,
                options: []
            )
            request.httpMethod = "POST"
            request.httpBody = bodyData
            // Create the HTTP request
            let session = URLSession.shared
            let task = session.dataTask(with: request) { (data, response, error) in

                if error != nil {
                    // Handle HTTP request error
                    print("error occurs")
                    print(response as Any)
                } else if data != nil {
                    print("data back")
                    print(response as Any)
                    // Handle HTTP request response
                } else {
                    print("response here")
                    print(response as Any)
                    // Handle unexpected error
                }
            }
            task.resume()
            
            completionHandler?(text, itemNum!, note, expiration!)
            navigationController?.popToRootViewController(animated: true)
        }
        else {
            print("Add something")
        }
    }
    
}

extension ViewFrgViewController : UITextFieldDelegate {
    // when user select a textfield, this method will be called
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // set the activeTextField to the selected textfield
        self.activeTextField = textField
        let bottomOfTextField = self.activeTextField!.convert(self.activeTextField!.bounds, to: self.view).maxY;
        let topOfKeyboard = self.view.frame.height - height
        if bottomOfTextField > topOfKeyboard {
            self.view.frame.origin.y = 0 - height
        }
    }
    
    // when user click 'done' or dismiss the keyboard
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
}

extension ViewFrgViewController : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // set the activeTextField to the selected textfield
        print("begin")
        self.activeTextView = textView
        let bottomOfTextView = self.activeTextView!.convert(self.activeTextView!.bounds, to: self.view).maxY;
        let topOfKeyboard = self.view.frame.height - height
        if bottomOfTextView > topOfKeyboard {
            self.view.frame.origin.y = 0 - height
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("end")
        self.activeTextView = nil
    }
}
