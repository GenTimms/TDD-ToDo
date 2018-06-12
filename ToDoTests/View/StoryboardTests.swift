import XCTest
@testable import ToDo

class StoryboardTests: XCTestCase {
    var storyboard: UIStoryboard!
    
    override func setUp() {
        super.setUp()
        storyboard = UIStoryboard(name: "Main", bundle: nil)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test_InitialViewController_IsItemListViewController() {
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        let rootViewController = navigationController.viewControllers[0]
        
        XCTAssertTrue(rootViewController is ItemListViewController)
        
    }
}
