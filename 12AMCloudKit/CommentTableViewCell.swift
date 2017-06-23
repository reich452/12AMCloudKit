//
//  CommentTableViewCell.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/20/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    var comment: Comment?  {
        didSet {
            updateViews()
        }
    }
    
    func updateViews() {
        guard let comment = comment else { return }
        commentUsernameLabel.text = comment.owner?.username
        commentBodyTextLabel.text = "User: \(comment.text)"
    }
    
    @IBAction func commentBlockButtonTapped(_ sender: Any) {
        blockUserActionSheet()
    }
    
    func blockUserActionSheet() {
        let blockUserAlertController = UIAlertController(title: "Block User", message: "Would you like to block this user? \nYou will no longer be able to \nsee their posts or comments", preferredStyle: .alert)
        let blockUserAction = UIAlertAction(title: "Block", style: .default) { (_) in
            self.blockUser()
    
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        blockUserAlertController.addAction(blockUserAction)
        blockUserAlertController.addAction(cancelAction)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(blockUserAlertController, animated: true, completion: nil)
    }
    
    func blockUser() {
        guard let comment = comment else { return }
        let ownerReference = comment.ownerReference
        UserController.shared.blockUser(userToBlock: ownerReference) {
            print("Sucessfully blocked user from their Comment")
        }
    }
    
    @IBOutlet weak var commentUsernameLabel: UILabel!
    @IBOutlet weak var commentBodyTextLabel: UILabel!

}
