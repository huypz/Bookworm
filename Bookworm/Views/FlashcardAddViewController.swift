import CoreData
import UIKit

class FlashcardAddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var addButtonItem: UIBarButtonItem!
    @IBOutlet var cancelButtonItem: UIBarButtonItem!
    
    @IBOutlet var termTextField: UITextField!
    @IBOutlet var definitionTextView: UITextView!
    @IBOutlet var partOfSpeechTextField: UITextField!
    @IBOutlet var audioTextField: UITextField!
    @IBOutlet var imageView: UIImageView!
    
    var deckStore: DeckStore!
    var deck: Deck!
    var delegate: FlashcardsViewController!
    
    var id: String = UUID().uuidString
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = "Add Flashcard"
        
        termTextField.leftView = UIView(frame: CGRectMake(0, 0, 4, 0))
        termTextField.leftViewMode = .always
        termTextField.layer.borderColor = UIColor.lightGray.cgColor
        termTextField.layer.borderWidth = 1
        termTextField.autocorrectionType = .no
        termTextField.autocapitalizationType = .none
        
        definitionTextView.layer.borderColor = UIColor.lightGray.cgColor
        definitionTextView.layer.borderWidth = 1
        definitionTextView.autocorrectionType = .no
        definitionTextView.autocapitalizationType = .none
        
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
    
    @IBAction func choosePhotoSource(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.modalPresentationStyle = .popover
        alertController.popoverPresentationController?.sourceItem = sender
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                let imagePicker = self.imagePicker(for: .camera)
                self.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            let imagePicker = self.imagePicker(for: .photoLibrary)
            imagePicker.modalPresentationStyle = .popover
            imagePicker.popoverPresentationController?.sourceItem = sender
            self.present(imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(photoLibraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func clearImage(_ sender: UIButton) {
        deckStore.imageStore.deleteImage(forKey: id)
        imageView.image = nil
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
        
        let context = deckStore.persistentContainer.viewContext
        let term = termTextField.text
        let definition = definitionTextView.text
        let partOfSpeech = partOfSpeechTextField.text
        let audio = audioTextField.text

        let newFlashcard = NSEntityDescription.insertNewObject(forEntityName: "Flashcard", into: context)
        newFlashcard.setValue(term, forKey: "term")
        newFlashcard.setValue(definition, forKey: "definition")
        newFlashcard.setValue(partOfSpeech, forKey: "partOfSpeech")
        newFlashcard.setValue(audio, forKey: "audio")
        newFlashcard.setValue(id, forKey: "id")
        deckStore.addFlashcard(flashcard: newFlashcard as! Flashcard, to: deck)
        delegate.updateFlashcards()
        
        cancel(sender)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePicker(for sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        return imagePicker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        deckStore.imageStore.setImage(image, forKey: id)
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
}
