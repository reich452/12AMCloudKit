//
//  CloudKitSyncable.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/20/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitSyncable {
    
    init?(record: CKRecord)
    
    var cloudKitRecordID: CKRecordID? { get set }
    var recordType: String { get }
}

extension CloudKitSyncable {
    /// helper variable to determine if a CloudKitSyncable has a CKRecordID, which we can use to say that the record has been saved to the server
    var isSynced: Bool {
        return cloudKitRecordID != nil
    }
    
    /// a computed property that returns a CKReference to the object in CloudKit
    var cloudKitReference: CKReference? {
        guard let recordID = cloudKitRecordID else { return nil }
        
        return CKReference(recordID: recordID, action: .none)
    }
}
