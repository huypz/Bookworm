import UIKit
import CoreData
import QuickLookThumbnailing

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
    
    func fetchThumbnail(for document: Document, size: CGSize, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let key = document.id!
        if let image = imageStore.image(forKey: key) {
            OperationQueue.main.addOperation {
                completion(.success(image))
            }
            return
        }
        
        guard let url = document.url else {
            completion(.failure(ImageError.missingURL))
            return
        }
        let scale = UIScreen.main.scale
        let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: scale, representationTypes: .thumbnail)
        let generator = QLThumbnailGenerator.shared
        generator.generateBestRepresentation(for: request) { (thumbnail, error) in
            OperationQueue.main.addOperation {
                if thumbnail == nil {
                    completion(.failure(ImageError.imageCreationError))
                }
                else if error != nil {
                    completion(.failure(error!))
                }
                else {
                    completion(.success(thumbnail!.uiImage))
                }
                CFURLStopAccessingSecurityScopedResource(url as CFURL)
            }
        }
    }

    func addDocument(url: URL) {
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
            print("Error addDocument: \(error)")
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
            catch let error {
                completion(.failure(error))
            }
        }
        
    }
    
    func deleteDocument(_ document: Document) {
        let viewContext = persistentContainer.viewContext
        viewContext.performAndWait {
            viewContext.delete(document as NSManagedObject)
        }
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
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        let viewContext = persistentContainer.viewContext
        do {
            try viewContext.performAndWait {
                let documents = try viewContext.fetch(fetchRequest)
                documents.forEach {
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
