//
//  EntryFriViewController.swift
//  Fridge
//
//  Created by Tingyi Wang on 12/12/20.
//

import RealmSwift
import UIKit

class EntryFriViewController: UIViewController {
    
    public var imagePickerController: UIImagePickerController?
    
    @IBOutlet weak var itemNameFeild: UITextField!
    @IBOutlet weak var itemCountFeild: UITextField!
    @IBOutlet var inDatePicker: UIDatePicker!
    @IBOutlet weak var expirationDay: UITextField!
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet var imageView: UIImageView!
    
    private let url = URL(string: "https://wdrd6suw5h.execute-api.us-east-1.amazonaws.com/test/item/0")!
    
    private let realm = try! Realm()
    public var completionHandler: ((String, Date) -> Void)?
    
    internal var selectedImage: UIImage? {
            get {
                return self.imageView.image
            }
            
            set {
                switch newValue {
                case nil:
                    self.imageView.image = nil
                default:
                    self.imageView.image = newValue
                    
                }
            }
        }
    
    // to store the current active textfield
    var activeTextField : UITextField? = nil
    var activeTextView : UITextView? = nil
    
    public var height = CGFloat(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        itemNameFeild.becomeFirstResponder()
        itemNameFeild.delegate = self
        itemCountFeild.delegate = self
        expirationDay.delegate = self
        noteText.delegate = self
        inDatePicker.setDate(Date(), animated: true)
        expirationDay.text = "3"
        noteText.text = "please enter your note here"
        
        // call the 'keyboardWillShow' function when the view controller receive notification that keyboard is going to be shown
        NotificationCenter.default.addObserver(self, selector: #selector(EntryFriViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSavedButton))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        self.itemNameFeild.resignFirstResponder()
        self.itemCountFeild.resignFirstResponder()
        self.expirationDay.resignFirstResponder()
        self.noteText.resignFirstResponder()
        self.view.frame.origin.y = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        itemNameFeild.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {

        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {

            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        height = keyboardSize.height
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
    
    @IBOutlet weak var selectImageButton: UIButton! {
        didSet {
            guard let button = self.selectImageButton else { return }
            button.isEnabled = true
            button.alpha = 1
        }
    }
    
    @IBAction func selectImageButtonAction(_ sender: UIButton) {
        /// present image picker
        
        if self.imagePickerController != nil {
            self.imagePickerController?.delegate = nil
            self.imagePickerController = nil
        }
        
        self.imagePickerController = UIImagePickerController.init()
        
        let alert = UIAlertController.init(title: "Select Source Type", message: nil, preferredStyle: .actionSheet)
        
        print(UIImagePickerController.isSourceTypeAvailable(.camera))
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction.init(title: "Camera", style: .default, handler: { (_) in
                self.presentImagePicker(controller: self.imagePickerController!, source: .camera)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction.init(title: "Photo Library", style: .default, handler: { (_) in
                self.presentImagePicker(controller: self.imagePickerController!, source: .photoLibrary)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            alert.addAction(UIAlertAction.init(title: "Saved Albums", style: .default, handler: { (_) in
                self.presentImagePicker(controller: self.imagePickerController!, source: .savedPhotosAlbum)
            }))
        }
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    internal func presentImagePicker(controller: UIImagePickerController , source: UIImagePickerController.SourceType) {
            controller.delegate = self
            controller.sourceType = source
            self.present(controller, animated: true)
        }
}

extension EntryFriViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return self.imagePickerControllerDidCancel(picker)
        }
                
        self.selectedImage = image
            
        picker.dismiss(animated: true) {
            picker.delegate = nil
            self.imagePickerController = nil
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            picker.delegate = nil
            self.imagePickerController = nil
        }
    }
}

extension EntryFriViewController : UITextFieldDelegate {
    // when user select a textfield, this method will be called
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // set the activeTextField to the selected textfield
        self.activeTextField = textField
    }
    
    // when user click 'done' or dismiss the keyboard
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
}

extension EntryFriViewController : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        // set the activeTextField to the selected textfield
        self.activeTextView = textView
        let bottomOfTextView = self.activeTextView!.convert(self.activeTextView!.bounds, to: self.view).maxY;
        let topOfKeyboard = self.view.frame.height - height
        if bottomOfTextView > topOfKeyboard {
            self.view.frame.origin.y = 0 - height
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.activeTextView = nil
    }
}
