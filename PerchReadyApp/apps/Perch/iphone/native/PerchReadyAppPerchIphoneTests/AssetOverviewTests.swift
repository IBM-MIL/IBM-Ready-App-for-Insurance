/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/


import UIKit
import XCTest

class AssetOverviewTests: XCTestCase {
    
    var vc: AssetsViewController!
    var collectionView: UICollectionView?
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType))
        self.vc = storyboard.instantiateViewControllerWithIdentifier("AssetOverview") as! AssetsViewController
        vc.loadView()

    }

    func testCollectionViewDatasource() {
        XCTAssertTrue(vc.conformsToProtocol(UICollectionViewDataSource), "Collection view does not conform to the UICollectionViewDataSource protocol")
        XCTAssertNotNil(vc.assetCollectionView.dataSource, "Collection View datasource is nil")
    }
    
    func testCollectionViewDelegate() {
        XCTAssertTrue(vc.conformsToProtocol(UICollectionViewDelegate), "Collection view does not conform to the UICollectionViewDelegate protocol")
        XCTAssertNotNil(vc.assetCollectionView.delegate, "Collection View delegate is nil")
    }

    func testTableViewNumberOfRows() {
        let expectedNumber = 4
        XCTAssertTrue(vc.collectionView(vc.assetCollectionView, numberOfItemsInSection: 0) == expectedNumber, "CollectionView has \(vc.collectionView(vc.assetCollectionView, numberOfItemsInSection: 0)) items, but it should have \(expectedNumber)")
    }
    
    func testCellSizing() {
        
        if UIScreen.mainScreen().bounds.size.width < 768 {
            let indexPath = NSIndexPath(forItem: 0, inSection: 0)
            let cell = vc.assetCollectionView.dataSource?.collectionView(vc.assetCollectionView, cellForItemAtIndexPath: indexPath) as! AssetCollectionViewCell
            
            let expectedWidth = cell.size.height / 1.03
            XCTAssertEqual(cell.size.width, expectedWidth, "Expected width is different from actual cell width")
            
            let expectedHeight = cell.size.width * 1.03
            XCTAssertEqual(cell.size.height, expectedHeight, "Expected height is different from actual cell height")
        }
    }
    
    func testCellContent() {
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        let cell = vc.assetCollectionView.dataSource?.collectionView(vc.assetCollectionView, cellForItemAtIndexPath: indexPath) as! AssetCollectionViewCell
        
        let oldImage = cell.backgroundCircleImageView.image
        cell.swapAssetState(2)
        XCTAssertNotEqual(oldImage!, cell.backgroundCircleImageView.image!, "Cell Background Images are equal even after image swap")

        cell.setIconForDevice(DeviceType.SewerSystem, sensorStatus:0)
        let oldIcon = cell.assetIconImageView.image
        cell.setIconForDevice(DeviceType.AirConditioning, sensorStatus:0)
        XCTAssertNotEqual(oldIcon!, cell.assetIconImageView.image!, "Asset Icon Images are equal even after setting a different icon")
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
   
}
