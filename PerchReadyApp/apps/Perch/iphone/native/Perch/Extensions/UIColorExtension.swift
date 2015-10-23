/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

//Project Specific Colors
extension UIColor {
    class func perchOrange(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 255/255, green: 120/255, blue: 50/255, alpha: alpha)}
    class func perchPlaceholderTextColor(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 255/255, green: 212/255, blue: 160/255, alpha: alpha)}
    class func perchLightGray(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: alpha)}
    class func perchWarmGray(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 201/255, green: 194/255, blue: 194/255, alpha: alpha)}
    class func perchDarkGray(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: alpha)}
    class func perchDarkYellow(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 239/255, green: 193/255, blue: 0/255, alpha: alpha)}
    class func perchNavBarGray(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 174/255, green: 174/255, blue: 174/255, alpha: alpha)}
    class func unreadStatusOrange(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 255/255, green: 165/255, blue: 115/255, alpha: alpha)}
    class func unreadStatusYellow(alpha: CGFloat = 1.0) -> UIColor{return UIColor(red: 253/255, green: 214/255, blue: 0/255, alpha: alpha)}
}

extension UIColor {
    
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        
        var hexString = ""
        
        if hex.hasPrefix("#") {
            let index = hexString.startIndex.advancedBy(1)
            hexString = hex.substringFromIndex(index)
            
        } else {
            hexString = hex
        }
        
        let scanner = NSScanner(string: hex)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexLongLong(&hexValue) {
            switch (hex.characters.count) {
            case 3:
                red = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue = CGFloat(hexValue & 0x00F)              / 15.0
            case 6:
                red = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue = CGFloat(hexValue & 0x0000FF)           / 255.0
            default:
                print("Invalid HEX string, number of characters after '#' should be either 3, 6", terminator: "")
            }
        } else {
            print("Scan hex error")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    convenience init?(cyan: CGFloat, magenta: CGFloat, yellow: CGFloat, black: CGFloat, alpha: CGFloat = 1.0){
        let cmykColorSpace = CGColorSpaceCreateDeviceCMYK()
        let colors = [cyan, magenta, yellow, black, alpha] // CMYK+Alpha
        let cgColor = CGColorCreate(cmykColorSpace, colors)
        self.init(CGColor: cgColor!)
    }
    
}