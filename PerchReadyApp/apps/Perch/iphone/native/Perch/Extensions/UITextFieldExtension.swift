/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

/**
*  No native way to set the placeholder text color of a UITextField, so this utility is helpful
*/
extension UITextField {

    /**
    Set the color of the placeholder text
    
    :param: color The color to use
    */
    func setPlaceholderTextColor(color: UIColor) {
        if self.respondsToSelector("setAttributedPlaceholder:") {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSForegroundColorAttributeName: color])
        } else {
            println("Cannot set placeholder text color, because on iOS < 6.0")
        }
    }
    
}
