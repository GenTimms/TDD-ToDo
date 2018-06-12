import XCTest
import CoreLocation
@testable import ToDo

class InputViewControllerTests: XCTestCase {
    var sut: InputViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "InputViewController") as! InputViewController
        sut.loadViewIfNeeded()
        
    }
    
    override func tearDown() {
        sut.itemManager?.removeAll()
        super.tearDown()
    }
    
    func test_HasTitleTextField() {
        let titleTextfieldIsSubView = sut.titleTextField?.isDescendant(of: sut.view) ?? false
        XCTAssertTrue(titleTextfieldIsSubView)
    }
    
    func test_HasDateTextField() {
        let dateTextfieldIsSubView = sut.dateTextField?.isDescendant(of: sut.view) ?? false
        XCTAssertTrue(dateTextfieldIsSubView)
    }
    
    func test_HasLocationTextField() {
        let locationTextfieldIsSubView = sut.locationTextField?.isDescendant(of: sut.view) ?? false
        XCTAssertTrue(locationTextfieldIsSubView)
    }
    
    func test_HasAddressTextField() {
        let addressTextfieldIsSubView = sut.addressTextField?.isDescendant(of: sut.view) ?? false
        XCTAssertTrue(addressTextfieldIsSubView)
    }
    
    func test_HasDescriptionTextField() {
        let descriptionTextfieldIsSubView = sut.descriptionTextField?.isDescendant(of: sut.view) ?? false
        XCTAssertTrue(descriptionTextfieldIsSubView)
    }
    
    func test_HasSaveButton() {
        let saveButtonIsSubView = sut.saveButton?.isDescendant(of: sut.view) ?? false
        XCTAssertTrue(saveButtonIsSubView)
    }

    func test_HasCancelButton() {
        let cancelButtonIsSubView = sut.cancelButton?.isDescendant(of: sut.view) ?? false
        XCTAssertTrue(cancelButtonIsSubView)
    }
    
    var placemark: MockPlacemark!

    func test_Save_UsesGeocoderToGetcoordinateFromAddress() {
        
        let mockSut = MockInputViewController()
        
        mockSut.titleTextField = UITextField()
        mockSut.dateTextField = UITextField()
        mockSut.locationTextField = UITextField()
        mockSut.addressTextField = UITextField()
        mockSut.descriptionTextField = UITextField()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        let timestamp = 1456012800.0
        let date = Date(timeIntervalSince1970: timestamp)
        let dateString = dateFormatter.string(from: date)

        mockSut.titleTextField.text = "Foo"
        mockSut.dateTextField.text = dateString
        mockSut.locationTextField.text = "Bar"
        mockSut.addressTextField.text = "Infinite Loop 1, Cupertino"
        mockSut.descriptionTextField.text = "Baz"
        
        let mockGeocoder = MockGeocoder()
        mockSut.geocoder = mockGeocoder
        mockSut.itemManager = ItemManager()
        
        let dismissExpectation = expectation(description: "Dismiss")
        mockSut.completionHandler = {
            dismissExpectation.fulfill()
        }
        
            mockSut.save()
        
        placemark = MockPlacemark()
        let coordinate = CLLocationCoordinate2DMake(37.3316851, -122.0300674)
        placemark.mockCoordinate = coordinate
        mockGeocoder.completionHandler?([placemark], nil)
        
        waitForExpectations(timeout: 5, handler: nil)
        
        let item = mockSut.itemManager?.item(at: 0)
        
        let testItem = ToDoItem(title: "Foo",
                                itemDescription: "Baz",
                                timestamp: timestamp,
                                location: Location(name: "Bar",
                                                   coordinate: coordinate))
        XCTAssertEqual(item, testItem)
        mockSut.itemManager?.removeAll()
    }
    
    func test_SaveButtonHasSaveAction() {
        let saveButton: UIButton = sut.saveButton
        
        guard let actions = saveButton.actions(forTarget: sut, forControlEvent: .touchUpInside) else {
            XCTFail(); return
        }
        
        XCTAssertTrue(actions.contains("save"))
    }
    
    func text_Geocoder_FetchesCoordinates() {
        let geocoderAnswered = expectation(description: "Geocoder")
        let address = "Infinate Loop 1, Cupertino"
        CLGeocoder().geocodeAddressString(address) {
            (placemarks, error) -> Void in
            
            let coordinate = placemarks?.first?.location?.coordinate
            
            guard let latitude = coordinate?.latitude else {
                XCTFail()
                return
            }
            
            guard let longitude = coordinate?.longitude else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(latitude, 37.3316, accuracy: 0.001)
            XCTAssertEqual(longitude, -122.0300, accuracy: 0.001)
            geocoderAnswered.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testSave_DismissesViewController() {
        let mockInputViewController = MockInputViewController()
        mockInputViewController.titleTextField = UITextField()
        mockInputViewController.dateTextField = UITextField()
        mockInputViewController.locationTextField = UITextField()
        mockInputViewController.addressTextField = UITextField()
        mockInputViewController.descriptionTextField = UITextField()
        mockInputViewController.titleTextField.text = "Test Title"
        
        mockInputViewController.save()
        XCTAssertTrue(mockInputViewController.dismissGotCalled)
    }

    
    
}

extension InputViewControllerTests {
    class MockGeocoder: CLGeocoder {
        var completionHandler: CLGeocodeCompletionHandler?
        
        override func geocodeAddressString(
            _ addresString: String,
            completionHandler: @escaping CLGeocodeCompletionHandler) {
            self.completionHandler = completionHandler
        }
    }
    
    class MockPlacemark: CLPlacemark {
        var mockCoordinate: CLLocationCoordinate2D?
        
        override var location: CLLocation? {
        guard let coordinate = mockCoordinate else {
        return CLLocation() }
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
    }
    
    class MockInputViewController: InputViewController {
        var dismissGotCalled = false
        var completionHandler: (() -> Void)?
        
        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            dismissGotCalled = true
            completionHandler?()
        }
    }
}






