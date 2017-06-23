//
//  PostController.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/19/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

extension PostController {
    static let PostChangeNotified = Notification.Name("PostChangeNotified")
    static let PostCommentsChangedNotification = Notification.Name("PostCommentsChangedNotification")
}

class PostController {
    
    static let sharedController = PostController()
    
    var cloudKitManager = CloudKitManager()
    var posts: [Post] = []
    var comments: [Comment] = []
    var isSyncing: Bool = false
    
    var filteredPosts: [Post] {
        return self.posts.sorted(by: { $0.0.timestamp > $0.1.timestamp })
    }
    
    var sortedPost: [Post] {
        return self.posts.sorted(by: { return $0.timestamp.compare($1.timestamp) == .orderedDescending})
    }
    
    // MARK: CRUD
    
    func createPost(image: UIImage, commentText: String, completion: @escaping ((Post?) -> Void)) {
        guard let data = UIImageJPEGRepresentation(image, 1.0),
            let currenUser = UserController.shared.currentUser, let currentUserRecordID = currenUser.cloudKitRecordID else { return }
        let ownerReference = CKReference(recordID: currentUserRecordID, action: .none)
        let post = Post(photoData: data, text: commentText, owner: currenUser, ownerReference: ownerReference)
        
        posts.insert(post, at: 0)
        let record = CKRecord(post)
        
        cloudKitManager.saveRecord(record) { (record, error) in
            
            if let error = error {
                print("Error saving new post to CloudKit \(error.localizedDescription)")
            }
            completion(post)
        }
    }
    
    func addComment(post: Post, commentText: String, completion: @escaping (() -> Void) = { _ in }) {
        guard let postReference = post.cloudKitReference else { return }
        
        let comment = Comment(text: commentText, post: post, postReference: postReference, ownerReference: post.ownerReference)
        post.comments.append(comment)
        
        cloudKitManager.saveRecord(CKRecord(comment)) { (record, error) in
            if let error = error {
                print("Error saving new comment in CloudKit: \(error)")
                completion()
                return
            }
            comment.cloudKitRecordID = record?.recordID
            completion()
        }
        
        DispatchQueue.main.async {
            let nc = NotificationCenter.default
            nc.post(name: PostController.PostCommentsChangedNotification, object: post)
        }
    }
    
    // MARK: - Synced functions that will help grab records synced in CloudKit. Save on data and time
    
    // Check for specified post and comments
    private func recordsOf(type: String) -> [CloudKitSyncable] {
        switch type {
        case "Post":
            return posts.flatMap { $0 as CloudKitSyncable }
        case "Comment":
            return comments.flatMap { $0 as CloudKitSyncable }
        default:
            return []
        }
    }
    
    // Checking to see if thoes posts have synced or not
    func syncedRecords(ofType type: String) -> [CloudKitSyncable] {
        return recordsOf(type: type).filter { $0.isSynced }
    }
    
    func unsynedReords(ofType type: String) -> [CloudKitSyncable] {
        return recordsOf(type: type).filter { $0.isSynced }
    }
    
    /// Fetching new post only. Say there are 1,000 posts and 500 are on the phone and 500 are in CloudKit, using the above functions will help retriee only the 500 not on the phone saving data and time
    func fetchNewRecords(ofType type: String, completion: @escaping (() -> Void) = { _ in }) {
        
        var referencesToExclude = [CKReference]()
//        let midnight = TimeTracker.shared.midnight.timeIntervalSince1970
//        let midnightDate = NSDate(timeIntervalSince1970: midnight)
//        let oneAM = TimeTracker.shared.midnight.timeIntervalSince1970 + 3600
//        let oneAMDate = NSDate(timeIntervalSince1970: oneAM)
        
        var predicate: NSPredicate?
        if type == "User"{
            predicate = NSPredicate(value: true)
        } else if type == "Post" {
            guard let user = UserController.shared.currentUser,
                let blockUserRefs = user.blockUserRefs, type != "User" else { return }
            predicate = NSPredicate(format: "NOT(ownerRef IN %@)", blockUserRefs)
        } else if type == "Comment" {
            predicate = NSPredicate(value: true)
        }
        
        
        referencesToExclude = self.syncedRecords(ofType: type).flatMap {$0.cloudKitReference}
        //                 var predicateB = NSPredicate(format: "NOT(recordID IN %@)", argumentArray: [referencesToExclude])
        //                        if referencesToExclude.isEmpty {
        //                            if type == "Post" {
        //                                let startingTimePredicate = NSPredicate(format: "timestamp > %@", midnightDate)
        //                                let endingTimePredicate = NSPredicate(format: "timestamp < %@", oneAMDate)
        //
        //                                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startingTimePredicate, endingTimePredicate])
        //                            } else {
        //
        //                            }
        //
        //                        }
        
        guard let predicate2 = predicate else { return }
        
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate2, recordFetchedBlock: nil) { (records, error) in
            guard let records = records else { completion(); return }
            switch type {
            case User.typeKey:
                let users = records.flatMap { User(cloudKitRecord: $0) }
                UserController.shared.users = users
                completion()
            case Post.typeKey:
                let posts = records.flatMap { Post(record: $0) }
                self.posts = posts
                // Spencer helped make the user have a stronger relationship with post
                for post in self.posts {
                    let users = UserController.shared.users
                    guard let postOwner = users.filter({$0.cloudKitRecordID == post.ownerReference.recordID}).first else { break }
                    
                    post.owner = postOwner
                    
                }
                completion()
            case Comment.typeKey:
                let comments = records.flatMap { Comment(record: $0) }
                for comment in comments {
                    let postRef = comment.postReference
                    guard let postIndex = self.posts.index(where: {$0.cloudKitRecordID == postRef.recordID } ) else { completion(); return }
                    let post = self.posts[postIndex]
                    post.comments.append(comment)
                    comment.post = post
                    guard let ownerIndex = UserController.shared.users.index(where: { $0.cloudKitRecordID == comment.ownerReference.recordID  })
                        else { break }
                    let user = UserController.shared.users[ownerIndex]
                    comment.owner = user
                }
                self.comments = comments
                completion()
            default:
                return
            }
        }
    }
    
    func fetchAllPosts(completion: @escaping (() -> Void)) {
        self.fetchNewRecords(ofType: Post.typeKey) {
            completion()
        }
    }
    
    func performFullSync(completion: @escaping (() -> Void) = { _ in }) {
        isSyncing = true
        
        self.fetchNewRecords(ofType: User.typeKey) {
            
            self.fetchNewRecords(ofType: Post.typeKey) {
                
                self.fetchNewRecords(ofType: Comment.typeKey) {
                    
                    self.isSyncing = false
                    completion()
                }
            }
        }
    }
    
    func requestFullSync(_ completion: (() -> Void)? = nil) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        self.performFullSync {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            completion?()
        }
    }
    
}
