import Foundation

struct ToDoItem : Equatable {
    let title: String
    let itemDescription: String?
    let timestamp: Double?
    var location: Location?
    
    private let titleKey = "titleKey"
    private let itemDescriptionKey = "itemDescriptionKey"
    private let timestampKey = "timestampKey"
    private let locationKey = "locationKey"
    
    var plistDict: [String: Any] {
        var dict = [String: Any]()
        
        dict[titleKey] = title
        
        if let description = itemDescription {
            dict[itemDescriptionKey] = description
            
        }
        if let timestamp = timestamp {
            dict[timestampKey] = timestamp
        }
        
        if let location = location {
            dict[locationKey] = location.plistDict
        }
        
        return dict
    }
    
    init?(dict: [String: Any]) {
        guard let title = dict[titleKey] as? String else {
            return nil
        }
        
        self.title = title
        self.itemDescription = dict[itemDescriptionKey] as? String
        self.timestamp = dict[timestampKey] as? Double
        
        if let locationDict = dict[locationKey] as? [String: Any] {
         self.location = Location(dict: locationDict)
        } else {
            self.location = nil
        }
    }
    
    init(title: String, itemDescription: String? = nil, timestamp: Double? = nil, location: Location? = nil) {
        
        self.title = title
        self.itemDescription = itemDescription
        self.timestamp = timestamp
        self.location = location
    }
}

func ==(lhs: ToDoItem, rhs: ToDoItem) -> Bool {
    if lhs.location?.name != rhs.location?.name || lhs.timestamp != rhs.timestamp || lhs.itemDescription != rhs.itemDescription || lhs.title != rhs.title {
        return false
    }
    return true
}
