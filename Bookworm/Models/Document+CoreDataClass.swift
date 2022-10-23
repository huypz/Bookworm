import Foundation
import CoreData
import PDFKit

@objc(Document)
public class Document: NSManagedObject {
    
}

extension Document {
    
    static func thumbnail(data: Data) -> Data? {
        if let documentPDF = PDFDocument(data: data),
           let page = documentPDF.page(at: 0) {
            let cover = page.thumbnail(of: page.bounds(for: .artBox).size, for: .artBox)
            return cover.pngData()
        }
        return nil
    }
}
