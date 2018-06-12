import UIKit

class ItemListViewController: UIViewController {
    
    let itemManager = ItemManager()

    @IBOutlet var tableView: UITableView!
    @IBOutlet var dataProvider: (UITableViewDataSource & UITableViewDelegate & ItemManagerSettable)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataProvider
        tableView.delegate = dataProvider
        dataProvider.itemManager = itemManager
        
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(showDetails(sender:)),
        name:NSNotification.Name("ItemSelectedNotification"),
        object: nil)
    }
    
    @objc func showDetails(sender: NSNotification) {
        guard let index = sender.userInfo?["index"] as? Int else {
            fatalError()
        }
        
        if let nextViewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            nextViewController.itemInfo = (itemManager, index)
            navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func addItem(_ sender: UIBarButtonItem) {
        if let nextViewController = storyboard?.instantiateViewController(withIdentifier: "InputViewController") as? InputViewController       {
                nextViewController.itemManager = itemManager
                present(nextViewController, animated: true, completion: nil)
        }
    }
}
