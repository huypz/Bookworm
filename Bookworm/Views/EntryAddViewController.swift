import UIKit

class EntryAddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var addButtonItem: UIBarButtonItem!
    
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var termTextField: UITextField!
    @IBOutlet var definitionTextView: UITextView!
    
    var term: String?
    var definition: String?
    
    var decks = [Deck]()
    var deckStore: DeckStore!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Add Flashcard"
        
        pickerView.layer.borderColor = UIColor.lightGray.cgColor
        pickerView.layer.borderWidth = 1
        
        termTextField.leftView = UIView(frame: CGRectMake(0, 0, 4, 0))
        termTextField.leftViewMode = .always
        termTextField.layer.borderColor = UIColor.lightGray.cgColor
        termTextField.layer.borderWidth = 1
        
        definitionTextView.layer.borderColor = UIColor.lightGray.cgColor
        definitionTextView.layer.borderWidth = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        updateDataSource()
        
        termTextField.text = term
        definitionTextView.text = definition
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
        
        let deck = decks[pickerView.selectedRow(inComponent: 0)]
        
        let context = deckStore.persistentContainer.viewContext
        let term = termTextField.text
        let definition = definitionTextView.text
        let meaning = Meaning(context: context)
        meaning.setValue(definition, forKey: "definition")

        let flashcard = Flashcard(context: context)
        flashcard.setValue(term, forKey: "term")
        flashcard.addToMeanings(meaning)
        deckStore.addFlashcard(flashcard: flashcard, to: deck)
        
        navigationController?.popViewController(animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return decks.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return decks[row].title
    }
    
    func updateDataSource() {
        deckStore.fetchDecks { (result) in
            switch result {
            case let .success(decks):
                self.decks = decks
                if decks.count == 0 {
                    self.addButtonItem.isEnabled = false
                    let alert = UIAlertController(title: "No decks found", message: "Please create a new deck using the Decks tab.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
                        alert.dismiss(animated: true, completion: nil)
                    })
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            case let .failure(error):
                print("Error fetching decks: \(error)")
                self.decks.removeAll()
            }
            self.pickerView.reloadAllComponents()
        }
    }
}
