//
//  LoginViewController.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/20/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: Actions 
    
    @IBAction func profileImageButtonTapped(_ sender: Any) {
        addedProfileImage()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        if let existingUser = currentUser {
            updateCurrentUser()
        } else {
            saveNewUser()
        }
    }
    
    // MARK: Main 
    
    func showActivityIndicatory(uiView: UIView) {
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        actInd.center = loginView.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        uiView.addSubview(actInd)
        activityIndicaor.startAnimating()
    }
    
    func saveNewUser() {
        guard let userName = userNameTextField.text, let email = emailTextField.text else { return }
        let profileImage = profileImageView.image
        UserController.shared.createUser(with: userName, email: email, profileImage: profileImage, completion: { user in
            
            if let _ = user {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                print("SOMETHING WENT TERRIBLY WRONG \(#file) \(#function)")
            }
        })
    }
    
    func updateCurrentUser() {
        navigationController?.popViewController(animated: true)
        guard let userName = userNameTextField.text, let email = emailTextField.text else { return }
        let profileImage = profileImageView.image
        UserController.shared.updateCurrentUser(username: userName, email: email, profileImage: profileImage, completion: { user in
            if let _ = user {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                print("SOMETHING WENT TERRIBLY WRONG updating the currentUser\(#file) \(#function)")
            }
        })
    }
    
    func addedProfileImage() {
        if UIImagePickerController.isSourceTypeAvailable(.camera)  {
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .popover
            imagePicker.delegate = self
            present(imagePicker, animated:  true, completion: nil)
            
        } else {
            noCameraOnDevice()
        }
    }
    
    func updateViews() {
        if let currentUser = currentUser {
            title = "Edit Profile"
            signUpButton.setTitle("Save", for: .normal)
            userNameTextField.text = currentUser.username
            emailTextField.text = currentUser.email
            profileImageView.image = currentUser.profileImage
        } else {
            title = "Sign up"
            signUpButton.setTitle("Sign up", for: .normal)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if userNameTextField.isFirstResponder == true {
            userNameTextField.placeholder = ""
        }
        if emailTextField.isFirstResponder == true {
            emailTextField.keyboardType = .emailAddress
            emailTextField.placeholder = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Delegates
    
    // TODO: - Put animation clock while pic is loading to postdetaifromcameraviewcontroller
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        if chosenImage != nil {
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.image = chosenImage
        }
        imagePickerWasDismissed = true
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerWasDismissed = true
        dismiss(animated: true, completion: nil)
    }

    
    
    // MARK: Properties
    
    fileprivate var animationPerformedOnce = false
    fileprivate var imagePickerWasDismissed = false
    fileprivate var activityIndicaor: UIActivityIndicatorView = UIActivityIndicatorView()
    fileprivate let emailLine = UIView()
    fileprivate let usernameLine = UIView()
    fileprivate let imagePicker = UIImagePickerController()
    
    fileprivate var currentUser: User? {
        return UserController.shared.currentUser
    }

    @IBOutlet var loginView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signUpButtonCenterXContstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageCenterConstraint: NSLayoutConstraint!

}

extension LoginViewController  {
    
    func noCameraOnDevice() {
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style:.default, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func invalidEmailAlerMessage(messageToDisplay: String ) {
        let alertController = UIAlertController(title: "Invalid Email", message: messageToDisplay, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Code in this block will trigger when Save button tapped.
            print("Save button tapped");
        }
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func didEnterMidnight() {
        print("ITS GO TIME!!")
    }
    
    func didExitMidnight() {
        print("AINT NOBODY GOT TIME FOR DAT")
    }
    
}

// MARK: - UI Style

extension LoginViewController {
    
    func setUpUI() {
        profileImageView.layer.cornerRadius = profileImageButton.frame.size.width / 2
        signUpButton.layer.cornerRadius = 20.0
    }
}
