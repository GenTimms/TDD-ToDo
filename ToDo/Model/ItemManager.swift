  import UIKit

class ItemManager: NSObject {
    
    var toDoCount: Int { return toDoItems.count }
    var doneCount: Int { return doneItems.count }
    private var toDoItems: [ToDoItem] = []
    private var doneItems: [ToDoItem] = []

    //MARK: - PUBLIC API
    
    func add(_ item: ToDoItem) {
        if !toDoItems.contains(item) {
        toDoItems.append(item)
        }
    }
    
    func item(at index: Int) -> ToDoItem {
        return toDoItems[index]
    }
    
    func checkItem(at index: Int) {
        let item = toDoItems.remove(at: index)
        doneItems.append(item)
    }
    
    func uncheckItem(at index: Int) {
        let item = doneItems.remove(at: index)
        toDoItems.append(item)
    }
    
    func doneItem(at index: Int) -> ToDoItem {
        return doneItems[index]
    }
    
    func removeAll() {
        toDoItems.removeAll()
        doneItems.removeAll()
    }
    
    //MARK: - PERSISTENCE
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: .UIApplicationWillResignActive, object: nil)
        
        if let nsToDoItems = NSArray(contentsOf: toDoPathURL), let toDoItems = nsToDoItems[0] as? NSArray, let doneItems = nsToDoItems[1] as? NSArray {
            for dict in toDoItems {
                if let toDoItem = ToDoItem(dict: dict as! [String: Any]) {
                    self.toDoItems.append(toDoItem)
                }
            }
            for dict in doneItems {
                if let doneItem = ToDoItem(dict: dict as! [String: Any]) {
                    self.doneItems.append(doneItem)
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        save()
    }
    
    var toDoPathURL: URL {
        let fileURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        guard let documentURL = fileURLs.first else {
            print("Something went wrong. Documents url could not be found")
            fatalError()
        }
        return documentURL.appendingPathComponent("toDoItems.plist")
    }
    

    @objc func save() {
        let nsToDoItems = [toDoItems.map {$0.plistDict}, doneItems.map {$0.plistDict}]
        
        guard nsToDoItems.count > 0 else {
            try? FileManager.default.removeItem(at: toDoPathURL)
            return
        }
        do {
            let plistData = try PropertyListSerialization.data(fromPropertyList: nsToDoItems, format: PropertyListSerialization.PropertyListFormat.xml, options: PropertyListSerialization.WriteOptions(0))
            try plistData.write(to: toDoPathURL, options: Data.WritingOptions.atomic)
        } catch {
            print(error)
        }
    }
}
