import UIKit
import CoreData

enum ImageError: Error {
    case imageCreationError
    case missingImageURL
}

class DocumentStore {
    
    var imageStore: ImageStore!
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Bookworm")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print("Error setting up CoreData (\(error))")
            }
        }
        return container
    }()
    
    func thumbnail(for document: Document) -> UIImage? {
        return imageStore.image(forKey: document.id!)
    }

    func fetchDocument(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let context = persistentContainer.viewContext
            var document: Document!
            context.performAndWait {
                document = Document(context: context)
                document.id = UUID().uuidString
                document.title = url.lastPathComponent
                document.isSelected = false
                document.lastAccessed = Date()
                document.data = data
                document.url = url
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
    
    func flush() {
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        let viewContext = persistentContainer.viewContext
        do {
            try viewContext.performAndWait {
                let documents = try viewContext.fetch(fetchRequest)
                documents.forEach {
                    viewContext.delete($0 as NSManagedObject)
                }
                try persistentContainer.viewContext.save()
            }
        }
        catch {
            print("Error flushing data: \(error)")
        }
    }
}
