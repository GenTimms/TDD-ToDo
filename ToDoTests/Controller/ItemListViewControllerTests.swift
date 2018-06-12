//
//  ItemListViewControllerTests.swift
//  ToDoTests
//
//  Created by Genevieve Timms on 06/05/2018.
//  Copyright © 2018 GMJT. All rights reserved.
//

import XCTest
@testable import ToDo

class ItemListViewControllerTests: XCTestCase {
    var sut: ItemListViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ItemListViewController")
        sut = viewController as! ItemListViewController
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_TabeView_AfterViewDidLoad_IsNotNil() {
        XCTAssertNotNil(sut.tableView)
    }
    
    func test_LoadingView_SetsTableViewDataSource() {
        XCTAssertTrue(sut.tableView.dataSource is ItemListDataProvider)
    }
    
    func test_LoadingView_SetsTableViewDelegate() {
        XCTAssertTrue(sut.tableView.delegate is ItemListDataProvider)
    }
    
    func test_LoadingView_DataSourceEqualDelegate() {
    XCTAssertEqual(sut.tableView.dataSource as? ItemListDataProvider, sut.tableView.delegate as? ItemListDataProvider)
    }
    
    func test_ItemListViewController_HasAddBarButtonWithSelfAsTarget() {
        let target = sut.navigationItem.rightBarButtonItem?.target
        XCTAssertEqual(target as? UIViewController, sut)
    }
    
    func addItem() {
        XCTAssertNil(sut.presentedViewController)
        
        guard let addButton = sut.navigationItem.rightBarButtonItem else {
            XCTFail(); return }
        guard let action = addButton.action else { XCTFail(); return }
        
        UIApplication.shared.keyWindow?.rootViewController = sut
        
        sut.performSelector(onMainThread: action, with: addButton, waitUntilDone: true)
    }
    
    func test_AddItem_PresentsAddItemViewController() {

        addItem()
        XCTAssertNotNil(sut.presentedViewController)
        XCTAssertTrue(sut.presentedViewController is InputViewController)
        
        let inputViewController = sut.presentedViewController as! InputViewController
        XCTAssertNotNil(inputViewController.titleTextField)
    }
    
    func testItemListVC_SharesItemManagerWithInputVC() {

        addItem()
        guard let inputViewController = sut.presentedViewController as? InputViewController else { XCTFail(); return }
    guard let inputItemManager = inputViewController.itemManager else { XCTFail(); return }
    XCTAssertTrue(sut.itemManager === inputItemManager)
    }
    
    func test_AddItem_reloadsTableView() {
     sut.tableView = MockTableView()
        sut.beginAppearanceTransition(true, animated: true)
        sut.endAppearanceTransition()
        
        let mockTableView = sut.tableView as? MockTableView
        
        XCTAssertTrue(mockTableView?.reloadDataGotCalled ?? false)
    }
    
    func testItemSelectedNotification_PushedDetailVC() {
     let mockNavigationController = MockNavigationController(rootViewController: sut)
         UIApplication.shared.keyWindow?.rootViewController = mockNavigationController
        
        sut.loadViewIfNeeded()
        sut.itemManager.add(ToDoItem(title: "foo"))
        sut.itemManager.add(ToDoItem(title: "bar"))
        
        NotificationCenter.default.post(name: NSNotification.Name("ItemSelectedNotification"), object: self, userInfo: ["index": 1])
        
        guard let detailViewController = mockNavigationController.lastPushedViewController as? DetailViewController else {
            return XCTFail() }
        
        guard let detailItemManager = detailViewController.itemInfo?.0 else {
            return XCTFail() }
        
        guard let index = detailViewController.itemInfo?.1 else { return XCTFail() }
        
        detailViewController.loadViewIfNeeded()
        
        XCTAssertNotNil(detailViewController.titleLabel)
        XCTAssertTrue(detailItemManager === sut.itemManager)
        XCTAssertEqual(index, 1)
        
    }
    
    func test_ViewDidLoad_SetsItemManagerToDataProvider() {
        XCTAssertTrue(sut.itemManager === sut.dataProvider.itemManager)
    }
}
extension ItemListViewControllerTests {
    class MockNavigationController : UINavigationController {
        var lastPushedViewController: UIViewController?
        
        override func pushViewController(_ viewController: UIViewController, animated: Bool) {
            lastPushedViewController = viewController
            super.pushViewController(viewController, animated: animated)
        }
    }
    
    class MockTableView: UITableView {
        var reloadDataGotCalled = false
        
        override func reloadData() {
            super.reloadData()
            reloadDataGotCalled = true
        }
    }
}
