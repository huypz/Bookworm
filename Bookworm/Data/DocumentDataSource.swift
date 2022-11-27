import UIKit

class DocumentDataSource: NSObject, UICollectionViewDataSource {
    
    var documents = [Document]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "DocumentCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! DocumentCell
        
        cell.update(displaying: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "\(LibraryHeaderView.self)", for: indexPath)
            return view
        default:
            assert(false, "Invalid UICollectionView element type")
            return UICollectionReusableView()
        }
    }
}
