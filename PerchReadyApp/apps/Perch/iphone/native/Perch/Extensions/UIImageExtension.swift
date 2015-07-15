/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation
import AVFoundation
import UIKit

//Custom images for the project
extension UIImage {
    
    class func backArrowWhite()->UIImage{
        return UIImage(named: "back_white")!
    }
    
    class func backArrowGray()->UIImage{
        return UIImage(named: "back_grey")!
    }
    
    class func menuWhite()->UIImage{
        return UIImage(named: "menu_white")!
    }
    
    class func menuGray()->UIImage{
        return UIImage(named: "menu_grey")!
    }
    
    class func activePageDot()->UIImage{
        return UIImage(named: "page_dot_fill")!
    }
    
    class func inactivePageDot()->UIImage{
        return UIImage(named: "page_dot")!
    }
}
