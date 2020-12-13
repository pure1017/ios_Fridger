//
//  EntryFriViewController.swift
//  Fridge
//
//  Created by Tingyi Wang on 12/12/20.
//

import RealmSwift
import UIKit

class EntryFriViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var itemNameFeild: UITextField!
    @IBOutlet var itemCountFeild: UITextField!
    @IBOutlet var inDatePicker: UIDatePicker!
    @IBOutlet var expirationDay: UITextField!
    @IBOutlet var noteText: UITextView!
    @IBOutlet var imageView: UIImageView!
    
    private let url = URL(string: "https://wdrd6suw5h.execute-api.us-east-1.amazonaws.com/test/item/0")!
    
    private let realm = try! Realm()
    public var completionHandler: ((String, Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        itemNameFeild.becomeFirstResponder()
        itemNameFeild.delegate = self
        inDatePicker.setDate(Date(), animated: true)
        expirationDay.text = "3"
        noteText.text = "please enter your note here"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSavedButton))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        itemNameFeild.resignFirstResponder()
        return true
    }
    
    func imageToBase64(_ image: UIImage) -> String? {
        return "base64,"+(image.jpegData(compressionQuality: 1)?.base64EncodedString())! 
        }
    
    @objc func didTapSavedButton() {
        if let text = itemNameFeild.text, !text.isEmpty {
            let itemName = text
            let itemCount = itemCountFeild.text
            let expiration = expirationDay.text
            let note = noteText.text
            let get_inDate = inDatePicker.date
            let cal_outDate = Calendar.current.date(byAdding: .day, value: Int(expiration!) ?? 0, to: get_inDate)!
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let inDate = formatter.string(from: get_inDate)
            let iconUrl = "https://iot-helper.s3.amazonaws.com/default/IOS-device.jpg"
            let mainURL = imageToBase64(imageView.image!)
//            print(mainURL as Any)
            let id = "0"
            
            // post request
            var request = URLRequest(url: url)
            let body = ["itemNum": itemCount!,
                        "note": note!,
                        "inDate": inDate,
                        "expiration": expiration!,
                        "iconUrl": iconUrl,
                        "id": id,
                        "mainURL": mainURL!,
                        "itemName": itemName] as [String : Any]
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
            
            completionHandler?(text, cal_outDate)
            navigationController?.popToRootViewController(animated: true)
        }
        else {
            print("Add something")
        }
    }
    
    @IBAction func didTapButton() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
}

extension EntryFriViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            imageView.image = image
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
