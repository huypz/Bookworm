import UIKit
import CoreData

class FlashcardsViewController: UITableViewController {
    
    @IBOutlet var addButtonItem: UIBarButtonItem!
    
    var store: DeckStore!
    var deck: Deck!
    
    let dataSource = FlashcardDataSource()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        navigationItem.rightBarButtonItem = editButtonItem
        editButtonItem.action = #selector(toggleEditingMode)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        
        dataSource.store = store
        dataSource.deck = deck
        tableView.dataSource = dataSource
        updateFlashcards()

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "\(deck.title!)"
        tableView.reloadData()
    }
    
    private func updateNavigationItem() {
        if isEditing {
            navigationItem.setRightBarButtonItems([editButtonItem, addButtonItem], animated: true)
        }
        else {
            navigationItem.setRightBarButtonItems([editButtonItem], animated: true)
        }
    }
    
    private func updateFlashcards() {
        store.fetchFlashcards { (result) in
            switch result {
            case .success(_):
                guard let deckFlashcards = self.deck.flashcards?.allObjects as? [Flashcard] else {
                    return
                }
                self.dataSource.flashcards = deckFlashcards
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
    
    @IBAction func addFlashcard() {
        let context = store.persistentContainer.viewContext
        let term = UUID().uuidString
        let definition = "Default definition"
        let flashcard = Flashcard(context: context)
        flashcard.setValue(term, forKey: "term")
        flashcard.setValue(definition, forKey: "definition")
        store.addFlashcard(flashcard: flashcard, to: deck)
        
        updateFlashcards()
    }
}
