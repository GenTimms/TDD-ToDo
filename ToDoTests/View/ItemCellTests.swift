import XCTest
@testable import ToDo

class ItemCellTests: XCTestCase {
    
    var cell: ItemCell!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ItemListViewController") as! ItemListViewController
        
        controller.loadViewIfNeeded()
        
        let tableView = controller.tableView
        let dataSource = FakeDataSource()
        tableView?.dataSource = dataSource
        
        cell = tableView?.dequeueReusableCell(withIdentifier: "ItemCell", for: IndexPath(row: 0, section: 0)) as! ItemCell
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_HasNameLabel() {
        XCTAssertTrue(cell.titleLabel.isDescendant(of: cell.contentView))
    }
    
    func test_HasLocationLabel() {
        XCTAssertTrue(cell.locationLabel.isDescendant(of: cell.contentView))
    }
    
    func test_HasDateLabel() {
        XCTAssertTrue(cell.dateLabel.isDescendant(of: cell.contentView))
    }
    
    func test_ConfigCell_setsTitle() {
        cell.configCell(with: ToDoItem(title: "Foo"))
        
        XCTAssertEqual(cell.titleLabel.text, "Foo")
    }
    
    func test_ConfigCell_SetsDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let date = dateFormatter.date(from: "08/05/2018")
        let timestamp = date?.timeIntervalSince1970
        
        cell.configCell(with: ToDoItem(title: "Foo", timestamp: timestamp))
        XCTAssertEqual(cell.dateLabel.text, "08/05/2018")
    }
    
    func test_ConfigCell_SetsLocation() {
        
        let location = Location(name: "Everywhere")
        cell.configCell(with: ToDoItem(title: "Foo", location: location))
        XCTAssertEqual(cell.locationLabel.text, "Everywhere")
    }
    
    func test_Title_WhenItemIsChecked_IsStrokeThough() {
        let location = Location(name: "Bar")
        let item = ToDoItem(title: "Foo",
                            itemDescription: nil,
                            timestamp: 1456150025,
                            location: location)
        
        cell.configCell(with: item, checked: true)
        
        let attributedString = NSAttributedString(
            string: "Foo",
            attributes: [NSAttributedStringKey.strikethroughStyle: NSUnderlineStyle.styleSingle.rawValue])
        
        XCTAssertEqual(cell.titleLabel.attributedText, attributedString)
        XCTAssertNil(cell.locationLabel.text)
        XCTAssertNil(cell.dateLabel.text)
}
}
extension ItemCellTests {
    class FakeDataSource: NSObject, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return UITableViewCell()
        }
    }
}
