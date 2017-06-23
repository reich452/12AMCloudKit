//
//  SearchableRecord.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/23/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import Foundation

protocol SearchableRecord {
    
    func matches(searchTerm: String) -> Bool 
}
