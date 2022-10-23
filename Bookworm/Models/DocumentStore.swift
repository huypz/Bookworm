import Foundation
import CoreData

class DocumentStore {
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Bookworm")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up Core Data (\(error)).")
            }
        }
        return container
    }()

    func processDocument(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let context = persistentContainer.viewContext
            var document: Document!
            context.performAndWait {
                document = Document(context: context)
                document.title = url.lastPathComponent
                document.remoteURL = url
                document.documentID = UUID().uuidString
                document.lastAccessed = Date()
                document.data = data
                document.thumbnail = Document.thumbnail(data: data)
                document.isSelected = false
            }
            try persistentContainer.viewContext.save()
        }
        catch {
            print("Error processing document: \(error)")
        }
    }
    
    func fetchDocuments(completion: @escaping (Result<[Document], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        let sortByLastAccessed = NSSortDescriptor(key: #keyPath(Document.lastAccessed), ascending: false)
        fetchRequest.sortDescriptors = [sortByLastAccessed]
        
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            do {
                let documents = try viewContext.fetch(fetchRequest)
                completion(.success(documents))
            }
            catch {
                completion(.failure(error))
            }
        }
        
    }
    
    func delete(_ document: Document) {
        do {
            let viewContext = persistentContainer.viewContext
            try viewContext.performAndWait {
                viewContext.delete(document as NSManagedObject)
                try persistentContainer.viewContext.save()
            }
        }
        catch {
            print("Error deleting document: \(error)")
        }
    }
}
