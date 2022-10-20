//
//  DocumentStore.swift
//  Bookworm
//
//  Created by student on 26/07/1401 AP.
//

import Foundation
import PDFKit

class DocumentStore {
    
    var documents = [Document]()
    
    func fetchDocuments() {
        // let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        let documentsURL = Bundle.main.urls(forResourcesWithExtension: "pdf", subdirectory: .none)
        documentsURL?.forEach { (documentURL) in
            let document = Document(url: documentURL)
            print(document.title!)
            documents.append(document)
        }
    }
}
