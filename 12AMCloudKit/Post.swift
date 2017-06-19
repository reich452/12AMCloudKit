//
//  Post.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/19/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class Post {
    
    static let typeKey = "Post"
    static let photoDataKey = "photoData"
    static let timestampKey = "timestamp"
    static let textKey = "text"
    static let ownerKey = "owner"
    static let ownerReferenceKey = "ownerRef"
    
    let photoData: Data?
    let timestamp: Date
    let text: String
    var owner: User?
    var ownerReference: CKReference
    var cloudKitRecordID: CKRecordID?
    var comments: [Comment]
    
    var recordType: String {
        return Post.typeKey
    }
    
    var photo: UIImage? {
        guard let photoData = self.photoData else { return nil }
        return UIImage(data: photoData)
    }
    
    var cloudKitReference: CKReference? {
        guard let cloudKitRecordID = self.cloudKitRecordID else { return nil }
        
        return CKReference(recordID: cloudKitRecordID, action: .none)
    }
    
    // When creating a post
    init(photoData: Data?, timestamp: Date = Date(), text: String, comments: [Comment] = [], owner: User, ownerReference: CKReference) {
        
        self.photoData = photoData
        self.timestamp = timestamp
        self.text = text
        self.comments = comments.sorted(by: {$0.timestamp > $1.timestamp })
        self.ownerReference = ownerReference
    }
    
    fileprivate var temporaryPhotoURL: URL {
        
        let teporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: teporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathComponent("jpg")
        
        try? photoData?.write(to: fileURL, options: .atomic)
        
        return fileURL
    }
    
    init?(record: CKRecord) {
        guard let timestamp = record[Post.timestampKey] as? Date,
            let text = record[Post.textKey] as? String,
            let photoAsset = record[Post.photoDataKey] as? CKAsset,
            let photoData = try? Data(contentsOf: photoAsset.fileURL),
            let ownerReference = record[Post.ownerReferenceKey] as? CKReference else { return nil }
        
        self.photoData = photoData
        self.timestamp = timestamp
        self.text = text
        self.ownerReference = ownerReference
        self.cloudKitRecordID = record.recordID
        self.comments = []
    }
}


extension CKRecord {
    
    convenience init(_ post: Post) {
        
        let recordID = post.cloudKitRecordID ?? CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: post.recordType, recordID: recordID)
        self[Post.textKey] = post.text as CKRecordValue
        self.setValue(post.text, forKey: Post.textKey)
        self.setValue(post.timestamp, forKey: Post.timestampKey)
        self.setValue(post.photoData, forKey: Post.photoDataKey)
        guard let owner = post.owner,
            let ownerRecordID = owner.cloudKitRecordID else { return }
        self[Post.ownerReferenceKey] = CKReference(recordID: ownerRecordID, action: .deleteSelf)
        
    }
    
}

