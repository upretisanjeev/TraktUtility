//
//  TCSExtensions.swift
//  TraktUtility
//
//  Created by Sanjeev Upreti on 03/06/16.
//  Copyright © 2016 Sanjeev Upreti. All rights reserved.
//

// MARK: - Class Imports
import Foundation
import UIKit

// MARK: - Extension on Int
extension Int {
    /// Int to CGFloat conversion
    var cgf: CGFloat { return CGFloat(self) }
    
    /// Int to Float conversion
    var f: Float { return Float(self) }
}

// MARK: - Extension on Float
extension Float {
    /// Float to CGFloat conversion
    var cgf: CGFloat { return CGFloat(self) }
}

// MARK: - Extension on Double
extension Double {
    /// Double to CGFloat conversion
    var cgf: CGFloat { return CGFloat(self) }
}

// MARK: - Extension on CGFloat
extension CGFloat {
    /// CGFloat to Float conversion
    var f: Float { return Float(self) }
}

// MARK: - Extension on String
extension String
{
    /// Method to trim whitespaces
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }    
}

// MARK: - Extension on UIViewController
extension UIViewController {
    
    /// Display an alert with the given message
    func showAlert(message: String?) {
        guard let message = message else {
            print("message found nil in showAlert method")
            return
        }
        
        let alertController = UIAlertController(title: "TraktUtility", message: message, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}