import UIKit

class DecksViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    
    var store: DeckStore!
    
    let dataSource = DeckDataSource()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
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
                flashcardsViewController.deckStore = store
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
                self.dataSource.filteredDecks = decks
            case let .failure(error):
                print("Error fetching decks: \(error)")
                self.dataSource.decks.removeAll()
                self.dataSource.filteredDecks.removeAll()
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! DecksTableViewHeader
        view.titleLabel.text = "Name"
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

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            dataSource.filteredDecks = dataSource.decks
        }
        else {
            let filteredDecks = dataSource.decks.filter({ (deck) in
                deck.title!.lowercased().contains(searchText.lowercased())
            })
            dataSource.filteredDecks = filteredDecks
        }
        tableView.reloadData()
    }
}

class DecksTableViewHeader: UITableViewHeaderFooterView {
    let titleLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureContents() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
    }
}
