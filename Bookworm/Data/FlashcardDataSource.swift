import UIKit

class FlashcardDataSource: NSObject, UITableViewDataSource {
    
    var delegate: FlashcardsViewController!
    
    var deckStore: DeckStore!
    var deck: Deck!
    
    var flashcards = [Flashcard]()
    var filteredFlashcards = [Flashcard]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFlashcards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlashcardCell", for: indexPath) as! FlashcardCell
        let flashcard = filteredFlashcards[indexPath.row]
        cell.imageStore = deckStore.imageStore
        cell.flashcard = flashcard
        cell.delegate = delegate
        
        cell.contentView.setNeedsLayout()
        cell.contentView.layoutIfNeeded()
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let flashcard = filteredFlashcards[indexPath.row]
            if let index = filteredFlashcards.firstIndex(of: flashcard) {
                filteredFlashcards.remove(at: index)
                deckStore.removeFlashcard(flashcard: flashcard, from: deck)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveFlashcard(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func moveFlashcard(from fromIndex: Int, to toIndex: Int) {
        if fromIndex == toIndex {
            return
        }
        let movedFlashcard = filteredFlashcards[fromIndex]
        filteredFlashcards.remove(at: fromIndex)
        filteredFlashcards.insert(movedFlashcard, at: toIndex)
    }
}
