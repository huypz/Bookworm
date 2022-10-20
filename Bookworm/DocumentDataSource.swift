//
//  PDFDocumentDataSource.swift
//  Bookworm
//
//  Created by student on 26/07/1401 AP.
//

import PDFKit

class DocumentDataSource: NSObject, UICollectionViewDataSource {
    
    var documents = [PDFDocument]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "PDFDocumentCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        return cell
    }
}
