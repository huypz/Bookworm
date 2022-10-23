import Foundation
import CoreData


extension Document {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    @NSManaged public var documentID: String?
    @NSManaged public var title: String?
    @NSManaged public var remoteURL: URL?
    @NSManaged public var data: Data?

}

extension Document : Identifiable {

}
