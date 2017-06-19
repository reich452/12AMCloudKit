//
//  UserController.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/19/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class UserController {
    
    static let shared = UserController()
    
    let publicDB = CKContainer.default().publicCloudDatabase
    let privateDB = CKContainer.default().privateCloudDatabase
    
    var appleUserRecordID: CKRecordID?
    var blockUserRef: [CKReference]? = []
    var users: [User] = []
    var dict : [String: AnyObject]?
    // more effieceint when you want to find a user
    var currentUser: User?
    
    // MARK: - CRUD
    
    func fetchCurrentUser(completion: @escaping (User?) -> Void) {
        CKContainer.default().fetchUserRecordID { (appleUserRecordID, error) in
            if let error = error { print("Error fetching user: \(error.localizedDescription)") }
            guard let appleUserRecordID = appleUserRecordID else { return }
            let appleUserRef = CKReference(recordID: appleUserRecordID, action: .none)
            let predicate = NSPredicate(format: "appleUserRef == %@", appleUserRef)
            let query = CKQuery(recordType: "User", predicate: predicate)
            
            
            
        }
    }
}
