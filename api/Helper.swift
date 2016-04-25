//
//  Helper.swift
//  SalonObjectives
//
//  Created by dev on 4/12/16.
//  Copyright © 2016 Salon Objectives. All rights reserved.
//

import Foundation
import UIKit

public class Helper {
    
    static func resetBadge()  {
   //      print (UIApplication.sharedApplication().applicationIconBadgeNumber)
        if (device_id != "" && UIApplication.sharedApplication().applicationIconBadgeNumber > 0) {
        
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            //inser the device_id for this user
            let url = NSURL(string: ios_push_notif + "/" + device_id)!
        
            let session = NSURLSession.sharedSession()
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "DELETE"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            
            
            
            session.dataTaskWithRequest(request, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            
            }).resume()
        }
        
    }
}

extension String
{
    func trim() -> String
    {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}