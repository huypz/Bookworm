import CoreData
import UIKit

class FlashcardsViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var addButtonItem: UIBarButtonItem!
    
    var deckStore: DeckStore!
    var deck: Deck!
    
    var selectedFlashcard: Flashcard?
    
    let dataSource = FlashcardDataSource()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        navigationItem.rightBarButtonItem = editButtonItem
        editButtonItem.action = #selector(toggleEditingMode)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        dataSource.delegate = self
        dataSource.deckStore = deckStore
        dataSource.deck = deck
        tableView.dataSource = dataSource
        updateFlashcards()

        tableView.rowHeight = 384
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "\(deck.title!)"
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "addFlashcard":
            let flashcardAddViewController = (segue.destination as! UINavigationController).topViewController as! FlashcardAddViewController
            flashcardAddViewController.deckStore = deckStore
            flashcardAddViewController.deck = deck
            flashcardAddViewController.delegate = self
        case "editFlashcard":
            let flashcardEditViewController = (segue.destination as! UINavigationController).topViewController as! FlashcardEditViewController
            flashcardEditViewController.flashcard = selectedFlashcard
            flashcardEditViewController.delegate = self
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    @objc private func dismissKeyboard() {
        searchBar.endEditing(true)
    }
    
    private func updateNavigationItem() {
        if isEditing {
            navigationItem.setRightBarButtonItems([editButtonItem, addButtonItem], animated: true)
        }
        else {
            navigationItem.setRightBarButtonItems([editButtonItem], animated: true)
        }
    }
    
    func updateFlashcards() {
        deckStore.fetchFlashcards { (result) in
            switch result {
            case .success(_):
                guard let deckFlashcards = self.deck.flashcards?.allObjects as? [Flashcard] else {
                    return
                }
                self.dataSource.flashcards = deckFlashcards
                self.dataSource.filteredFlashcards = deckFlashcards 
            case let .failure(error):
                print("Error fetching flashcards: \(error)")
            }
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    @IBAction func toggleEditingMode(_ sender: Any?) {
        if isEditing {
            setEditing(false, animated: true)
        }
        else {
            setEditing(true, animated: true)
        }
        updateNavigationItem()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            dataSource.filteredFlashcards = dataSource.flashcards
        }
        else {
            let filteredFlashcards = dataSource.flashcards.filter({ (flashcard) in
                flashcard.term!.lowercased().contains(searchText.lowercased())
            })
            dataSource.filteredFlashcards = filteredFlashcards
        }
        tableView.reloadData()
    }
}
