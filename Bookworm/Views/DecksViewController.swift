import UIKit

class DecksViewController: UITableViewController {
    
    var store: DeckStore!
    
    let dataSource = DeckDataSource()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(DecksTableViewHeader.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
    
        tableView.delegate = self
        
        dataSource.store = store
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! DecksTableViewHeader
        view.title.text = "Name"
        return view
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
            
            guard title.count > 0 else {
                let alertEmpty = UIAlertController(title: "Empty text field", message: "Deck title cannot be empty", preferredStyle: .alert)
                alertEmpty.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
                    alertEmpty.dismiss(animated: true, completion: nil)
                    alert.dismiss(animated: true, completion: nil)
                })
                present(alertEmpty, animated: true, completion: nil)
                return
            }
            
            self.store.addDeck(title: title)
            self.updateDataSource()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true, completion: nil)
    }

}

class DecksTableViewHeader: UITableViewHeaderFooterView {
    let title = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureContents() {
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        contentView.addSubview(title)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
    }
}
