import UIKit
import CoreData

class DeckStore {
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Bookworm")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error))")
            }
        }
        return container
    }()
    
    func fetchDecks(completion: @escaping (Result<[Deck], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Deck> = Deck.fetchRequest()
        let sortByTitle = NSSortDescriptor(key: "\(#keyPath(Deck.title))", ascending: true)
        fetchRequest.sortDescriptors = [sortByTitle]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let decks = try viewContext.fetch(fetchRequest)
                completion(.success(decks))
            }
            catch let error {
                completion(.failure(error))
            }
        }
    }
    
    func fetchFlashcards(completion: @escaping (Result<[Flashcard], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Flashcard> = Flashcard.fetchRequest()
        let sortByTerm = NSSortDescriptor(key: "\(#keyPath(Flashcard.term))", ascending: true)
        fetchRequest.sortDescriptors = [sortByTerm]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let flashcards = try fetchRequest.execute()
                completion(.success(flashcards))
            }
            catch let error {
                completion(.failure(error))
            }
        }
    }
    
    func addDeck(title: String) {
        let context = persistentContainer.viewContext
        var deck: Deck!
        context.performAndWait {
            deck = Deck(context: context)
            deck.title = title
        }
        saveContext()
    }
    
    func removeDeck(deck: Deck) {
        let viewContext = persistentContainer.viewContext
        viewContext.performAndWait {
            viewContext.delete(deck as NSManagedObject)
        }
        saveContext()
    }
    
    func addFlashcard(flashcard: Flashcard, to deck: Deck) {
        deck.addToFlashcards(flashcard)
        saveContext()
    }
    
    func removeFlashcard(flashcard: Flashcard, from deck: Deck) {
        deck.removeFromFlashcards(flashcard)
        saveContext()
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            }
            catch {
                fatalError("Error saveContext: \(error)")
            }
        }
    }
    
    func flushContext() {
        let decksFetchRequest: NSFetchRequest<Deck> = Deck.fetchRequest()
        let flashcardsFetchRequest: NSFetchRequest<Flashcard> = Flashcard.fetchRequest()
        let viewContext = persistentContainer.viewContext
        do {
            try viewContext.performAndWait {
                let documents = try viewContext.fetch(decksFetchRequest)
                documents.forEach {
                    viewContext.delete($0 as NSManagedObject)
                }
                let flashcards = try viewContext.fetch(flashcardsFetchRequest)
                flashcards.forEach {
                    viewContext.delete($0 as NSManagedObject)
                }
            }
        }
        catch {
            fatalError("Error flushContext: \(error)")
        }
        saveContext()
    }
}
