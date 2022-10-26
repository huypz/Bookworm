import UIKit

class DeckDataSource: NSObject, UITableViewDataSource {
    
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
}
