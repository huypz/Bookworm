import QuickLook

class DocumentDataSource: NSObject, UICollectionViewDataSource {
    
    var documents = [Document]()
    
    var isEditing: Bool = false
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return documents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "DocumentCollectionViewCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! DocumentCollectionViewCell
        
        
        let document = documents[indexPath.row]
        cell.isEditing = isEditing
        cell.isSelected = document.isSelected
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
        }
    }
}
