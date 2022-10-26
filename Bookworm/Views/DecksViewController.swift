import UIKit

class DecksViewController: UITableViewController {
    
    var store: DeckStore!
    
    let dataSource = DeckDataSource()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.delegate = self
        
        tableView.dataSource = dataSource
        updateDataSource()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 48
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Decks"
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showDeck":
            if let row = tableView.indexPathForSelectedRow?.row {
                let deck = dataSource.decks[row]
                let flashcardsViewController = segue.destination as! FlashcardsViewController
                flashcardsViewController.deck = deck
                flashcardsViewController.store = store
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    private func updateDataSource() {
        store.fetchDecks { (result) in
            switch result {
            case let .success(decks):
                self.dataSource.decks = decks
            case let .failure(error):
                print("Error fetching decks: \(error)")
                self.dataSource.decks.removeAll()
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    @IBAction func addDeck(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Empty Deck", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Deck Name"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self] action in
            guard
                let textField = alert.textFields?.first,
                let title = textField.text else {
                return
            }
            
            self.store.addDeck(title: title)
            self.updateDataSource()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)
    }

}
