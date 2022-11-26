import CoreData
import UIKit

class EntryAddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet var addButtonItem: UIBarButtonItem!
    
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var termTextField: UITextField!
    @IBOutlet var definitionTextView: UITextView!
    @IBOutlet var partOfSpeechTextField: UITextField!
    @IBOutlet var audioTextField: UITextField!
    
    var term: String?
    var definition: String?
    var audio: String?
    var partOfSpeech: String?
    
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
        termTextField.autocorrectionType = .no
        termTextField.autocapitalizationType = .none
        
        definitionTextView.layer.borderColor = UIColor.lightGray.cgColor
        definitionTextView.layer.borderWidth = 1
        definitionTextView.autocapitalizationType = .none
        definitionTextView.autocorrectionType = .no
        
        partOfSpeechTextField.leftView = UIView(frame: CGRectMake(0, 0, 4, 0))
        partOfSpeechTextField.leftViewMode = .always
        partOfSpeechTextField.layer.borderColor = UIColor.lightGray.cgColor
        partOfSpeechTextField.layer.borderWidth = 1
        partOfSpeechTextField.autocorrectionType = .no
        partOfSpeechTextField.autocapitalizationType = .none
        
        audioTextField.leftView = UIView(frame: CGRectMake(0, 0, 4, 0))
        audioTextField.leftViewMode = .always
        audioTextField.layer.borderColor = UIColor.lightGray.cgColor
        audioTextField.layer.borderWidth = 1
        audioTextField.autocorrectionType = .no
        audioTextField.autocapitalizationType = .none
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        updateDataSource()
        
        termTextField.text = term
        definitionTextView.text = definition
        partOfSpeechTextField.text = partOfSpeech
        audioTextField.text = audio
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
        term = termTextField.text
        definition = definitionTextView.text
        partOfSpeech = partOfSpeechTextField.text
        audio = audioTextField.text
        
        let newFlashcard = NSEntityDescription.insertNewObject(forEntityName: "Flashcard", into: context)
        newFlashcard.setValue(term, forKey: "term")
        newFlashcard.setValue(definition, forKey: "definition")
        newFlashcard.setValue(audio, forKey: "audio")
        newFlashcard.setValue(partOfSpeech, forKey: "partOfSpeech")
        deckStore.addFlashcard(flashcard: newFlashcard as! Flashcard, to: deck)
        
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
