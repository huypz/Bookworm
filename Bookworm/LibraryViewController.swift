import UIKit
import PDFKit

class LibraryViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    var documentStore: DocumentStore!
    let documentDataSource = DocumentDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = documentDataSource
        collectionView.delegate = self
        
        documentStore.fetchDocuments()
        documentDataSource.documents = documentStore.documents
        
        collectionView.reloadSections(IndexSet(integer: 0))
    }    
}

extension LibraryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = CGFloat(2)
        var paddingSpace = CGFloat(0)
        
        if let collectionViewFlowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            paddingSpace += collectionViewFlowLayout.minimumInteritemSpacing * (itemsPerRow - 1)
            paddingSpace += collectionViewFlowLayout.sectionInset.left + collectionViewFlowLayout.sectionInset.right
        }
        
        let itemWidth = ((collectionView.bounds.width - paddingSpace) / itemsPerRow).rounded(.down)
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
}
