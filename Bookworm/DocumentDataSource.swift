//
//  PDFDocumentDataSource.swift
//  Bookworm
//
//  Created by student on 26/07/1401 AP.
//

import PDFKit

class DocumentDataSource: NSObject, UICollectionViewDataSource {
    
    var documents = [Document]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "DocumentCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! DocumentCollectionViewCell
        
        let document = documents[indexPath.row]
        if let documentPDF = PDFDocument(url: document.url),
           let page = documentPDF.page(at: 0) {
            let size = collectionView.collectionViewLayout.collectionViewContentSize
            let cover = page.thumbnail(of: size, for: .artBox)
            cell.imageView.image = cover
        }
        
        return cell
    }
}
