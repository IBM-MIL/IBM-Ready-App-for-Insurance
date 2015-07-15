/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import XCTest

class TipTests: XCTestCase {
    
    var vc: TipsViewController!
    var tableView: UITableView?
    
    override func setUp() {
        super.setUp()
        
        var storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        self.vc = storyboard.instantiateViewControllerWithIdentifier("TipsViewController") as! TipsViewController
        
        var oneTip = self.createTestTip()
        TipDataManager.sharedInstance.tips = [oneTip]
        vc.loadView()
        
    }
    
    func createTestTip() -> Tip {
            
        let path = NSBundle(forClass: self.dynamicType).pathForResource("Example", ofType: "json")
        var data = NSData(contentsOfFile: path!, options: .DataReadingMappedIfSafe, error: nil)

        var error : NSError?
        var diction: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: &error) as! NSDictionary
        if error != nil {
            println(error?.localizedDescription)
        }
    
        var tempTip = Tip(dictionary: diction)
        
        return tempTip!
    }
    
    func testTableViewDatasource() {
        XCTAssertTrue(vc.conformsToProtocol(UITableViewDataSource), "Table view does not conform to the UITableViewDataSource protocol")
        XCTAssertNotNil(vc.tipsTableView.dataSource, "Table View datasource is nil")
    }

    func testTableViewDelegate() {
        XCTAssertTrue(vc.conformsToProtocol(UITableViewDelegate), "Table view does not conform to the UITableViewDelegate protocol")
        XCTAssertNotNil(vc.tipsTableView.delegate, "Table View delegate is nil")
    }

    func testTipStatus() {
       
        vc.tipsTableView.registerNib(UINib(nibName: "TipsTableViewCell", bundle: NSBundle(forClass: self.dynamicType)), forCellReuseIdentifier: "tipCell")
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        let cell = vc.tipsTableView.dataSource?.tableView(vc.tipsTableView, cellForRowAtIndexPath: indexPath) as! TipsTableViewCell
        
        // Testing tip status method
        cell.updateTipStatus(true, priorityStatus: true)
        XCTAssertEqual(cell.statusIndicatorView.backgroundColor!, UIColor.unreadStatusYellow(alpha: 1.0), "Tip status should be yellow, but it is not")
        
        cell.updateTipStatus(true, priorityStatus: false)
        XCTAssertEqual(cell.statusIndicatorView.backgroundColor!, UIColor.clearColor(), "Tip status color should be invisible, but it is not")
        
        cell.updateTipStatus(false, priorityStatus: true)
        XCTAssertEqual(cell.statusIndicatorView.backgroundColor!, UIColor.unreadStatusYellow(alpha: 1.0), "Tip status should be yellow, but it is not")
        
        cell.updateTipStatus(false, priorityStatus: false)
        XCTAssertEqual(cell.statusIndicatorView.backgroundColor!, UIColor.unreadStatusOrange(alpha: 1.0), "Tip status should be orange, but it is not")

    }

    override func tearDown() {
        super.tearDown()
    }
   
}
