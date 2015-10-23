/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

/**
*  UICollectionViewCell class used to manage the various types of icons and status of Assets
*/
class AssetCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var backgroundCircleImageView: UIImageView!
    @IBOutlet weak var assetIconImageView: UIImageView!
    @IBOutlet weak var typeLabel: UILabel!
    
    /**
    Simple method to swap asset backgrounds
    
    - parameter sensorStatus: sensorStatus returned from server, 0 = good, 2 = critical
    */
    func swapAssetState(sensorStatus: Int) {
        
        if sensorStatus == 2 {
            self.backgroundCircleImageView.image = UIImage(named: "circle_yellow")
        } else {
            self.backgroundCircleImageView.image = UIImage(named: "light_gray_circle")
        }
        
    }
    
    /**
    Method that sets the icon for an asset
    
    - parameter deviceType: the type of deviceType to loade the image for
    */
    func setIconForDevice(deviceType: DeviceType, sensorStatus: Int) {
        
        // Icons are white or gray based on sensorStatus
        switch deviceType {
            
            case .WaterMeter:
                self.assetIconImageView.image = (sensorStatus == 0 ? UIImage(named: "watermeter_icon_static") : UIImage(named: "watermeter_icon"))
            case .AirConditioning:
                self.assetIconImageView.image = (sensorStatus == 0 ? UIImage(named: "ac_icon_static") : UIImage(named: "ac_icon"))
            case .SewerSystem:
                self.assetIconImageView.image = (sensorStatus == 0 ? UIImage(named: "sewer_icon_static") : UIImage(named: "sewer_icon"))
            case .Electrical:
                self.assetIconImageView.image = (sensorStatus == 0 ? UIImage(named: "electrical_icon_static") : UIImage(named: "electrical_icon"))
        }
        
    }

}
