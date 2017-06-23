//
//  FeedTableViewController.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/20/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController {

    fileprivate let presentSignUpSegue =  "presentSignUp"
    fileprivate let showEditProfileSegue = "editProfile"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTimer()
    
        performInitialAppLogic()
        //        self.refreshControl?.addTarget(self, action: #selector(FeedTableViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(reloadData), name: Notification.Name("PostCommentsChangedNotification"), object: nil)
        
        PostController.sharedController.requestFullSync {
            DispatchQueue.main.async {
                self.reloadData()
            }
        }
    }
    
    func setUpTimer() {
        Timer.every(1.second) {
            DispatchQueue.main.async {
                self.navigationController?.title = Date().timeTillString
            }
        }
    }
    
    func reloadData() {
        tableView.reloadData()
        //FIXME: - do we need to call reload data multiple times? or can we use the animateTableFromBottom func since it has reload data?????
    }
    
    // MARK: - Actions
    
    @IBAction func swipToRefresh(_ sender: UIRefreshControl, forEvent event: UIEvent) {
        //        handleRefresh(sender)
        PostController.sharedController.requestFullSync {
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func imageButtonTapped(_ sender: UIImage) {
        // TODO: Fix the segue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "feedToPostDetail" {
            guard let indexPath = tableView.indexPathForSelectedRow, let detailVC = segue.destination as? PostDetailTableViewController else { return }
            let post = PostController.sharedController.filteredPosts[indexPath.row]
            detailVC.post = post
        }
    }
    
    //    func handleRefresh(_ refreshControl: UIRefreshControl) {
    //        PostController.sharedController.requestFullSync()
    ////        PostController.sharedController.performFullSync()
    //        self.tableView.reloadData()
    //        refreshControl.endRefreshing()
    //    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.sharedController.filteredPosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        
        let post = PostController.sharedController.filteredPosts[indexPath.row]
        cell.post = post
        
        return cell
    }
    
    // MARK: - Navigation
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        if let _ = UserController.shared.currentUser {
            performSegue(withIdentifier: showEditProfileSegue, sender: self)
        } else {
            performSegue(withIdentifier: presentSignUpSegue, sender: self)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.black
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        addPicButtonTapped()
        
    }
    
    // test photo posting at whatever time
    
    func performInitialAppLogic() {
        UserController.shared.fetchCurrentUser { user in
            if let _ = user {
                return
            } else {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: self.presentSignUpSegue, sender: self)
                }
            }
        }
    }

    func addPicButtonTapped() {
        
        guard let isMidnight = TimeTracker.shared.isMidnight else { return }
        
        if isMidnight {
            
            if UserController.shared.currentUser != nil {
                
                let cameraOrCancelAlertController = UIAlertController(title: "Add Photo", message: "Take a photo to post", preferredStyle: .alert)
                let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
                    self.performSegue(withIdentifier: "toCameraVC", sender: self) }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                cameraOrCancelAlertController.addAction(cameraAction)
                cameraOrCancelAlertController.addAction(cancelAction)
                present(cameraOrCancelAlertController, animated: true, completion: nil)
                
            } else {
                let noUserAlertController = UIAlertController(title: "User needed", message: "In order to post photos, please log in", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                noUserAlertController.addAction(dismissAction)
                present(noUserAlertController, animated: true, completion: nil)
            }
            
        } else {
            let notMidnightAlertController = UIAlertController(title: "Can't Post photos until midnight", message: "Post photos between 12AM and 1AM", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            notMidnightAlertController.addAction(dismissAction)
            present(notMidnightAlertController, animated: true, completion: nil) ; return
        }
    }
}
