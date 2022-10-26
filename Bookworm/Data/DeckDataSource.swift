import UIKit

class DeckDataSource: NSObject, UITableViewDataSource {
    
    var store: DeckStore!
    
    var decks = [Deck]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeckCell", for: indexPath) as! DeckCell
        let deck = decks[indexPath.row]
        cell.titleLabel.text = deck.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deck = decks[indexPath.row]
            if let index = decks.firstIndex(of: deck) {
                decks.remove(at: index)
                store.removeDeck(deck: deck)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveDeck(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func moveDeck(from fromIndex: Int, to toIndex: Int) {
        if fromIndex == toIndex {
            return
        }
        
        let movedDeck = decks[fromIndex]
        decks.remove(at: fromIndex)
        decks.insert(movedDeck, at: toIndex)
    }
}
