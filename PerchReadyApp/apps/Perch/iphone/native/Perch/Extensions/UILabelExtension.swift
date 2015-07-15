/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/


import Foundation
import UIKit

extension UILabel {
    
    func setKernAttribute(size: CGFloat!){
        let kernAttribute : Dictionary = [NSKernAttributeName: size]
        self.attributedText = NSAttributedString(string: self.text!, attributes: kernAttribute)
    }
}