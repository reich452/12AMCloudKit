//
//  UICollorHelper.swift
//  12AMCloudKit
//
//  Created by Nick Reichard on 6/20/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let midnight = #colorLiteral(red: 0.256510973, green: 0.2349787056, blue: 0.2926091254, alpha: 1)
    
}

extension CGColor {
    
    static let midnight = #colorLiteral(red: 0.256510973, green: 0.2349787056, blue: 0.2926091254, alpha: 1)
    
}

extension UIColor {
    
    static let clearBlur = #colorLiteral(red: 0.5622138721, green: 0.6007425318, blue: 0.6744725571, alpha: 0.3732609161)
}

extension UIColor {
    
    static func rgb(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}


