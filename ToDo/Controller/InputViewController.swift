import UIKit
import CoreLocation

class InputViewController: UIViewController {
    
    lazy var geocoder = CLGeocoder()
    var itemManager: ItemManager?


    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var dateTextField: UITextField!
    @IBOutlet var locationTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var descriptionTextField: UITextField!
    
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }()

    @IBAction func save() {
        guard let titleString = titleTextField.text, titleString.count > 0 else { return }
        let date: Date?
        if let dateText = self.dateTextField.text, dateText.count > 0 {
            date = dateFormatter.date(from: dateText)
        } else {
            date = nil
        }
        let descriptionString = descriptionTextField.text
        var item = ToDoItem(title: titleString,
                            itemDescription: descriptionString,
                            timestamp: date?.timeIntervalSince1970,
                            location: nil)
        
        if let locationName = locationTextField.text, locationName.count > 0 {
            if let address = addressTextField.text, address.count > 0 {
                
                geocoder.geocodeAddressString(address) {
                    [unowned self] (placeMarks, error) -> Void in
                    
                    let placeMark = placeMarks?.first
                    
                    item.location = Location(name: locationName, coordinate: placeMark?.location?.coordinate)
                    DispatchQueue.main.async(execute: {
                        self.itemManager?.add(item)
                        self.dismiss(animated: true)
                    })
                }
            } else {
                item.location = Location(name: locationName)
              itemManager?.add(item)
               dismiss(animated: true)
            }
        } else {
           itemManager?.add(item)
            dismiss(animated: true)
        }
        
    }
}
