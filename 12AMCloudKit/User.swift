//
//  User.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/19/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class User {
    
    static let usernameKey = "username"
    static let emailKey = "email"
    static let appleUserRefKey = "appleUserRef"
    static let recordTypeKey = "User"
    static let imageKey = "image"
    static let typeKey = "User"
    static let blockUserRefKey = "blockUserRef"
    static let accessTokenKey = "accessToken"
    
    var username: String
    var email: String
    var profileImage: UIImage?
    var currenTimeZone: String { return TimeZone.current.identifier }
    var blockUserRefs: [CKReference]? = []
    var blockUsersArray: [User] = []
    var users: [User] = []
    // post
    
    // This is your cusome user record's ID
    var cloudKitRecordID: CKRecordID?
    var appleUserRef: CKReference?
    
    var imageData: Data? {
        guard let image = profileImage, let imageData = UIImageJPEGRepresentation(image, 1.0) else { return nil }
        return imageData
    }
    
    // TODO: - add a facebook initializer ?? 
    
    /// Must write to temporary directory to be able to pass image file path to CKAsset
    fileprivate var temporaryPhotoURL: URL {
        
        let temperoaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temperoaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathComponent("jpg")

        try? imageData?.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    /// For the sign up page. Exists locally - its a new user that doesn't exist yet
    /// To create an instance from a new user
    init(username: String, email: String, profileImage: UIImage?, appleUserRef: CKReference, blockUserRefs: [CKReference]? = []) {
        self.username = username
        self.email = email
        self.profileImage = profileImage
        self.appleUserRef = appleUserRef
        self.blockUserRefs = blockUserRefs
    }
    
    /// FetchLogedInUserRecord - this is for fetching
    init?(cloudKitRecord: CKRecord) {
        guard let username = cloudKitRecord[User.usernameKey] as? String,
            let email = cloudKitRecord[User.emailKey] as? String,
            let appleUserRef = cloudKitRecord[User.appleUserRefKey] as? CKReference else { return nil }
        
        self.blockUserRefs = cloudKitRecord[User.blockUserRefKey] as? [CKReference] ?? []
        self.username = username
        self.email = email
        self.appleUserRef = appleUserRef
        self.cloudKitRecordID = cloudKitRecord.recordID // our recordID
    }
}

// adding on to a CKRecord

extension CKRecord {
    
    convenience init(user: User) {
        
        // check the record id first. 
        let recordID = user.cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        
        self.init(recordType: User.recordTypeKey, recordID: recordID)
        self.setValue(user.username, forKey: User.usernameKey)
        self.setValue(user.email, forKey: User.emailKey)
        self.setValue(user.appleUserRef, forKey: User.appleUserRefKey)
        self.setValue(user.blockUserRefs, forKey: User.blockUserRefKey)
        guard user.profileImage != nil else { return }
        let imageAsset = CKAsset(fileURL: user.temporaryPhotoURL)
        self.setValue(imageAsset, forKey: User.imageKey)
        
    }
}


