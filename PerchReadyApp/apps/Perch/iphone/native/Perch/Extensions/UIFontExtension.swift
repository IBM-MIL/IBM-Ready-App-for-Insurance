/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

//Project specific font
extension UIFont {
    /**
    Returns the UIFont for Karla of a particular size
    - parameter size: The size of the font
    */
    class func karla(size: CGFloat) -> UIFont{return UIFont(name: "Karla-Regular", size: size)!}
    
    /**
    Returns the UIFont for Karla-Italic of a particular size
    - parameter size: The size of the font
    */
    class func karlaItalic(size: CGFloat) -> UIFont{return UIFont(name: "Karla-Italic", size: size)!}
    
    /**
    Returns the UIFont for karla-Bold-Italic of a particular size
    - parameter size: The size of the font
    */
    class func karlaBoldItalic(size: CGFloat) -> UIFont{return UIFont(name: "Karla-BoldItalic", size: size)!}
    
    /**
    Returns the UIFont for karla-Bold of a particular size
    - parameter size: The size of the font
    */
    class func karlaBold(size: CGFloat) -> UIFont{return UIFont(name: "Karla-Bold", size: size)!}
    
    /**
    Returns the UIFont for Merriweather-Regular of a particular size
    - parameter size: The size of the font
    */
    class func merriweather(size: CGFloat) -> UIFont{return UIFont(name: "Merriweather", size: size)!}
    
    /**
    Returns the UIFont for Merriweather-Black of a particular size
    - parameter size: The size of the font
    */
    class func merriweatherBlack(size: CGFloat) -> UIFont{return UIFont(name: "Merriweather-Black", size: size)!}
    
    /**
    Returns the UIFont for Merriweather-Bold of a particular size
    - parameter size: The size of the font
    */
    class func merriweatherBold(size: CGFloat) -> UIFont{return UIFont(name: "Merriweather-Bold", size: size)!}
    
    /**
    Returns the UIFont for Merriweather-BoldItalic of a particular size
    - parameter size: The size of the font
    */
    class func merriweatherBoldItalic(size: CGFloat) -> UIFont{return UIFont(name: "Merriweather-BoldItalic", size: size)!}
    
    /**
    Returns the UIFont for Merriweather-HeavyItalic of a particular size
    - parameter size: The size of the font
    */
    class func merriweatherHeavyItalic(size: CGFloat) -> UIFont{return UIFont(name: "Merriweather-HeavyItalic", size: size)!}
    
    /**
    Returns the UIFont for Merriweather-Italic of a particular size
    - parameter size: The size of the font
    */
    class func merriweatherItalic(size: CGFloat) -> UIFont{return UIFont(name: "Merriweather-Italic", size: size)!}
    
    /**
    Returns the UIFont for Merriweather-Light of a particular size
    - parameter size: The size of the font
    */
    class func merriweatherLight(size: CGFloat) -> UIFont{return UIFont(name: "Merriweather-Light", size: size)!}
    
    /**
    Returns the UIFont for Merriweather-LightItalic of a particular size
    - parameter size: The size of the font
    */
    class func merriweatherLightItalic(size: CGFloat) -> UIFont{return UIFont(name: "Merriweather-LightItalic", size: size)!}
}

extension UIFont {
    
    
    /**
    Prints all the font names for the app to the console. This is helpful to find out if the font you added is in the project and to find the string needed to initialize a font with.
    */
    class func printAllFontNames(){
        for family in UIFont.familyNames(){
            print(family)
            for font in UIFont.fontNamesForFamilyName((family )){
                print("\t\(font)")
            }
        }
    }
    
    /**
    Generates and prints all the code needed to make a function for each default font in XCode
    */
    class func printAllFontNameFunctions(){
        for family in UIFont.familyNames(){
            for font in (UIFont.fontNamesForFamilyName((family )) ){
                var fontfunctionname = font.lowercaseFirstLetterString()
                fontfunctionname = fontfunctionname.stringByReplacingOccurrencesOfString("-", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                print("\t/**\n\tReturns the UIFont for \(font) of a particular size\n\t:param: size The size of the font\n\t*/\n\tclass func \(fontfunctionname)(size: CGFloat) -> UIFont{return UIFont(name: \"\(font)\", size: size)!}\n\n")
            }
        }
    }
    
}
