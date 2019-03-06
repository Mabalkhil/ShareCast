//
//  String.swift
//  Podcast
//
//  Created by assem hakami on 16/03/1440 AH.
//  Copyright © 1440 MacBook. All rights reserved.
//

import Foundation



extension String{

        var isValidName: Bool {
            let RegEx = "^\\w{1,18}$"
            let Test = NSPredicate(format:"SELF MATCHES %@", RegEx)
            return Test.evaluate(with: self)
        }
    
   func  toSecureHTTPS() -> String{
    
    return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
    
    func timeStamps() -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: "[0-5]?:[0-5][0-59]:[0-59][0-59][^<a>]")
        {
            let string = self as NSString
            
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range)
            }
        }
        
        return []
    }
    
    
    
    func timeStampsLabled() -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: "[0-5]?:[0-5][0-59]:[0-59][0-59]+\\s+[[\\w+|[-]|[<b>]|[<strong>]]+\\s+]*")
        {
            let string = self as NSString
            
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range)
            }
        }
        
        return []
    }
    
    
    
}
