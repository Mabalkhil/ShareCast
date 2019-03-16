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
    
    func dropFirst() -> String {
        var str = self
        str = str.substring(from: 1)
        return str
    }
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
}
