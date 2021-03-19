//
//  ViewController.swift
//  Meme Me 1.0
//
//  Created by Betz, Florian (059) on 08.03.21.
//

import UIKit

class CreateMemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    let albumController = UIImagePickerController()
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: NSNumber(-3.0)
    ]
    
    // MARK: View methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // connect delegates with UI elements
        albumController.delegate = self
        topTextField.delegate = self
        bottomTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        // set default values for text labels
        setMemeTextFieldAttributes(topTextField)
        setMemeTextFieldAttributes(bottomTextField)
        
        // check if camera is available on the device
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        // disable navigation bar buttons at the beginning
        enableNavigationBarButtons(false)
        
        // subscribe to keyboard notifications
        subscribeToKeyboardNotifications()
        
        // disable tab bar
        self.tabBarController!.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    // MARK: IBActions
    @IBAction func albumButtonPressed(_ sender: UIBarButtonItem) {
        albumController.sourceType = .photoLibrary
        present(albumController, animated: true, completion: nil)
    }
    
    @IBAction func photoButtonPressed(_ sender: UIBarButtonItem) {
        albumController.sourceType = .camera
        present(albumController, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        let myMeme = save()
        let shareController = UIActivityViewController(activityItems: [myMeme.memedImage], applicationActivities: nil)
        shareController.completionWithItemsHandler = { (_, completed: Bool, _, _) in
            if completed {
                self.saveMemeToDocumentsDirectory(meme: myMeme)
            }
        }
        present(shareController, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        imageView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        self.navigationController!.popViewController(animated: true)
        enableNavigationBarButtons(false)
    }
    
    // MARK: Delegate methods
    
    // MARK: image picker delegate methods
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            enableNavigationBarButtons(true)
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: UITextFieldDelegate methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == topTextField {
            if topTextField.text == "TOP" {
                topTextField.text = ""
            }
        } else {
            if bottomTextField.text == "BOTTOM" {
                bottomTextField.text = ""
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text == "" {
            if textField == topTextField {
                textField.text = "TOP"
                enableNavigationBarButtons(false)
            } else {
                textField.text = "BOTTOM"
                enableNavigationBarButtons(false)
            }
        } else {
            enableNavigationBarButtons(true)
        }
        
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: keyboard methods
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: meme object methods
    func save() -> Meme {
        let myMeme = Meme(topText: topTextField.text, bottomText: bottomTextField.text, originalImage: imageView.image, memedImage: generateMemedImage())
        
        // add new meme to the Meme Array
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(myMeme)
        
        return myMeme
    }

    func generateMemedImage() -> UIImage {
        // hide tool and navbar
        toolBar.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // enable tool and navbar
        toolBar.isHidden = false
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        return memedImage
    }

    func saveMemeToDocumentsDirectory(meme: Meme) {
        // get documents directory url
        let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // define image name
        let fileName: String
        if let text = meme.topText {
            fileName = text + ".jpg"
        } else {
            fileName = "myMeme.jpg"
        }
        // define filepath where the meme gets saved
        let filePath = documentDir.appendingPathComponent(fileName)
        if let data = meme.memedImage.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: filePath)
            } catch {
                print("failed to save the meme!", error)
            }
        }
    }
    
    // MARK: additional methods for reducing code duplication
    func setMemeTextFieldAttributes(_ textField: UITextField) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.text = textField == topTextField ? "TOP" : "BOTTOM"
    }
    
    func enableNavigationBarButtons(_ enable: Bool) {
        shareButton.isEnabled = enable
        cancelButton.isEnabled = enable
    }
}

