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

/**
*  This is a simple perch loading view that shows a bouncing bird house animation and a loading text label
*/
class PerchLoadView: UIView {

    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var loadingTextLabel: UILabel!
    var originalFrame: CGRect!
    var stoppedAnimation = false
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
    When waking up from Nib, hide the loading image view which will contain the animated image
    */
    override func awakeFromNib() {
        loadingImageView.alpha = 0.0
        loadingImageView.image = nil
    }
    
    /**
    When this is called, animation a static image growing from the middle of the screen. When that finishes, hide the static image and show the animation image
    */
    func startAnimation() {
        var startingImageView = UIImageView(image: UIImage(named: "house_white"))
        startingImageView.frame = CGRect(x: self.frame.width / 2, y: self.frame.height / 2, width: 0, height: 0)
        self.addSubview(startingImageView)
        
        var finalHeight: CGFloat = 65
        var finalWidth: CGFloat = 53
        
        stoppedAnimation = false
        UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                startingImageView.frame = CGRect(x: (self.frame.width / 2) - (finalWidth / 2), y: (self.frame.height / 2) - (finalHeight / 2), width: finalWidth, height: finalHeight)
        }, completion: { (completed) -> Void in
            startingImageView.removeFromSuperview()
            if !self.stoppedAnimation {
                self.loadingImageView.alpha = 1.0
                self.loadingImageView.image = UIImage.animatedImageNamed("white_perch_loading", duration: 3.0)
            }
        })
    }
    
    /**
    Stop the animating image and destroys it
    */
    func stopAnimation() {
        stoppedAnimation = true
        self.loadingImageView.image = nil
    }
    
    /**
    Animates the perch logo out, but does NOT perform the shaking animation
    */
    func animateWithoutShaking() {
        var startingImageView = UIImageView(image: UIImage(named: "house_white"))
        startingImageView.frame = CGRect(x: self.frame.width / 2, y: self.frame.height / 2, width: 0, height: 0)
        self.addSubview(startingImageView)
        
        var finalHeight: CGFloat = 65
        var finalWidth: CGFloat = 53
        
        UIView.animateWithDuration(0.7, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut,
            animations: { () -> Void in
                startingImageView.frame = CGRect(x: (self.frame.width / 2) - (finalWidth / 2), y: (self.frame.height / 2) - (finalHeight / 2), width: finalWidth, height: finalHeight)
            }, completion: nil)
    }
}
