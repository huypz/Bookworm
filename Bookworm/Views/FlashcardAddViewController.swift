import UIKit

class FlashcardAddViewController: UIViewController {
    
    @IBOutlet var addButtonItem: UIBarButtonItem!
    @IBOutlet var cancelButtonItem: UIBarButtonItem!
    
    @IBOutlet var termTextField: UITextField!
    @IBOutlet var definitionTextView: UITextView!
    
    var store: DeckStore!
    var deck: Deck!
    var delegate: FlashcardsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Add Flashcard"
        
        termTextField.leftView = UIView(frame: CGRectMake(0, 0, 4, 0))
        termTextField.leftViewMode = .always
        termTextField.layer.borderColor = UIColor.lightGray.cgColor
        termTextField.layer.borderWidth = 1
        
        definitionTextView.layer.borderColor = UIColor.lightGray.cgColor
        definitionTextView.layer.borderWidth = 1
    }
    
    @IBAction func addFlashcard(_ sender: UIBarButtonItem) {
        guard termTextField.text!.count > 0 else {
            let alert = UIAlertController(title: "Empty text field", message: "Term cannot be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
                alert.dismiss(animated: true, completion: nil)
            })
            present(alert, animated: true, completion: nil)
            return
        }
        
        let context = store.persistentContainer.viewContext
        let term = termTextField.text
        let definition = definitionTextView.text
        let flashcard = Flashcard(context: context)
        flashcard.setValue(term, forKey: "term")
        flashcard.setValue(definition, forKey: "definition")
        store.addFlashcard(flashcard: flashcard, to: deck)
        delegate.updateFlashcards()
        
        cancel(sender)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
