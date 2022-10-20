//
//  Document.swift
//  Bookworm
//
//  Created by student on 27/07/1401 AP.
//

import UIKit

class Document: Equatable {
    
    var title: String?
    var url: URL
    var id: String
    
    static func ==(lhs: Document, rhs: Document) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(url: URL) {
        self.title = url.lastPathComponent
        self.url = url
        self.id = UUID().uuidString
    }
}
