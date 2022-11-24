import UIKit

class EntriesViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var doneButtonItem: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    
    var term: String!
    var store: EntryStore!
    
    var selectedDefinition: String?
    var audio: URL?
    
    var deckStore: DeckStore!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Dictionary"
        
        searchBar.searchTextField.autocapitalizationType = .none
        searchBar.searchTextField.text = term
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 96
        
        updateEntries(for: term)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "addEntry":
            let entryAddViewController = segue.destination as! EntryAddViewController
            entryAddViewController.deckStore = deckStore
            entryAddViewController.term = term
            entryAddViewController.definition = selectedDefinition
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntryCell", for: indexPath) as! EntryCell
        
        if let entry = store.entries.first {
            cell.delegate = self
            let definition = entry.meanings[indexPath.section].definitions[indexPath.row]
            cell.termLabel.text = term
            cell.partOfSpeechLabel.text = entry.meanings[indexPath.section].partOfSpeech
            cell.definitionLabel.text = definition.definition
            cell.audio = audio
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let entry = store.entries.first {
            return entry.meanings[section].definitions.count
        }
        else {
            return 0
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let entry = store.entries.first {
            return entry.meanings.count
        }
        return 0
    }
    
    @IBAction func done(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        term = searchBar.searchTextField.text ?? ""
        guard !term.isEmpty else { return }
    
        updateEntries(for: term)
    }
    
    func updateEntries(for term: String) {
        audio = nil
        
        store.fetchEntries(for: term) { (result) -> Void in
            switch result {
            case let .success(entries):
                self.store.entries = entries
                self.store.entries.forEach { (entry) in
                    if self.audio == nil {
                        entry.phonetics.forEach { (phonetic) in
                            if let audioString = phonetic.audio,
                               !audioString.isEmpty {
                                self.audio = URL(string: audioString)
                            }
                        }
                    }
                    entry.meanings.forEach { (meaning) in
                        self.store.definitions.append(contentsOf: meaning.definitions)
                    }
                }
                self.tableView.reloadData()
                self.tableView.visibleCells.forEach { (cell) in
                    let entryCell = cell as! EntryCell
                    entryCell.audioButton.isEnabled = self.audio != nil
                }
            case let .failure(error):
                print("Error fetching dictionary information: \(error)")
            }
        }
    }
}
