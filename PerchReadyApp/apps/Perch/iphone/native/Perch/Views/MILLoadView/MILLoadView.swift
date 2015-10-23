/**************************************
*
*  Licensed Materials - Property of IBM
*  © Copyright IBM Corporation 2015. All Rights Reserved.
*  This sample program is provided AS IS and may be used, executed, copied and modified without royalty payment by customer
*  (a) for its own instruction and study, (b) in order to develop applications designed to run with an IBM product,
*  either for customer's own internal use or for redistribution by customer, as part of such an application, in customer's
*  own products.
*
***************************************/

import UIKit

public class MILLoadView : UIView {
    
    @IBOutlet weak var loadingImage : UIImageView!
    var isLoading = false

    /**
    Initializer for MILLoadView
    
    - returns: And instance of MILLoadView
    */
    class func instanceFromNib() -> MILLoadView {
        return UINib(nibName: "MILLoadView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! MILLoadView
    }
    
    /**
    Begins and repetition of a series of images
    */
    func showLoadingAnimation() {
        self.loadingImage.image = UIImage.animatedImageNamed("", duration: 1.25)
        self.loadingImage.hidden = false
    }
}
