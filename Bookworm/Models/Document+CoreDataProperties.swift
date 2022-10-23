//
//  Document+CoreDataProperties.swift
//  Bookworm
//
//  Created by student on 10/23/22.
//
//

import Foundation
import CoreData


extension Document {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    @NSManaged public var documentID: String?
    @NSManaged public var remoteURL: URL?
    @NSManaged public var title: String?
    @NSManaged public var data: Data?
    @NSManaged public var isSelected: Bool
    @NSManaged public var lastAccessed: Date?
    @NSManaged public var thumbnail: Data?

}

extension Document : Identifiable {

}
