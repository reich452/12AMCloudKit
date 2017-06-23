//
//  Comment.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/19/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import Foundation
import CloudKit
import UIKit

class Comment: CloudKitSyncable {
    
    static let typeKey = "Comment"
    static let textKey = "text"
    static let timestampKey = "timestamp"
    static let postKey = "post"
    static let postReferenceKey = "postReference"
    static let ownerReferenceKey = "ownerReference"
    
    var text: String
    var timestamp: String
    var post: Post?
    var postReference: CKReference
    var owner: User?
    var ownerReference: CKReference
    var cloudKitRecordID: CKRecordID?
    
    var recordType: String {
        return Comment.typeKey
    }
    
    init(text: String, timestamp: String = Date().description(with: Locale.current), post: Post?, postReference: CKReference, ownerReference: CKReference) {
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.postReference = postReference
        self.ownerReference = ownerReference
    }
    
    convenience required init?(record: CKRecord) {
        guard let timestamp = record.creationDate?.description(with: Locale.current),
            let text = record[Comment.textKey] as? String,
            let postReference = record[Comment.postReferenceKey] as? CKReference,
            let ownerReference = record[Comment.ownerReferenceKey] as? CKReference else { return nil }
        
        self.init(text: text, timestamp: timestamp, post: nil, postReference: postReference, ownerReference: ownerReference)
        
        cloudKitRecordID = record.recordID
    }
}

extension CKRecord {
    
    convenience init(_ comment: Comment) {
        guard let post = comment.post else {
            fatalError("Comment does not have a Post relationship")
        }
        let recordID = CKRecordID(recordName: UUID().uuidString)
        self.init(recordType: comment.recordType, recordID: recordID)
        self.setValue(comment.text, forKey: Comment.textKey)
        self.setValue(comment.timestamp, forKey: Comment.timestampKey)
        self.setValue(post.cloudKitReference, forKey: Comment.postReferenceKey)
        self.setValue(comment.ownerReference, forKey: Comment.ownerReferenceKey)
    }
}
// MARK - Protocol search

extension Comment: SearchableRecord {
    func matches(searchTerm: String) -> Bool {
        return text.contains(searchTerm)
    }
}
