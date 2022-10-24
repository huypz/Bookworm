import UIKit
import QuickLookThumbnailing
import PDFKit
import UniformTypeIdentifiers

class LibraryViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var importButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    
    var documentStore: DocumentStore!
    var imageStore: ImageStore!
    let dataSource = DocumentDataSource()
    
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
        
        updateDataSource()
        updateNavigationItem()
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
            case .failure:
                self.dataSource.documents.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    // MARK: - Actions
    @IBAction func toggleEditingMode(_ sender: Any?) {
        dataSource.isEditing = !isEditing
        dataSource.documents.forEach {
            $0.isSelected = false
        }
        
        if isEditing {
            collectionView.allowsMultipleSelection = false
            collectionView.indexPathsForSelectedItems?.forEach {
                collectionView.deselectItem(at: $0, animated: true)
            }
            collectionView.visibleCells.forEach {
                let cell = $0 as! DocumentCollectionViewCell
                cell.isEditing = false
                cell.isSelected = false
            }
            deleteButton.isEnabled = false
            collectionView.reloadSections(IndexSet(integer: 0))
            setEditing(false, animated: true)
        }
        else {
            collectionView.allowsMultipleSelection = true
            collectionView.visibleCells.forEach {
                let cell = $0 as! DocumentCollectionViewCell
                cell.isEditing = true
                cell.isSelected = false
            }
            setEditing(true, animated: true)
        }
        updateNavigationItem()
    }
    
    @IBAction func deleteSelectedDocuments(_ sender: UIBarButtonItem) {
        dataSource.documents.filter({ $0.isSelected }).forEach({ (document) in
            documentStore.delete(document)
        })
        updateDataSource()
        deleteButton.isEnabled = false
    }
    
    @IBAction func documentMenu(_ sender: UIBarButtonItem) {
        let pickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf, UTType.epub])
        pickerViewController.delegate = self
        pickerViewController.allowsMultipleSelection = true
        pickerViewController.modalPresentationStyle = .popover
        present(pickerViewController, animated: true, completion: nil)
    }
    
    // MARK: - Collection View
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            let cell = collectionView.cellForItem(at: indexPath) as! DocumentCollectionViewCell
            cell.isSelected = true
            
            let document = dataSource.documents[indexPath.row]
            document.isSelected = true
            
            if dataSource.documents.filter({ $0.isSelected }).count > 0 {
                deleteButton.isEnabled = true
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditing {
            let cell = collectionView.cellForItem(at: indexPath) as! DocumentCollectionViewCell
            cell.isSelected = false
            
            let document = dataSource.documents[indexPath.row]
            document.isSelected = false
            
            if dataSource.documents.filter({ $0.isSelected }).count == 0 {
                deleteButton.isEnabled = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let document = dataSource.documents[indexPath.row]
        if let cell = cell as? DocumentCollectionViewCell, let image = documentStore.thumbnail(for: document) {
            cell.update(displaying: image)
        }
        else {
            let url = document.url!
            let size = cell.frame.size
            let scale = UIScreen.main.scale
            let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: scale, representationTypes: .thumbnail)
            let generator = QLThumbnailGenerator.shared
            generator.generateRepresentations(for: request) { (thumbnail, type, error) in
                OperationQueue.main.addOperation {
                    guard let documentIndex = self.dataSource.documents.firstIndex(of: document), let image = thumbnail?.uiImage else {
                        return
                    }
                    let documentIndexPath = IndexPath(item: documentIndex, section: 0)
                    if let cell = self.collectionView.cellForItem(at: documentIndexPath) as? DocumentCollectionViewCell {
                        self.documentStore.imageStore.setImage(image, forKey: document.id!)
                        cell.update(displaying: image)
                    }
                }
            }
        }
    }
    
    func updateNavigationItem() {
        if isEditing {
            navigationItem.setLeftBarButtonItems([deleteButton], animated: true)
            navigationItem.setRightBarButtonItems([editButtonItem, importButton], animated: true)
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
        print("documentPicker didPickDocumentsAt")
        for url in urls {
            CFURLStartAccessingSecurityScopedResource(url as CFURL)
            documentStore.fetchDocument(url: url)
            CFURLStopAccessingSecurityScopedResource(url as CFURL)
        }
        updateDataSource()
    }
}

class LibraryHeaderView: UICollectionReusableView {
    
    @IBOutlet var label: UILabel!
}
