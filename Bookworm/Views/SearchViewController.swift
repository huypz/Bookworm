import UIKit

class SearchViewController: UITableViewController {

    var documentStore: DocumentStore!
    var deckStore: DeckStore!
    
    let documentDataSource = DocumentDataSource()
    let deckDataSource = DeckDataSource()
    
    let sections: [String] = ["Books", "Decks"]
    var items: [[Any]] = [[Document](), [Deck]()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SearchTableViewHeader.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Search"
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
    
    private func updateDocumentDataSource() {
        documentStore.fetchDocuments { (result) in
            switch result {
            case let .success(documents):
                self.documentDataSource.documents = documents
            case let .failure(error):
                print("Error fetching documents: \(error)")
                self.documentDataSource.documents.removeAll()
            }
            self.items[0] = self.documentDataSource.documents
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
            self.items[1] = self.deckDataSource.decks
            self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        }
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
