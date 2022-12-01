import UIKit

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Books, Decks"
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none
        return searchBar
    }()

    var documentStore: DocumentStore!
    var deckStore: DeckStore!
    
    let documentDataSource = DocumentDataSource()
    let deckDataSource = DeckDataSource()
    
    let sections: [String] = ["Books", "Decks"]
    var items: [[Any]] = [[Document](), [Deck]()]
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showDocument":
            if let row = tableView.indexPathForSelectedRow?.row {
                if let document = items[0][row] as? Document {
                    document.lastAccessed = Date()
                    let readerViewController = segue.destination as! ReaderViewController
                    readerViewController.deckStore = deckStore
                    readerViewController.document = document
                    readerViewController.hidesBottomBarWhenPushed = true
                    readerViewController.navigationController?.hidesBarsOnTap = true
                }
            }
        case "showDeck":
            if let row = tableView.indexPathForSelectedRow?.row {
                if let deck = items[1][row] as? Deck {
                    let flashcardsViewController = segue.destination as! FlashcardsViewController
                    flashcardsViewController.deck = deck
                    flashcardsViewController.deckStore = deckStore
                }
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        tableView.register(SearchTableViewHeader.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")

        tableView.delegate = self
        tableView.dataSource = self
        
        navigationItem.title = ""
        navigationItem.titleView = searchBar
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        items[0].removeAll()
        items[1].removeAll()
        updateDocumentDataSource()
        updateDeckDataSource()
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchDocumentCell", for: indexPath) as! SearchDocumentCell
            let document = items[indexPath.section][indexPath.row] as! Document
            cell.titleLabel.text = document.title
            cell.descLabel.text = "Book"
            cell.coverImageView.image = documentStore.imageStore.image(forKey: document.id!)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchDeckCell", for: indexPath) as! SearchDeckCell
            let deck = items[indexPath.section][indexPath.row] as! Deck
            cell.titleLabel.text = deck.title
            return cell
        default:
            print("Unexpected index path in SearchViewController cellForRowAt")
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 192.0
        case 1:
            return 64.0
        default:
            print("Unexpected index path in SearchViewController heightForRowAt")
            return 0.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! SearchTableViewHeader
        view.titleLabel.text = sections[section]
        return view
    }

    @objc private func dismissKeyboard() {
        searchBar.endEditing(true)
    }
    
    private func updateDocumentDataSource() {
        documentStore.fetchDocuments { (result) in
            switch result {
            case let .success(documents):
                self.documentDataSource.documents = documents
                self.documentDataSource.filteredDocuments = documents
            case let .failure(error):
                print("Error fetching documents: \(error)")
                self.documentDataSource.documents.removeAll()
                self.documentDataSource.filteredDocuments.removeAll()
            }
            self.items[0] = self.documentDataSource.filteredDocuments
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    private func updateDeckDataSource() {
        deckStore.fetchDecks { (result) in
            switch result {
            case let .success(decks):
                self.deckDataSource.decks = decks
                self.deckDataSource.filteredDecks = decks
            case let .failure(error):
                print("Error fetching decks: \(error)")
                self.deckDataSource.decks.removeAll()
                self.deckDataSource.filteredDecks.removeAll()
            }
            self.items[1] = self.deckDataSource.filteredDecks
            self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
    }
    
    private func reloadData() {
        items[0] = documentDataSource.filteredDocuments
        items[1] = deckDataSource.filteredDecks
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            documentDataSource.filteredDocuments = documentDataSource.documents
            deckDataSource.filteredDecks = deckDataSource.decks
        }
        else {
            let filteredDocuments = documentDataSource.documents.filter({ (document) in
                document.title!.lowercased().contains(searchText.lowercased())
            })
            documentDataSource.filteredDocuments = filteredDocuments
            let filteredDecks = deckDataSource.decks.filter({ (deck) in
                deck.title!.lowercased().contains(searchText.lowercased())
            })
            deckDataSource.filteredDecks = filteredDecks
        }
        reloadData()
    }
}

class SearchDocumentCell: UITableViewCell {
    
    @IBOutlet var coverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descLabel: UILabel!
}

class SearchDeckCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
}

class SearchTableViewHeader: UITableViewHeaderFooterView {
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
