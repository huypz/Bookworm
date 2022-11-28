import UIKit
import QuickLookThumbnailing
import UniformTypeIdentifiers

class LibraryViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var importButtonItem: UIBarButtonItem!
    @IBOutlet var deleteButtonItem: UIBarButtonItem!
    
    var documentStore: DocumentStore!
    var imageStore: ImageStore!
    let dataSource = DocumentDataSource()
    
    var deckStore: DeckStore!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        navigationItem.rightBarButtonItem = editButtonItem
        editButtonItem.action = #selector(toggleEditingMode)
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        
        updateNavigationItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDataSource()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.title = ""
    }
    
    // MARK: - Navigation
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "showDocument":
            return !isEditing
        default:
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showDocument":
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                let document = dataSource.documents[selectedIndexPath.row]
                document.lastAccessed = Date()
                let readerViewController = segue.destination as! ReaderViewController
                readerViewController.deckStore = deckStore
                readerViewController.document = document
                readerViewController.hidesBottomBarWhenPushed = true
                readerViewController.navigationController?.hidesBarsOnTap = true
            }
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
    // MARK: - Data
    private func updateDataSource() {
        documentStore.fetchDocuments { (result) in
            switch result {
            case let .success(documents):
                self.dataSource.documents = documents
            case let .failure(error):
                print("Error fetching documents: \(error)")
                self.dataSource.documents.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    // MARK: - Actions
    @IBAction func toggleEditingMode(_ sender: Any?) {
        if isEditing {
            dataSource.documents.forEach {
                $0.isSelected = false
            }
            collectionView.allowsMultipleSelection = false
            collectionView.visibleCells.forEach {
                let cell = $0 as! DocumentCell
                cell.isEditing = false
                cell.isSelected = false
                cell.update()
            }
            deleteButtonItem.isEnabled = false
            setEditing(false, animated: true)
        }
        else {
            collectionView.allowsMultipleSelection = true
            collectionView.visibleCells.forEach {
                let cell = $0 as! DocumentCell
                cell.isEditing = true
                cell.isSelected = false
                cell.update()
            }
            setEditing(true, animated: true)
        }
        
        updateNavigationItem()
    }
    
    @IBAction func deleteSelectedDocuments(_ sender: UIBarButtonItem) {
        dataSource.documents.filter({ $0.isSelected }).forEach({ (document) in
            documentStore.deleteDocument(document)
        })
        updateDataSource()
        deleteButtonItem.isEnabled = false
    }
    
    @IBAction func documentMenu(_ sender: UIBarButtonItem) {
        let pickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf, UTType.epub])
    
        pickerViewController.delegate = self
        pickerViewController.allowsMultipleSelection = true
        pickerViewController.modalPresentationStyle = .popover
        pickerViewController.popoverPresentationController?.sourceItem = sender
        present(pickerViewController, animated: true, completion: nil)
    }
    
    // MARK: - Collection View
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard isEditing else {
            return
        }
        
        let document = dataSource.documents[indexPath.row]
        document.isSelected = true
        
        let cell = collectionView.cellForItem(at: indexPath) as! DocumentCell
        cell.update()
        
        if collectionView.indexPathsForSelectedItems?.count != 0 {
            deleteButtonItem.isEnabled = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard isEditing else {
            return
        }
        
        let document = dataSource.documents[indexPath.row]
        document.isSelected = false
        
        let cell = collectionView.cellForItem(at: indexPath) as! DocumentCell
        cell.update()
        
        if collectionView.indexPathsForSelectedItems?.count == 0 {
            deleteButtonItem.isEnabled = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let document = dataSource.documents[indexPath.row]
        
        documentStore.fetchThumbnail(for: document, size: cell.frame.size) { (result) in
            guard
                let documentIndex = self.dataSource.documents.firstIndex(of: document),
                case let .success(image) = result else {
                print("Failed to generate thumbnail for: \(result)")
                return
            }
            let documentIndexPath = IndexPath(item: documentIndex, section: 0)
            if let cell = self.collectionView.cellForItem(at: documentIndexPath) as? DocumentCell {
                self.documentStore.imageStore.setImage(image, forKey: document.id!)
                cell.isEditing = self.isEditing
                cell.isSelected = document.isSelected
                cell.update(displaying: image)
            }
        }
    }
    
    func updateNavigationItem() {
        if isEditing {
            navigationItem.setLeftBarButtonItems([deleteButtonItem], animated: true)
            navigationItem.setRightBarButtonItems([editButtonItem, importButtonItem], animated: true)
        }
        else {
            navigationItem.setLeftBarButtonItems(nil, animated: true)
            navigationItem.setRightBarButtonItems([editButtonItem], animated: true)
        }
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

extension LibraryViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            CFURLStartAccessingSecurityScopedResource(url as CFURL)
            documentStore.addDocument(url: url)
        }
        updateDataSource()
    }
}

class LibraryHeaderView: UICollectionReusableView {
    
    @IBOutlet var label: UILabel!
}
