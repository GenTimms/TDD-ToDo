import XCTest
@testable import ToDo
import CoreLocation

class DetailViewControllerTests: XCTestCase {
    var sut: DetailViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        super.tearDown()
        sut.itemInfo?.0.removeAll()
    }
    
    func test_HasTitleLabel() {
        let titleLabelIsSubView = sut.titleLabel?.isDescendant(of: sut.view) ?? false
        
        XCTAssertTrue(titleLabelIsSubView)
    }
    
    func test_HasDueDateLabel() {
        let dueDateLabelIsSubView = sut.dueDateLabel?.isDescendant(of: sut.view) ?? false
        
        XCTAssertTrue(dueDateLabelIsSubView)
    }
    
    func test_LocationLabel() {
        let locationLabelIsSubView = sut.locationLabel?.isDescendant(of: sut.view) ?? false
        
        XCTAssertTrue(locationLabelIsSubView)
    }
    
    func test_HasDescriptionLabel() {
        let descriptionLabelIsSubView = sut.descriptionLabel?.isDescendant(of: sut.view) ?? false
        
        XCTAssertTrue(descriptionLabelIsSubView)
    }
    
    func test_HasMapView() {
        let mapViewIsSubView = sut.mapView?.isDescendant(of: sut.view) ?? false
        XCTAssertTrue(mapViewIsSubView)
    }
    
    func  test_SettingItemInfo_SetsTextsToLabels() {
        let coordinate = CLLocationCoordinate2DMake(51.2277, 6.7735)
        
        let location = Location(name: "Foo", coordinate: coordinate)
        let item = ToDoItem(title: "Bar",
                            itemDescription: "Baz",
                            timestamp: 1456150025,
                            location: location)
        
        let itemManager = ItemManager()
        itemManager.add(item)
        
        sut.itemInfo = (itemManager, 0)
        sut.beginAppearanceTransition(true, animated: true)
        sut.endAppearanceTransition()
        //in reality labels should be in different tests?
        XCTAssertEqual(sut.titleLabel.text, "Bar")
        XCTAssertEqual(sut.dueDateLabel.text, "22/02/2016")
        XCTAssertEqual(sut.locationLabel.text, "Foo")
        XCTAssertEqual(sut.descriptionLabel.text, "Baz")
        XCTAssertEqual(sut.mapView.centerCoordinate.latitude, coordinate.latitude, accuracy: 0.001)
        XCTAssertEqual(sut.mapView.centerCoordinate.longitude, coordinate.longitude, accuracy: 0.001)
    }
    
    func test_CheckItem_ChecksItemInItemManager() {
        let itemManager = ItemManager()
        itemManager.add(ToDoItem(title: "Foo"))
        
        sut.itemInfo = (itemManager, 0)
        sut.checkItem()
        
        XCTAssertEqual(itemManager.toDoCount, 0)
        XCTAssertEqual(itemManager.doneCount, 1)
    }
    
}





