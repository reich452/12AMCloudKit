//
//  PostTableViewCell.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/20/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var captionLabel: UILabel! // until we get the ratings worked out
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var blockUserButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var post: Post? {
        didSet {
            updateViews()
            setUpUI()
        }
    }
    
    private func updateViews() {
        guard let post = self.post else { return }
        
        imageButton?.setImage(post.photo, for: .normal)
        guard let username = post.owner?.username else { return }
        //this lets the captionLabel just display the first 25 chars of the caption
        let captionLede = String(post.text.characters.prefix(25))
        if captionLede.characters.count > 24 {
            captionLabel.text = "\(captionLede)..."
        } else {
            captionLabel.text = captionLede
        }
        userNameLabel.text = username
        profileImageView.image = post.owner?.profileImage
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.black
    }
    
    // MARK: - Action
    
    @IBAction func imageButtonTapped(_ sender: Any) { // Do stuff to make the imageButtonTapped segue to the detailVC
        let segue = UIStoryboardSegue(identifier: "toPostDVC", source: FeedTableViewController(), destination: PostDetailTableViewController())
        if segue.identifier == "feedToPostDetail" {
            let indexPath = self.index(ofAccessibilityElement: PostTableViewCell())
            guard let detailVC = segue.destination as? PostDetailTableViewController else { return }
            let post = PostController.sharedController.filteredPosts[indexPath]
            detailVC.post = post
        }
    }
    @IBAction func blockUserButtonTapped(_ sender: UIButton) {
        blockUserActionSheet()
    }
    
    func blockUserActionSheet() {
        let blockUserAlertController = UIAlertController(title: "Block User", message: "Would you like to block this user? \nYou will no longer be able to \nsee their posts or comments", preferredStyle: .actionSheet)
        let blockUserAction = UIAlertAction(title: "Block", style: .default) { (_) in
            self.blockUser()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        blockUserAlertController.addAction(blockUserAction)
        blockUserAlertController.addAction(cancelAction)
        UIApplication.shared.keyWindow?.rootViewController?.present(blockUserAlertController, animated: true, completion: nil)
        
    }
    
    func blockUser() {
        guard let post = post else { return }
        let ownerReference = post.ownerReference
        UserController.shared.blockUser(userToBlock: ownerReference) {
            print("Sucessfully blocked user from the Cell")
        }
    }
}

extension PostTableViewCell {
    
    func setUpUI() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
    }
}
