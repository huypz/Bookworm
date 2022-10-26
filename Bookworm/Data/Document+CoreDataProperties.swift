import Foundation
import CoreData


extension Document {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    @NSManaged public var data: Data?
    @NSManaged public var id: String?
    @NSManaged public var isSelected: Bool
    @NSManaged public var lastAccessed: Date?
    @NSManaged public var title: String?
    @NSManaged public var url: URL?

}

extension Document : Identifiable {

}
