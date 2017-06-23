//
//  CameraPreviewViewController.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/20/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class CameraPreviewViewController: UIViewController, UITextFieldDelegate {
    
    var location = CGPoint(x: 0, y: 0)
    var capturedImage : UIImage?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCaptionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = capturedImage
        
        imageCaptionTextFieldGestures()
        self.imageCaptionTextField.delegate = self
        // Tap anywhere on the screen to dismiss the keyboard
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
    }
    
    // MARK: - TextField Functions
    
    func imageCaptionTextFieldGestures() {
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(CameraPreviewViewController.draggedView(_:)))
        
        imageCaptionTextField.addGestureRecognizer(panGesture)
        imageCaptionTextField.isUserInteractionEnabled = true
        
    }
    
    // Press return to dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        imageCaptionTextField.resignFirstResponder()
        return true
    }
    
    // The following four functions allow the textField to be dragged around
    
    // Haven't tested but the userDragged function may not be needed since draggedView function does the same and sets bounds
    func userDragged(gesture: UIPanGestureRecognizer){
        let loc = gesture.location(in: self.view)
        self.imageCaptionTextField.center = loc
    }
    
    func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch : UITouch! = touches.first as? UITouch
        
        location = touch.location(in: self.view)
        
        imageCaptionTextField.center = location
    }
    
    func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        let touch : UITouch! = touches.first as? UITouch
        
        location = touch.location(in: self.view)
        
        imageCaptionTextField.center = location
    }
    
    func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch : UITouch! = touches.first
        
        let location = touch.location(in: self.view)
        
        imageCaptionTextField.center = location
    }
    
    // Function that sets bounds of dragging textField around screen
    func draggedView(_ sender: UIPanGestureRecognizer) {
        
        guard let senderView = sender.view else {
            return
        }
        
        var translation = sender.translation(in: view)
        
        translation.x = max(translation.x, imageView.frame.minX - imageCaptionTextField.frame.minX)
        translation.x = min(translation.x, imageView.frame.maxX - imageCaptionTextField.frame.maxX)
        
        translation.y = max(translation.y, imageView.frame.minY - imageCaptionTextField.frame.minY)
        translation.y = min(translation.y, imageView.frame.maxY - imageCaptionTextField.frame.maxY)
        
        senderView.center = CGPoint(x: senderView.center.x + translation.x, y: senderView.center.y + translation.y)
        sender.setTranslation(.zero, in: view)
        view.bringSubview(toFront: senderView)
    }
    
    // MARK: - Image Gesture Functions
    
    // Function to add tap gesture to UIImageView
    //    func imageTapGesture() {
    //
    //        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
    //
    //        imageView.addGestureRecognizer(tap)
    //
    //        imageView.isUserInteractionEnabled = true
    //
    //        self.view.addSubview(view)
    //
    //    }
    
//     Function which brings up textField when UIImageView is tapped, called in imageTapGesture
        func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
        {
            _ = tapGestureRecognizer.view as! UIImageView
    
            // Your action
        }
    
    
    // MARK: - Action
    
    @IBAction func usePhotoButtonTapped(_ sender: Any) {
        usePhoto()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func imageToTextFieldButton(_ sender: Any) {
        

    }
    
    func usePhoto() {
        guard let commentText = imageCaptionTextField.text, let image = imageView.image else { return }

        PostController.sharedController.createPost(image: image, commentText: commentText) { (post) in
            // TODO: post
        }
    }
    
}
